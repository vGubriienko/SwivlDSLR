//
//  SWAppDelegate.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWAppDelegate.h"

#import "SWScript.h"
#import "SWTimelapseSettings.h"
#import "SWDSLRConfiguration.h"
#import "SWSideBar.h"
#import "MVYSideMenuController.h"
#import <Swivl2Lib/SwivlCommonLib.h>
#import <Crashlytics/Crashlytics.h>

#define SW_SCRIPT_KEY @"SW_SCRIPT_KEY"
#define SW_CAMERA_INTERFACE_KEY @"SW_CAMERA_INTERFACE_KEY"
#define SW_CAMERA_CONFIGURATION_KEY @"SW_CAMERA_CONFIGURATION_KEY"

SWAppDelegate *swAppDelegate = nil;

@interface SWAppDelegate () <SwivlBaseDelegate>
{ 
    MVYSideMenuController *_sideBarController;
    
    BOOL _stopForRunningNewScript;
    //BOOL _moveBeforeTimelapse;
}

@end

@implementation SWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"3cc74596e11f1822925527f515758299a6b646bf"];
    [[Countly sharedInstance] start:@"a7c5600626ee637a959c35da28960279b2fe533a" withHost:@"https://cloud.count.ly"]; // newly added line
    
    swAppDelegate = self;
    self.swivl = [SwivlCommonLib sharedSwivlBaseForDelegate:self];

    [self loadConfigurations];
    [self loadDefaults];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scriptProgressDidFinish:)
                                                 name:AVSandboxScriptProgressDidFinishNotification
                                               object:nil];
    
    [self configRootController];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // HACK: avoid autohiding on iOS 8 + iPhone
    [UIApplication sharedApplication].statusBarHidden = YES;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self restoreSavedScript];

    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark SwivlBaseDelegate

- (void)swivlLibVersion:(NSDictionary *)dict
{
	NSLog(@"SwivlCommonLib has sent us version information:[%@]", dict);
}

- (BOOL)appIsRecording
{
	return NO;
}

- (BOOL)appShouldStartRecording
{
    return NO;
}

- (void)setAppRecording:(BOOL)recording
{

}

- (BOOL)appAtRecordingView
{
    return NO;
}

- (void)transitionAppToRecordingView
{

}

- (void)appTagsRecording
{

}

- (void)markerButtonEvents:(unsigned char)buttons
{
    //Change to open SDK and remove this
}

- (void)baseAudioJackStateChanged:(BOOL)pluggedin
{

}

- (void)swivlScriptBufferState:(UInt8)state isRunning:(BOOL)swivlIsBusy
{
    NSLog(@"swivlScriptBufferState isRunning: %i, state: %i", swivlIsBusy, state);

    if (self.scriptState == SWScriptStateRunning || !self.script) {
        return;
    }
    
    if (swivlIsBusy) {
        if (self.script.scriptType == SWScriptTypeTimelapse) {
            [self showSwivlIsBusyMessage];
        }
        return;
    }
    
//    if (self.script.timelapseSettings) {
//        _moveBeforeTimelapse = YES;
//        [self prepareForRunningScript];
//    } else {
        [self runScript];
//    }
}

//- (void)prepareForRunningScript
//{
//    self.scriptState = SWScriptStatePreparing;
//    
//    MotionDescriptor *motionDescriptor = [[MotionDescriptor alloc] init];
//    motionDescriptor.ID = [swAppDelegate.swivl swivlLastFinishedMoveId] + 1;
//    motionDescriptor.axis = AXIS_TILT;
//    motionDescriptor.type = MOVE_TO_ABS_POS;
//    motionDescriptor.steps = self.script.timelapseSettings.startTiltAngle / 0.0088;
//    motionDescriptor.speed = 1000;
//    motionDescriptor.startNow = YES;
//    motionDescriptor.timeoutMs = 0;
//    [swAppDelegate.swivl swivlMoveLoad:motionDescriptor];
//}

- (void)runScript
{
    self.scriptState = SWScriptStateRunning;
    self.script.startDate = [NSDate date];
    
    NSString *strScript = [self.script generateScriptForInterface:self.currentCameraInterface];
    char *ptr = (char *)[strScript UTF8String];
    NSInteger length = strScript.length;
    
    while(length > 100)
    {
        [self.swivl swivlScriptLoadBlock:ptr length:100];
        length -= 100;
        ptr += 100;
    }
    if (length > 0)
    {
        [self.swivl swivlScriptLoadBlock:ptr length:(int)length];
    }
    
    [self saveScript];
    
    [self.swivl swivlScriptStartSingleThread];
    NSLog(@"swivlScriptStartSingleThread");
}

- (void)swivlScriptResult:(SInt8)thread Result:(SInt8)res Run:(UInt16)run Stack:(UInt32)stack
{
    NSLog(@"swivlScriptResult thread: %i, Result: %i, Run: %i, Stack: %i", thread, res, run, (unsigned int)stack);
    
    if (_stopForRunningNewScript) {
        _stopForRunningNewScript = NO;
        [self.swivl swivlScriptRequestBufferState];
    } else {
        self.scriptState = SWScriptStateNone;
        [self removeScript];
    }
}

- (void)swivlMoveFinished:(int32_t)state withID:(int32_t)ID;
{
//    if (_moveBeforeTimelapse) {
//        _moveBeforeTimelapse = NO;
//        [self runScript];
//    }
    NSLog(@"swivlMoveFinished state: %i, ID: %i", (unsigned int)state, (unsigned int)ID);
}

#pragma mark - Save script

- (void)saveScript
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.script];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SW_SCRIPT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeScript
{
    self.script = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SW_SCRIPT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreSavedScript
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SW_SCRIPT_KEY];
    if (data) {
        SWScript *script = (SWScript *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (script && [script isRunningFromStartDate]) {
            self.script = script;
            self.scriptState = SWScriptStateRunning;
        }
    }
}

#pragma mark - Load & Copy configurations

- (NSString *)configurationsDirectory
{
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *pathToDrivers = [documentsDirectory stringByAppendingPathComponent:@"Configurations"];
    return pathToDrivers;
}

- (NSString *)pathForConfiguration:(NSString *)configurationPath
{
    return [[self configurationsDirectory] stringByAppendingPathComponent:configurationPath];
}

- (void)copyDefaultConfigurations
{
    BOOL success;
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@""];
    success = [fileManager fileExistsAtPath:[self configurationsDirectory]];
    if (success) {
        [fileManager removeItemAtPath:[self configurationsDirectory] error:&error];
    }
    success = [fileManager copyItemAtPath:path toPath:[self configurationsDirectory] error:&error];

}

- (void)loadConfigurations
{
    [self copyDefaultConfigurations];
    _availableDSLRConfigurations = nil;
    NSMutableArray *configurations = [NSMutableArray new];
    
    NSError *error;
    NSArray *configurationsFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self configurationsDirectory] error:&error];
    
    for (NSString *configuration in configurationsFiles) {
        NSDictionary *configDict = [NSDictionary dictionaryWithContentsOfFile:[self pathForConfiguration:configuration]];
        SWDSLRConfiguration *configuration = [SWDSLRConfiguration configurationWithDictionary:configDict];
        [configurations addObject:configuration];
    }
    
    _availableDSLRConfigurations = [configurations copy];
}

#pragma mark - Properties

- (void)setCurrentCameraInterface:(SWCameraInterface)currentCameraInterface
{
    if (_currentCameraInterface != currentCameraInterface) {
        _currentCameraInterface = currentCameraInterface;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:currentCameraInterface ]forKey:SW_CAMERA_INTERFACE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setCurrentDSLRConfiguration:(SWDSLRConfiguration *)currentCameraConfiguration
{
    if (_currentDSLRConfiguration != currentCameraConfiguration) {
        _currentDSLRConfiguration = currentCameraConfiguration;
        [[NSUserDefaults standardUserDefaults] setObject:_currentDSLRConfiguration.dictionary forKey:SW_CAMERA_CONFIGURATION_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setScriptState:(SWScriptState)scriptState
{
    if (scriptState != _scriptState) {
        _scriptState = scriptState;
        [[NSNotificationCenter defaultCenter] postNotificationName:AVSandboxSwivlScriptStateChangedNotification object:self];
    }
}

- (void)loadDefaults
{
    NSNumber *savedCameraInterface = [[NSUserDefaults standardUserDefaults] objectForKey:SW_CAMERA_INTERFACE_KEY];
    
    if (savedCameraInterface) {
        self.currentCameraInterface = savedCameraInterface.integerValue;
    } else {
        self.currentCameraInterface = SWCameraInterfaceUSB;
    }
    
    NSDictionary *savedDSLRConfiguration = [[NSUserDefaults standardUserDefaults] objectForKey:SW_CAMERA_CONFIGURATION_KEY];
    if (savedDSLRConfiguration) {
        self.currentDSLRConfiguration = [SWDSLRConfiguration configurationWithDictionary:savedDSLRConfiguration];
    } else {
        //Default value is first configuration
        self.currentDSLRConfiguration = [self.availableDSLRConfigurations firstObject];
    }
}

#pragma mark - Config UI

- (void)configRootController
{
    NSInteger sideBarWidth;
    UIStoryboard *storyboard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        sideBarWidth = 320;
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    } else {
        sideBarWidth = 200;
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    
    UIViewController *mainVC = self.window.rootViewController;
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:18.0 / 255.0 green:19.0 / 255.0 blue:19.0 / 255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    [navVC setNavigationBarHidden:YES];

    SWSideBar *sideBar = [[SWSideBar alloc] initWithStyle:UITableViewStylePlain];
    sideBar.navigationController = navVC;
    
    MVYSideMenuOptions *options = [[MVYSideMenuOptions alloc] init];
    options.contentViewScale = 1.0f;
    _sideBarController = [[MVYSideMenuController alloc] initWithMenuViewController:sideBar
                                                             contentViewController:navVC options:options];
    _sideBarController.menuFrame = CGRectMake(0, 0, sideBarWidth, -1);
    self.window.rootViewController = _sideBarController;
}

#pragma mark - Notifications

- (void)needHideSideBarNotification
{
    [_sideBarController closeMenu];
}

- (void)needShowSideBarNotification
{
    [_sideBarController openMenu];
}

- (void)scriptProgressDidFinish:(NSNotification *)notification
{
    NSLog(@"scriptProgressDidFinish");

    self.scriptState = SWScriptStateNone;
    [self removeScript];
}

#pragma mark - messages

- (void)showSwivlIsBusyMessage
{
    [[[UIAlertView alloc] initWithTitle:@"Swivl is busy"
                                message:@"Swivl is making time-lapse photography at the moment. Try again later."
                               delegate:nil
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Start anyway?", nil]
     
     showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
         if (buttonIndex == 1) {
             _stopForRunningNewScript = YES;
             [self.swivl swivlScriptStop];
         }
    }];
}

@end
