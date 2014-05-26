//
//  SWManualController.m
//  SwivlDSLR
//
//  Created by Sergei Me (mer.sergei@gmai.com) on 4/10/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWManualController.h"
#import "SWScript.h"

#import "SWAppDelegate.h"
#import "SwivlCommonLib.h"
#import "MotionDescriptor.h"

@interface SWManualController()
{
    __weak IBOutlet UIImageView *_batteryLevelImg;
    __weak IBOutlet UIImageView *_swivlStatusImg;
}

@end

@implementation SWManualController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startObserving];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.navigationController.view.bounds;
    self.view.frame = frame;
}

#pragma mark - IBActions

- (IBAction)onMenuBtnTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SW_NEED_SHOW_SIDE_BAR_NOTIFICATION object:self];
}

- (IBAction)onLeftBtnStart:(id)sender
{
    MotionDescriptor *motionDescriptor = [[MotionDescriptor alloc] init];
    motionDescriptor.ID = [swAppDelegate.swivl swivlLastFinishedMoveId] + 1;
    motionDescriptor.axis = AXIS_PAN;
    motionDescriptor.type = MOVE_TO_REL_POS;
    motionDescriptor.steps = -80000;
    motionDescriptor.speed = 2000;
    motionDescriptor.startNow = YES;
    motionDescriptor.timeoutMs = 0;
    [swAppDelegate.swivl swivlMoveLoad:motionDescriptor];
}

- (IBAction)onLeftBtnStop:(id)sender
{
    MotionDescriptor *motionDescriptor = [[MotionDescriptor alloc] init];
    motionDescriptor.ID = [swAppDelegate.swivl swivlLastFinishedMoveId] + 1;
    motionDescriptor.axis = AXIS_PAN;
    motionDescriptor.type = MOVE_TO_REL_POS;
    motionDescriptor.steps = -4;
    motionDescriptor.speed = 1000;
    motionDescriptor.startNow = YES;
    motionDescriptor.timeoutMs = 0;
    [swAppDelegate.swivl swivlMoveLoad:motionDescriptor];
}

- (IBAction)onRightBtnStart:(id)sender
{
    MotionDescriptor *motionDescriptor = [[MotionDescriptor alloc] init];
    motionDescriptor.ID = [swAppDelegate.swivl swivlLastFinishedMoveId] + 1;
    motionDescriptor.axis = AXIS_PAN;
    motionDescriptor.type = MOVE_TO_REL_POS;
    motionDescriptor.steps = 80000;
    motionDescriptor.speed = 2000;
    motionDescriptor.startNow = YES;
    motionDescriptor.timeoutMs = 0;
    [swAppDelegate.swivl swivlMoveLoad:motionDescriptor];
}

- (IBAction)onRightBtnStop:(id)sender
{
    MotionDescriptor *motionDescriptor = [[MotionDescriptor alloc] init];
    motionDescriptor.ID = [swAppDelegate.swivl swivlLastFinishedMoveId] + 1;
    motionDescriptor.axis = AXIS_PAN;
    motionDescriptor.type = MOVE_TO_REL_POS;
    motionDescriptor.steps = 4;
    motionDescriptor.speed = 1000;
    motionDescriptor.startNow = YES;
    motionDescriptor.timeoutMs = 0;
    [swAppDelegate.swivl swivlMoveLoad:motionDescriptor];
}

- (IBAction)onUpBtnStart:(id)sender
{
    MotionDescriptor *motionDescriptor = [[MotionDescriptor alloc] init];
    motionDescriptor.ID = [swAppDelegate.swivl swivlLastFinishedMoveId] + 1;
    motionDescriptor.axis = AXIS_TILT;
    motionDescriptor.type = MOVE_TO_REL_POS;
    motionDescriptor.steps = 3000;
    motionDescriptor.speed = 400;
    motionDescriptor.startNow = YES;
    motionDescriptor.timeoutMs = 0;
    [swAppDelegate.swivl swivlMoveLoad:motionDescriptor];
}

- (IBAction)onUpBtnStop:(id)sender
{
    MotionDescriptor *motionDescriptor = [[MotionDescriptor alloc] init];
    motionDescriptor.ID = [swAppDelegate.swivl swivlLastFinishedMoveId] + 1;
    motionDescriptor.axis = AXIS_TILT;
    motionDescriptor.type = MOVE_TO_REL_POS;
    motionDescriptor.steps = 4;
    motionDescriptor.speed = 100;
    motionDescriptor.startNow = YES;
    motionDescriptor.timeoutMs = 0;
    [swAppDelegate.swivl swivlMoveLoad:motionDescriptor];
}

- (IBAction)onDownBtnStart:(id)sender
{
    MotionDescriptor *motionDescriptor = [[MotionDescriptor alloc] init];
    motionDescriptor.ID = [swAppDelegate.swivl swivlLastFinishedMoveId] + 1;
    motionDescriptor.axis = AXIS_TILT;
    motionDescriptor.type = MOVE_TO_REL_POS;
    motionDescriptor.steps = -3000;
    motionDescriptor.speed = 400;
    motionDescriptor.startNow = YES;
    motionDescriptor.timeoutMs = 0;
    [swAppDelegate.swivl swivlMoveLoad:motionDescriptor];
}

- (IBAction)onDownBtnStop:(id)sender
{
    MotionDescriptor *motionDescriptor = [[MotionDescriptor alloc] init];
    motionDescriptor.ID = [swAppDelegate.swivl swivlLastFinishedMoveId] + 1;
    motionDescriptor.axis = AXIS_TILT;
    motionDescriptor.type = MOVE_TO_REL_POS;
    motionDescriptor.steps = -4;
    motionDescriptor.speed = 100;
    motionDescriptor.startNow = YES;
    motionDescriptor.timeoutMs = 0;
    [swAppDelegate.swivl swivlMoveLoad:motionDescriptor];
}

- (IBAction)onCaptureBtnTapped
{
    if (swAppDelegate.scriptState == SWScriptStateNone) {
        if (swAppDelegate.swivl.swivlConnected) {
            SWScript *script = [[SWScript alloc] init];
            swAppDelegate.script = script;
            script.scriptType = SWScriptTypeShot;
            script.connectionType = swAppDelegate.currentCameraInterface;
            script.dslrConfiguration = swAppDelegate.currentDSLRConfiguration;
            [swAppDelegate.swivl swivlScriptRequestBufferState];
        } else {
            [self showSwivlDisconnectedMessage];
        }
    } else if (swAppDelegate.scriptState == SWScriptStateRunning) {
        if (swAppDelegate.swivl.swivlConnected) {
            NSLog(@"swivlScriptStop");
            [swAppDelegate.swivl swivlScriptStop];
            [[NSNotificationCenter defaultCenter] postNotificationName:AVSandboxScriptProgressDidFinishNotification object:self];
        } else {
            [self showStopProgressConfirmation];
        }
    }
}

#pragma mark - Observing

- (void)startObserving
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryStateChanged)
                                                 name:AVSandboxSwivlDockAttached
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryStateChanged)
                                                 name:AVSandboxSwivlDockDetached
                                               object:nil];
    [self accessoryStateChanged];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBatteryLevel)
                                                 name:AVSandboxBaseBatteryLevelChanged
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBatteryLevel)
                                                 name:AVSandboxMarkerBatteryLevelChanged
                                               object:nil];
    [self updateBatteryLevel];
}

- (void)accessoryStateChanged
{
    _swivlStatusImg.highlighted = swAppDelegate.swivl.swivlConnected;
}

- (void)updateBatteryLevel
{
    CGFloat deviceBatteryLevel = [UIDevice currentDevice].batteryLevel;
    if (deviceBatteryLevel > 0) {
        deviceBatteryLevel *= 100;
    }
    
    NSInteger markerBatteryLevel = swAppDelegate.swivl.markerBatteryLevel;
    NSInteger baseBatteryLevel = swAppDelegate.swivl.baseBatteryLevel;
    
    if (!swAppDelegate.swivl.primaryMarkerConnected)
    {
        markerBatteryLevel = -1;
    }
    
    BOOL lowBattery = NO;
    lowBattery = lowBattery || (deviceBatteryLevel > -1 && deviceBatteryLevel < BATTERY_LOW_LEVEL);
    lowBattery = lowBattery || (baseBatteryLevel > -1 && baseBatteryLevel < BATTERY_LOW_LEVEL);
    lowBattery = lowBattery || (markerBatteryLevel > -1 && markerBatteryLevel < BATTERY_LOW_LEVEL);
    
    _batteryLevelImg.hidden = !lowBattery;
}

- (void)finishObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Messages

- (void)showSwivlDisconnectedMessage
{
    [[[UIAlertView alloc] initWithTitle:@"Swivl is disconnected"
                                message:@"Make sure there is bluetooth connection with Swivl and try again."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)showStopProgressConfirmation
{
    [[[UIAlertView alloc] initWithTitle:@"Swivl is disconnected"
                                message:@"There is no connection with swivl at the moment. Stop showing progress?"
                               delegate:nil
                      cancelButtonTitle:@"NO"
                      otherButtonTitles:@"YES", nil]
     
     showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
         if (buttonIndex == 1) {
             [[NSNotificationCenter defaultCenter] postNotificationName:AVSandboxScriptProgressDidFinishNotification object:self];
         }
     }];
}


#pragma mark -

- (void)dealloc
{
    [self finishObserving];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
