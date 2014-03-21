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

#import <Swivl2Lib/SwivlCommonLib.h>

SWAppDelegate *swAppDelegate = nil;

@interface SWAppDelegate ()
{
    UIBarButtonItem *_splitVCBtn;
    
    MVYSideMenuController *_sideBarController;
}
@end

@implementation SWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    swAppDelegate = self;
    self.swivl = [SwivlCommonLib sharedSwivlBaseForDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needHideSideBarNotification)
                                                 name:SW_NEED_HIDE_SIDE_BAR_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needShowSideBarNotification)
                                                 name:SW_NEED_SHOW_SIDE_BAR_NOTIFICATION
                                               object:nil];
    
    [self configRootController];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
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

}

- (void)swivlScriptBufferState:(UInt8)state isRunning:(BOOL)isRunning
{
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
    
    [self.swivl swivlScriptStartThread];
}

- (void)swivlScriptResult:(SInt8)thread Result:(SInt8)res Run:(UInt16)run Stack:(UInt32)stack
{

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

#pragma mark - Show/Hide side bar

- (void)needHideSideBarNotification
{
    [_sideBarController closeMenu];
}

- (void)needShowSideBarNotification
{
    [_sideBarController openMenu];
}

@end
