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
#import "TimelapsSegue.h"
#import "SWAppDelegate.h"

#import <Swivl2Lib/SwivlCommonLib.h>

#define SW_SCRIPT_KEY @"SW_SCRIPT_KEY"
#define SW_TIMELAPSE_SETTINGS_KEY @"SW_TIMELAPSE_SETTINGS_KEY"

@interface SWMainViewController ()
{
    __weak IBOutlet UIButton *_distanceBtn;
    __weak IBOutlet UIButton *_directionBtn;
    __weak IBOutlet UIButton *_stepSizeBtn;
    __weak IBOutlet UIButton *_recordingTimeBtn;
    __weak IBOutlet UIButton *_timeBetweenPicturesBtn;
    __weak IBOutlet UIImageView *_batteryLevelImg;
    __weak IBOutlet UIImageView *_swivlStatusImg;

    NSTimer *_observeBatteryLevelTimer;
    
    SWTimelapseSettings *_timelapseSettings;
    
    UIViewController <TimelapsSegueNavigation> *_currentSettingsController;
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
    _distanceBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _recordingTimeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _timeBetweenPicturesBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
}

#pragma mark - IBActions

- (IBAction)onDirectionBtnTapped
{
    _timelapseSettings.clockwiseDirection = !_timelapseSettings.clockwiseDirection;
}

- (IBAction)onMenuBtnTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SW_NEED_SHOW_SIDE_BAR_NOTIFICATION object:nil];
}

- (IBAction)onCaptureBtnTapped
{
    SWScript *script = [[SWScript alloc] initWithTimelapseSettings:_timelapseSettings];
    
    swAppDelegate.script = script;
    script.type = swAppDelegate.currentCameraInterface;
    [swAppDelegate.swivl swivlScriptRequestBufferState];
    
    [self saveScript:script];
    
    //TO DO: show progress
}

#pragma mark - Storyboard navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [_currentSettingsController.view removeFromSuperview];
   
    _currentSettingsController = segue.destinationViewController;

    //Set settings to edit controller
    if ([_currentSettingsController respondsToSelector:@selector(setTimelapseSettings:)]) {
        [_currentSettingsController setTimelapseSettings:_timelapseSettings];
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
    
    [_timelapseSettings addObserver:self
                         forKeyPath:@"distance"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
    [_timelapseSettings addObserver:self
                         forKeyPath:@"stepSize"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
    [_timelapseSettings addObserver:self forKeyPath:@"timeBetweenPictures"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
    [_timelapseSettings addObserver:self forKeyPath:@"recordingTime"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
    [_timelapseSettings addObserver:self forKeyPath:@"clockwiseDirection"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
    
    _observeBatteryLevelTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                 target:self
                                                               selector:@selector(updateBatteryLevel)
                                                               userInfo:nil
                                                                repeats:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _timelapseSettings) {
        
        [_distanceBtn setTitle:[NSString stringWithFormat:@"%li", (long)_timelapseSettings.distance] forState:UIControlStateNormal];
        
        [_stepSizeBtn setTitle:[NSString stringWithFormat:@"%.2f", _timelapseSettings.stepSize] forState:UIControlStateNormal];
        
        SWTimeComponents timeComps = [_timelapseSettings timeBetweenPicturesComponents];
        NSString *strTime = [NSString stringWithFormat:@"%.2li:%.2li:%.2li", (long)timeComps.hours, (long)timeComps.minutes, (long)timeComps.seconds];
        [_timeBetweenPicturesBtn setTitle:strTime forState:UIControlStateNormal];
        
        timeComps = [_timelapseSettings recordingTimeComponents];
        strTime = [NSString stringWithFormat:@"%.2li:%.2li:%.2li", (long)timeComps.hours, (long)timeComps.minutes, (long)timeComps.seconds];
        [_recordingTimeBtn setTitle:strTime forState:UIControlStateNormal];
        
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
    
    BOOL lowBattery = NO;
    lowBattery = lowBattery || (deviceBatteryLevel > -1 && deviceBatteryLevel < BATTERY_LOW_LEVEL);
    lowBattery = lowBattery || (baseBatteryLevel > -1 && baseBatteryLevel < BATTERY_LOW_LEVEL);
    lowBattery = lowBattery || (markerBatteryLevel > -1 && markerBatteryLevel < BATTERY_LOW_LEVEL);
    
    _batteryLevelImg.hidden = !lowBattery;
}

- (void)finishObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_timelapseSettings removeObserver:self forKeyPath:@"distance"];
    [_timelapseSettings removeObserver:self forKeyPath:@"stepSize"];
    [_timelapseSettings removeObserver:self forKeyPath:@"timeBetweenPictures"];
    [_timelapseSettings removeObserver:self forKeyPath:@"recordingTime"];
    [_timelapseSettings removeObserver:self forKeyPath:@"clockwiseDirection"];
    
    [_observeBatteryLevelTimer invalidate];
}

#pragma Saving

- (void)saveSettings
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_timelapseSettings];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SW_TIMELAPSE_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveScript:(SWScript *)script
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:script];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SW_SCRIPT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreSettings
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SW_SCRIPT_KEY];
    SWScript *script = (SWScript *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (script && ![script isFinished]) {
        _timelapseSettings = script.timelapseSettings;
        //TO DO: show progress
    } else {
        data = [[NSUserDefaults standardUserDefaults] objectForKey:SW_TIMELAPSE_SETTINGS_KEY];
        _timelapseSettings = (SWTimelapseSettings *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (!_timelapseSettings) {
            _timelapseSettings = [[SWTimelapseSettings alloc] init];
        }
    }
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
