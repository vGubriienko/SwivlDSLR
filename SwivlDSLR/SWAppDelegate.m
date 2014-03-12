//
//  SWAppDelegate.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWAppDelegate.h"

#import "SWSideBar.h"
#import <SWRevealViewController/SWRevealViewController.h>

#import <Swivl2Lib/SwivlCommonLib.h>

@interface SWAppDelegate () <UISplitViewControllerDelegate>
{
    UIBarButtonItem *_splitVCBtn;
    
    SWRevealViewController *_revealViewController;
    UISplitViewController *_splitViewController;
}
@end

@implementation SWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SwivlCommonLib sharedSwivlBaseForDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needHideSideBarNotification)
                                                 name:SW_NEED_HIDE_SIDE_BAR_NOTIFICATION
                                               object:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self configPadWindow];
    } else {
        [self configPhoneWindow];
    }
    
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

- (void) transitionAppToRecordingView
{

}

- (void) appTagsRecording
{

}

- (void) markerButtonEvents: (unsigned char) buttons
{

}

#pragma mark - Config UI

- (void)configPadWindow
{
    _splitViewController = (UISplitViewController *)self.window.rootViewController;
    NSMutableArray *controllers = [_splitViewController.viewControllers mutableCopy];
    
    SWSideBar *sideBar = [[SWSideBar alloc] initWithStyle:UITableViewStylePlain];
    sideBar.navigationController = controllers.lastObject;
    
    [controllers insertObject:sideBar atIndex:0];
    _splitViewController.viewControllers = controllers;
    _splitViewController.delegate = self;
}

- (void)configPhoneWindow
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UIViewController *mainVC = [storyboard instantiateViewControllerWithIdentifier:@"SWMainViewController"];
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    [navVC setNavigationBarHidden:YES];
    
    SWSideBar *sideBar = [[SWSideBar alloc] initWithStyle:UITableViewStylePlain];
    sideBar.navigationController = navVC;
    
    _revealViewController = [[SWRevealViewController alloc] initWithRearViewController:sideBar frontViewController:navVC];
    [navVC.view addGestureRecognizer:_revealViewController.panGestureRecognizer];
    self.window.rootViewController = _revealViewController;
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    _splitVCBtn = barButtonItem;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

- (void)needHideSideBarNotification
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_splitVCBtn.target performSelector: _splitVCBtn.action withObject:_splitVCBtn afterDelay:0];
    } else {
        [_revealViewController revealToggleAnimated:YES];
    }
}

@end
