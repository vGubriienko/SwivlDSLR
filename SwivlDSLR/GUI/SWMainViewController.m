//
//  SWMainViewController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWMainViewController.h"

#import "TimelapsSegue.h"
#import "SWTimelapseSettings.h"

#import <Swivl2Lib/SwivlCommonLib.h>

@interface SWMainViewController ()
{
    __weak IBOutlet UIButton *_distanceBtn;
    __weak IBOutlet UIButton *_directionBtn;
    __weak IBOutlet UIButton *_stepSizeBtn;
    __weak IBOutlet UIButton *_recordingTimeBtn;
    __weak IBOutlet UIButton *_timeBetweenPicturesBtn;
    __weak IBOutlet UIImageView *_batteryLevelImg;
    __weak IBOutlet UIImageView *_swivlStatusImg;

    SwivlCommonLib *_swivl;
    NSTimer *_observeBatteryLevelTimer;
    
    SWTimelapseSettings *_timelapseSettings;
    
    UIViewController <TimelapsSegueNavigation> *_currentSettingsController;
}
@end

@implementation SWMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configUI];
    
    _swivl = [SwivlCommonLib sharedSwivlBaseForDelegate:nil];
    
    _timelapseSettings = [[SWTimelapseSettings alloc] init];
    
    [self startObserving];
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
    _directionBtn.selected = !_directionBtn.selected;
    _timelapseSettings.clockwiseDirection = !_directionBtn.selected;
}

- (IBAction)onMenuBtnTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SW_NEED_SHOW_SIDE_BAR_NOTIFICATION object:nil];
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
    
    _observeBatteryLevelTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                 target:self
                                                               selector:@selector(updateBatteryLevel)
                                                               userInfo:nil
                                                                repeats:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _timelapseSettings) {
        
        [_distanceBtn setTitle:[NSString stringWithFormat:@"%li", (long)_timelapseSettings.distance]
                      forState:UIControlStateNormal];
        
        [_stepSizeBtn setTitle:[NSString stringWithFormat:@"%.2f", _timelapseSettings.stepSize]
                      forState:UIControlStateNormal];
        
        [_timeBetweenPicturesBtn setTitle:[NSString stringWithFormat:@"%.1f", _timelapseSettings.timeBetweenPictures]
                                 forState:UIControlStateNormal];
        
        NSDateComponents *dateComps = _timelapseSettings.recordingTime;
        NSString *strTime = [NSString stringWithFormat:@"%.2li:%.2li:%.2li", (long)dateComps.hour, (long)dateComps.minute, (long)dateComps.second];
        [_recordingTimeBtn setTitle:strTime
                           forState:UIControlStateNormal];
    }
}

- (void)accessoryStateChanged
{
    _swivlStatusImg.highlighted = _swivl.swivlConnected;
}

- (void)updateBatteryLevel
{
    CGFloat deviceBatteryLevel = [UIDevice currentDevice].batteryLevel;
    if (deviceBatteryLevel > 0) {
        deviceBatteryLevel *= 100;
    }
    
    NSInteger markerBatteryLevel = _swivl.markerBatteryLevel;
    NSInteger baseBatteryLevel = _swivl.baseBatteryLevel;
    
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
    
    [_observeBatteryLevelTimer invalidate];
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
