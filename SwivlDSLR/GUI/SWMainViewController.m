//
//  SWMainViewController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWMainViewController.h"

#import "SWScript.h"
#import "SWTimelapseSettings.h"
#import "SWAppDelegate.h"

#import <Swivl-iOS-SDK/SwivlCommonLib.h>

#define SW_TIMELAPSE_SETTINGS_KEY @"SW_TIMELAPSE_SETTINGS_KEY"

@protocol SWContentControllerDelegate <NSObject>
@optional
@property (nonatomic, weak) SWScript *script;
@property (nonatomic, weak) SWTimelapseSettings *timelapseSettings;
@end

@interface SWMainViewController ()
{
    __weak IBOutlet UIButton *_stepsBtn;
    __weak IBOutlet UIButton *_directionBtn;
    __weak IBOutlet UIButton *_stepSizeBtn;
    __weak IBOutlet UIButton *_timeBtn;
    __weak IBOutlet UIButton *_tiltBtn;
    __weak IBOutlet UIView *_timelapseControls;
    __weak IBOutlet UIButton *_helpButton;
    
    __weak IBOutlet UITextView *_infoTextView;
    __weak IBOutlet UIButton *_captureBtn, *_captureBtnActive;
    __weak IBOutlet UIImageView *_batteryLevelImg;
    __weak IBOutlet UIImageView *_swivlStatusImg;
    
    SWTimelapseSettings *_timelapseSettings;
    UIViewController <SWContentControllerDelegate> *_currentContentController;
    
    BOOL _isShowingProgress;
}
@end

@implementation SWMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self restoreSettings];
    [self startObserving];
    [self configUI];
}

- (void)configUI
{
    _stepSizeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _stepsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _timeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _tiltBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    _infoTextView.contentOffset = CGPointZero;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
    
    [self startObserving];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self finishObserving];
}

#pragma mark - IBActions

- (IBAction)onInfoBtnTapped
{
    [self clearContent];
}

- (IBAction)onDirectionBtnTapped
{
    _timelapseSettings.clockwiseDirection = !_timelapseSettings.clockwiseDirection;
    
    [swAppDelegate.swivl swivlScriptStop];
}

- (IBAction)onMenuBtnTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SW_NEED_SHOW_SIDE_BAR_NOTIFICATION object:self];
}

- (IBAction)onCaptureBtnTapped
{
    if (swAppDelegate.scriptState == SWScriptStateNone) {
        if (swAppDelegate.swivl.swivlConnected) {
            SWScript *script = [[SWScript alloc] init];
            script.timelapseSettings = _timelapseSettings;
            script.scriptType = SWScriptTypeTimelapse;
            script.connectionType = swAppDelegate.currentCameraInterface;
            script.dslrConfiguration = swAppDelegate.currentDSLRConfiguration;
            swAppDelegate.script = script;
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

#pragma mark - Progress

- (void)showProgress
{
    _isShowingProgress = YES;
    
    _stepsBtn.enabled = NO;
    _stepSizeBtn.enabled = NO;
    _timeBtn.enabled = NO;
    _tiltBtn.enabled = NO;
    _helpButton.enabled = NO;
    _directionBtn.enabled = NO;

    _captureBtnActive.hidden = NO;
    _captureBtnActive.alpha = 1.0;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         _captureBtnActive.alpha = 0.0;
                     }
                     completion:nil];
    
    [self performSegueWithIdentifier:@"ScriptProgress" sender:nil];
}

- (void)hideProgress
{
    _isShowingProgress = NO;
    
    _directionBtn.enabled = YES;
    _stepsBtn.enabled = YES;
    _stepSizeBtn.enabled = YES;
    _timeBtn.enabled = YES;
    _tiltBtn.enabled = YES;
    _helpButton.enabled = YES;
    
    _captureBtnActive.hidden = YES;
    [_captureBtnActive.layer removeAllAnimations];
    
    [self clearContent];
}

#pragma mark - Storyboard navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self clearContent];
    _currentContentController = segue.destinationViewController;

    if ([_currentContentController respondsToSelector:@selector(setTimelapseSettings:)]) {
        [_currentContentController performSelector:@selector(setTimelapseSettings:) withObject:_timelapseSettings];
    }
    if ([_currentContentController respondsToSelector:@selector(setScript:)]) {
        [_currentContentController performSelector:@selector(setScript:) withObject:swAppDelegate.script];
    }
}

- (void)clearContent
{
    [_currentContentController willMoveToParentViewController:nil];
    [_currentContentController.view removeFromSuperview];
    [_currentContentController removeFromParentViewController];
    _currentContentController = nil;
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
                                             selector:@selector(scriptStateDidChanged)
                                                 name:AVSandboxSwivlScriptStateChangedNotification
                                               object:nil];
    [self scriptStateDidChanged];
    
    [_timelapseSettings addObserver:self
                         forKeyPath:@"stepCount"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
    [_timelapseSettings addObserver:self
                         forKeyPath:@"stepSize"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
    [_timelapseSettings addObserver:self forKeyPath:@"timeBetweenPictures"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
    [_timelapseSettings addObserver:self forKeyPath:@"clockwiseDirection"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
    [_timelapseSettings addObserver:self forKeyPath:@"startTiltAngle"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
    [_timelapseSettings addObserver:self forKeyPath:@"endTiltAngle"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
    
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _timelapseSettings) {
        
        [_stepsBtn setTitle:[NSString stringWithFormat:@"%li", (long)_timelapseSettings.stepCount] forState:UIControlStateNormal];
        
        [_stepSizeBtn setTitle:[NSString stringWithFormat:@"%.2f", _timelapseSettings.stepSize] forState:UIControlStateNormal];
        
        NSString *strTime = [NSString stringWithFormat:@"%li - %li", (long)_timelapseSettings.startTiltAngle, (long)_timelapseSettings.endTiltAngle];
        [_tiltBtn setTitle:strTime forState:UIControlStateNormal];
        
        SWTimeComponents timeComps = [_timelapseSettings timeBetweenPicturesComponents];
        strTime = [NSString stringWithFormat:@"%.2li:%.2li:%.2li", (long)timeComps.hours, (long)timeComps.minutes, (long)timeComps.seconds];
        [_timeBtn setTitle:strTime forState:UIControlStateNormal];
        
        _directionBtn.selected = !_timelapseSettings.clockwiseDirection;
        
        [self saveSettings];
    }
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

- (void)scriptStateDidChanged
{
    if (swAppDelegate.scriptState == SWScriptStatePreparing) {
        [self showProgress];
    } else if (swAppDelegate.scriptState == SWScriptStateRunning) {
        if (!_isShowingProgress) {
            [self showProgress];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:AVSandboxScriptProgressNeedStartNotification object:nil];
    } else if (swAppDelegate.scriptState == SWScriptStateNone) {
        [self hideProgress];
    }
}

- (void)finishObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_timelapseSettings removeObserver:self forKeyPath:@"stepCount"];
    [_timelapseSettings removeObserver:self forKeyPath:@"stepSize"];
    [_timelapseSettings removeObserver:self forKeyPath:@"timeBetweenPictures"];
    [_timelapseSettings removeObserver:self forKeyPath:@"clockwiseDirection"];
    [_timelapseSettings removeObserver:self forKeyPath:@"startTiltAngle"];
    [_timelapseSettings removeObserver:self forKeyPath:@"endTiltAngle"];

}

#pragma mark - Saving

- (void)saveSettings
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_timelapseSettings];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SW_TIMELAPSE_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreSettings
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SW_TIMELAPSE_SETTINGS_KEY];
    _timelapseSettings = (SWTimelapseSettings *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!_timelapseSettings) {
        _timelapseSettings = [[SWTimelapseSettings alloc] init];
    }
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
