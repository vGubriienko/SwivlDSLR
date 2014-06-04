//
//  SWTiltController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 5/19/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWTiltController.h"

#import "SWTimelapseSettings.h"

#import "Countly.h"

@interface SWTiltController ()
{
    __weak IBOutlet UISlider *_startTiltSlider;
    __weak IBOutlet UISlider *_endTiltSlider;
}
@end

@implementation SWTiltController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _startTiltSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _endTiltSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);

    _startTiltSlider.minimumValue = SW_TIMELAPSE_MIN_TILT;
    _startTiltSlider.maximumValue = SW_TIMELAPSE_MAX_TILT;
    
    _endTiltSlider.minimumValue = SW_TIMELAPSE_MIN_TILT;
    _endTiltSlider.maximumValue = SW_TIMELAPSE_MAX_TILT;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _startTiltSlider.value = self.timelapseSettings.startTiltAngle;
    _endTiltSlider.value = self.timelapseSettings.endTiltAngle;
    
    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
}

#pragma mark - IBActions

- (IBAction)onStartAngleValueChanged
{
    self.timelapseSettings.startTiltAngle = _startTiltSlider.value;
}

- (IBAction)onEndAngleValueChanged
{
    self.timelapseSettings.endTiltAngle = _endTiltSlider.value;
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
