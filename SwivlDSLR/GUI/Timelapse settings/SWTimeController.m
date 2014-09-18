//
//  SWTimeController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/6/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWTimeController.h"

#import "SWTimelapseSettings.h"

#import "Countly.h"

@interface SWTimeController ()
{
    __weak IBOutlet UIPickerView *_timePicker;
    __weak IBOutlet UIPickerView *_exposurePicker;
    __weak IBOutlet UILabel *_recordingTimeLabel;

    SWTimeComponents _minTimeComponents;
    SWTimeComponents _maxTimeComponents;
}
@end

@implementation SWTimeController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _minTimeComponents = SWTimeComponentsMake(SW_TIMELAPSE_MIN_TIME_BTWN_PICTURES);
    _maxTimeComponents = SWTimeComponentsMake(SW_TIMELAPSE_MAX_TIME_BTWN_PICTURES);

    [self setupTimePicker:NO];
    [self setupExposurePicker:NO];

    [self reloadRecordingTimeLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
    [super viewDidAppear:animated];
}

- (void)setupTimePicker:(BOOL)animated
{
    [_timePicker selectRow:_timelapseSettings.timeBetweenPicturesComponents.hours - _minTimeComponents.hours inComponent:0 animated:animated];
    [_timePicker selectRow:_timelapseSettings.timeBetweenPicturesComponents.minutes - _minTimeComponents.minutes inComponent:1 animated:animated];
    [_timePicker selectRow:_timelapseSettings.timeBetweenPicturesComponents.seconds - _minTimeComponents.seconds inComponent:2 animated:animated];
}

- (void)setupExposurePicker:(BOOL)animated
{
    [_exposurePicker selectRow:_timelapseSettings.exposure - SW_TIMELAPSE_MIN_EXPOSURE inComponent:0 animated:animated];
}

#pragma mark UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == _timePicker) {
        return 3;
    } else if (pickerView == _exposurePicker) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _timePicker) {
        if (component == 0) {
            return _maxTimeComponents.hours - _minTimeComponents.hours + 1;
        } else if (component == 1) {
            return _maxTimeComponents.minutes - _minTimeComponents.minutes + 1;
        } else if (component == 2) {
            return _maxTimeComponents.seconds - _minTimeComponents.seconds + 1;
        }
    } else if (pickerView == _exposurePicker) {
        return SW_TIMELAPSE_MAX_EXPOSURE - SW_TIMELAPSE_MIN_EXPOSURE + 1;
    }
    
    return 0;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title;
    NSInteger value = 0;
    
    if (pickerView == _timePicker) {
        if (component == 0) {
            value = row + _minTimeComponents.hours;
        } else if (component == 1) {
            value = row + _minTimeComponents.minutes;
        } else if (component == 2) {
            value = row + _minTimeComponents.seconds;
        }
        title = [NSString stringWithFormat:@"%li", (long)value];
    } else if (pickerView == _exposurePicker) {
        value = row + SW_TIMELAPSE_MIN_EXPOSURE;
        if (value == SW_TIMELAPSE_MIN_EXPOSURE) {
            title = [NSString stringWithFormat:@"<=%li", (long)value];
        } else {
            title = [NSString stringWithFormat:@"%li", (long)value];
        }
    }
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == _timePicker) {
        SWTimeComponents timeComponents = [_timelapseSettings timeBetweenPicturesComponents];
        
        if (component == 0) {
            timeComponents.hours = row + _minTimeComponents.hours;
        } else if (component == 1) {
            timeComponents.minutes = row + _minTimeComponents.minutes;
        } else if (component == 2) {
            timeComponents.seconds = row + _minTimeComponents.seconds;
        }
        
        [_timelapseSettings setTimeBetweenPicturesWithComponents:timeComponents];
        [self setupExposurePicker:YES];
    } else {
        _timelapseSettings.exposure = row + SW_TIMELAPSE_MIN_EXPOSURE;
        [self setupTimePicker:YES];
    }
    
    [self reloadRecordingTimeLabel];
}

- (void)reloadRecordingTimeLabel
{
    SWTimeComponents recordingTimeComps = [_timelapseSettings recordingTimeComponents];
    NSString *strTime = [NSString stringWithFormat:@"Recording Time: %.2li:%.2li:%.2li", (long)recordingTimeComps.hours, (long)recordingTimeComps.minutes, (long)recordingTimeComps.seconds];
    _recordingTimeLabel.text = strTime;
}

@end
