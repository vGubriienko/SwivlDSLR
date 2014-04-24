//
//  SWAppDelegate.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWAppDelegate.h"

#import "SWScript.h"
#import "SWSideBar.h"
#import "MVYSideMenuController.h"
#import <Swivl-iOS-SDK/SwivlCommonLib.h>
#import <Crashlytics/Crashlytics.h>

#define SW_SCRIPT_KEY @"SW_SCRIPT_KEY"
#define SW_CAMERA_INTERFACE_KEY @"SW_CAMERA_INTERFACE_KEY"

SWAppDelegate *swAppDelegate = nil;

@interface SWAppDelegate ()
{
    UIBarButtonItem *_splitVCBtn;
    
    MVYSideMenuController *_sideBarController;
    
    BOOL _stopForRunningNewScript;
}

@property (nonatomic, assign, getter = isScriptRunning) BOOL scriptRunning;

@end

@implementation SWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"3cc74596e11f1822925527f515758299a6b646bf"];
    [[Countly sharedInstance] start:@"a7c5600626ee637a959c35da28960279b2fe533a" withHost:@"https://cloud.count.ly"]; // newly added line
    
    swAppDelegate = self;
    self.swivl = [SwivlCommonLib sharedSwivlBaseForDelegate:self];

    NSNumber *savedCameraInterface = [[NSUserDefaults standardUserDefaults] objectForKey:SW_CAMERA_INTERFACE_KEY];
    if (savedCameraInterface) {
        self.currentCameraInterface = savedCameraInterface.integerValue;
    } else {
        self.currentCameraInterface = SWCameraInterfaceUSB;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needHideSideBarNotification)
                                                 name:SW_NEED_HIDE_SIDE_BAR_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needShowSideBarNotification)
                                                 name:SW_NEED_SHOW_SIDE_BAR_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scriptProgressDidFinish:)
                                                 name:AVSandboxScriptProgressDidFinishNotification
                                               object:nil];
    
    [self configRootController];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
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

- (void)swivlMoveFinished:(UInt32)state withID:(UInt32)ID
{
    NSLog(@"MOVE FINISHED: %i = %i", (unsigned int)state, ID);
}

- (void)swivlScriptBufferState:(UInt8)state isRunning:(BOOL)swivlIsBusy
{
    NSLog(@"swivlScriptBufferState isRunning: %i, state: %i", swivlIsBusy, state);

    if (self.isScriptRunning || !self.script) {
        return;
    }
    
    if (swivlIsBusy) {
        if (self.script.scriptType == SWScriptTypeDSLR) {
            [self showSwivlIsBusyMessage];
        }
        return;
    }
    
    self.scriptRunning = YES;
    self.script.startDate = [NSDate date];

    NSString *strScript = [self.script generateScript];
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
        [self.swivl swivlScriptLoadBlock:ptr length:length];
    }
    
    [self saveScript];
    [self.swivl swivlScriptStartSingleThread];
    NSLog(@"swivlScriptStartSingleThread");
}

- (void)swivlScriptResult:(SInt8)thread Result:(SInt8)res Run:(UInt16)run Stack:(UInt32)stack
{
    NSLog(@"swivlScriptResult thread: %i, Result: %i, Run: %i, Stack: %i", thread, res, run, stack);
    
    if (_stopForRunningNewScript) {
        _stopForRunningNewScript = NO;
        [self.swivl swivlScriptRequestBufferState];
    } else {
        self.scriptRunning = NO;
        [self removeScript];
    }
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
    SWScript *script = (SWScript *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (script && [script isRunningFromStartDate]) {
        self.script = script;
        self.scriptRunning = YES;
    }
}

#pragma mark - Properties

- (void)setCurrentCameraInterface:(SWCameraInterface)currentCameraInterface
{
    _currentCameraInterface = currentCameraInterface;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:currentCameraInterface ]forKey:SW_CAMERA_INTERFACE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setScriptRunning:(BOOL)scriptRunning
{
    _scriptRunning = scriptRunning;
    [[NSNotificationCenter defaultCenter] postNotificationName:AVSandboxSwivlScriptStateChangedNotification object:self];
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
        if (IS_IPHONE_4) {
            sideBarWidth = 125;
            
        } else {
            sideBarWidth = 200;
        }
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    
    UIViewController *mainVC = [storyboard instantiateViewControllerWithIdentifier:@"SWMainViewController"];
    
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

    self.scriptRunning = NO;
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
