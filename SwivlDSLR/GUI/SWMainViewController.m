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

@interface SWMainViewController ()
{
    __weak IBOutlet UIButton *_distanceBtn;
    __weak IBOutlet UIButton *_directionBtn;
    __weak IBOutlet UIButton *_stepSizeBtn;
    __weak IBOutlet UIButton *_recordingTimeBtn;
    __weak IBOutlet UIButton *_timeBetweenPicturesBtn;
	SWTimelapseSettings *_timelapseSettings;
    UIViewController *_showingController;
}
@end

@implementation SWMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configUI];
    
    _timelapseSettings = [[SWTimelapseSettings alloc] init];
    [self startObserveTimelapseSettings];
}

- (void)configUI
{
    _stepSizeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _distanceBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _recordingTimeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _timeBetweenPicturesBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
}

#pragma IBActions

- (IBAction)onDistanceBtnTapped
{

}

- (IBAction)onDirectionBtnTapped
{
    _directionBtn.selected = !_directionBtn.selected;
    _timelapseSettings.clockwiseDirection = !_directionBtn.selected;
}

- (IBAction)onStepSizeBtnTapped
{
    
}

- (IBAction)onRecordingBtnTapped
{
    
}

- (IBAction)onTimeBetweenPicturesBtnTapped
{
    
}

#pragma mark - Storyboard navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [_showingController removeFromParentViewController];
    NSLog(@"Remove controller from screen = %@", NSStringFromClass([_showingController class]));
    _showingController = segue.destinationViewController;
    NSLog(@"Add controller to screen = %@", NSStringFromClass([_showingController class]));
}

#pragma Observing

- (void)startObserveTimelapseSettings
{
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
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _timelapseSettings) {
        
        [_distanceBtn setTitle:[NSString stringWithFormat:@"%i", _timelapseSettings.distance]
                      forState:UIControlStateNormal];
        
        [_stepSizeBtn setTitle:[NSString stringWithFormat:@"%i", _timelapseSettings.stepSize]
                      forState:UIControlStateNormal];
        
        [_timeBetweenPicturesBtn setTitle:[NSString stringWithFormat:@"%.0f", _timelapseSettings.timeBetweenPictures]
                                 forState:UIControlStateNormal];
        
        NSDateComponents *dateComps = _timelapseSettings.recordingTime;
        NSString *strTime = [NSString stringWithFormat:@"%.2i:%.2i:%.2i", dateComps.hour, dateComps.minute, dateComps.second];
        [_recordingTimeBtn setTitle:strTime
                           forState:UIControlStateNormal];
    }
}

- (void)finishObserving
{
    [_timelapseSettings removeObserver:self forKeyPath:@"distance"];
    [_timelapseSettings removeObserver:self forKeyPath:@"stepSize"];
    [_timelapseSettings removeObserver:self forKeyPath:@"timeBetweenPictures"];
    [_timelapseSettings removeObserver:self forKeyPath:@"recordingTime"];
}

#pragma -

- (void)dealloc
{
    [self finishObserving];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
