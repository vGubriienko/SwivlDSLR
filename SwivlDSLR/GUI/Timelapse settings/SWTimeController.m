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

typedef NS_ENUM(NSInteger, SWTimeComponent)
{
    SWTimeComponentHour,
    SWTimeComponentMinute,
    SWTimeComponentSecond,
};

@interface SWTimeController ()
{
    __weak IBOutlet UIPickerView *_timePicker;
    __weak IBOutlet UIPickerView *_exposurePicker;
    __weak IBOutlet UILabel *_recordingTimeLabel;

    SWTimeComponents _minTimeComponents;
    SWTimeComponents _maxTimeComponents;
    NSMutableArray *_hoursRange;
    NSMutableArray *_minutesRange;
    NSMutableArray *_secondsRangeFull;
    NSMutableArray *_secondsRangeMin;
    NSMutableArray *_exposureRange;
}
@end

@implementation SWTimeController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _minTimeComponents = SWTimeComponentsMake(_timelapseSettings.minimumTimeBetweenPictures);
    _maxTimeComponents = SWTimeComponentsMake(SW_TIMELAPSE_MAX_TIME_BTWN_PICTURES);

    [self setupTimeRanges];
    [self setupTimePicker:NO];
    [self setupExposurePicker:NO];

    [self reloadRecordingTimeLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
    [super viewDidAppear:animated];
}

- (void)setupTimeRanges
{
    _hoursRange = [NSMutableArray new];
    for (NSTimeInterval i = 0.0; i <= _maxTimeComponents.hours; i++) {
        [_hoursRange addObject:@(i)];
    }
    _minutesRange = [NSMutableArray new];
    for (NSTimeInterval i = 0.0; i <= _maxTimeComponents.minutes; i++) {
        [_minutesRange addObject:@(i)];
    }
    _secondsRangeFull = [NSMutableArray new];
    for (NSTimeInterval i = 0.0; i <= _maxTimeComponents.seconds; i++) {
        [_secondsRangeFull addObject:@(i)];
    }
    _secondsRangeMin = [NSMutableArray new];
    if ([self hasTimeDecimalPart:_timelapseSettings.minimumTimeBetweenPictures]) {
        [_secondsRangeMin addObject:@(_timelapseSettings.minimumTimeBetweenPictures)];
    }
    for (NSTimeInterval i = ceil(_timelapseSettings.minimumTimeBetweenPictures); i <= _maxTimeComponents.seconds; i++) {
        [_secondsRangeMin addObject:@(i)];
    }
    _exposureRange = [NSMutableArray new];
    if ([self hasTimeDecimalPart:_timelapseSettings.minimumExposure]) {
        [_exposureRange addObject:@(_timelapseSettings.minimumExposure)];
    }
    for (NSTimeInterval i = ceil(_timelapseSettings.minimumExposure); i <= SW_TIMELAPSE_MAX_EXPOSURE; i++) {
        [_exposureRange addObject:@(i)];
    }
}

- (void)setupTimePicker:(BOOL)animated
{
    NSNumber *hours = [NSNumber numberWithInteger:_timelapseSettings.timeBetweenPicturesComponents.hours];
    NSInteger index = [_hoursRange indexOfObject:hours];
    index = (index == NSNotFound) ? 0 : index;
    [_timePicker selectRow:index inComponent:0 animated:animated];
    
    NSNumber *minutes = [NSNumber numberWithInteger:_timelapseSettings.timeBetweenPicturesComponents.minutes];
    index = [_minutesRange indexOfObject:minutes];
    index = (index == NSNotFound) ? 0 : index;
    [_timePicker selectRow:index inComponent:1 animated:animated];
    
    NSNumber *seconds = [NSNumber numberWithDouble:_timelapseSettings.timeBetweenPicturesComponents.seconds];
    index = [[self secondsRange] indexOfObject:seconds];
    index = (index == NSNotFound) ? 0 : index;
    [_timePicker selectRow:index inComponent:2 animated:animated];
}

- (void)setupExposurePicker:(BOOL)animated
{
    NSNumber *exposure = [NSNumber numberWithDouble:_timelapseSettings.exposure];
    NSInteger index = [_exposureRange indexOfObject:exposure];
    index = (index == NSNotFound) ? 0 : index;
    [_exposurePicker selectRow:index inComponent:0 animated:animated];
}

- (BOOL)hasTimeDecimalPart:(NSTimeInterval)time
{
    return fabs(_timelapseSettings.minimumExposure - (long)_timelapseSettings.minimumExposure) > DBL_EPSILON;
}

- (NSMutableArray *)secondsRange
{
    if (_timelapseSettings.timeBetweenPicturesComponents.minutes == 0 && _timelapseSettings.timeBetweenPicturesComponents.hours == 0) {
        return _secondsRangeMin;
    } else {
        return _secondsRangeFull;
    }
}

- (void)reloadSecondsPicker
{
    [_timePicker reloadComponent:2];
    NSNumber *seconds = [NSNumber numberWithDouble:_timelapseSettings.timeBetweenPicturesComponents.seconds];
    NSInteger index = [[self secondsRange] indexOfObject:seconds];
    index = (index == NSNotFound) ? 0 : index;
    [_timePicker selectRow:index inComponent:2 animated:NO];
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
        if (component == SWTimeComponentHour) {
            return _hoursRange.count;
        } else if (component == SWTimeComponentMinute) {
            return _minutesRange.count;
        } else if (component == SWTimeComponentSecond) {
            return [self secondsRange].count;
        }
    } else if (pickerView == _exposurePicker) {
        return _exposureRange.count;
    }
    
    return 0;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title;
    NSTimeInterval value = 0.0;
    
    if (pickerView == _timePicker) {
        if (component == SWTimeComponentHour) {
            value = [_hoursRange[row] doubleValue];
        } else if (component == SWTimeComponentMinute) {
            value = [_minutesRange[row] doubleValue];
        } else if (component == SWTimeComponentSecond) {
            value = [[self secondsRange][row] doubleValue];
        }
    } else if (pickerView == _exposurePicker) {
        value = [_exposureRange[row] doubleValue];
    }
    title = [NSString stringWithFormat:@"%g", value];
    return [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == _timePicker) {
        SWTimeComponents timeComponents = [_timelapseSettings timeBetweenPicturesComponents];
        
        if (component == SWTimeComponentHour) {
            timeComponents.hours = [_hoursRange[row] integerValue];
        } else if (component == SWTimeComponentMinute) {
            timeComponents.minutes = [_minutesRange[row] integerValue];
        } else if (component == SWTimeComponentSecond) {
            timeComponents.seconds = [[self secondsRange][row] doubleValue];
        }
        
        if (timeComponents.hours == 0 && timeComponents.minutes == 0 && timeComponents.seconds <= _timelapseSettings.minimumTimeBetweenPictures) {
            timeComponents.seconds = _timelapseSettings.minimumTimeBetweenPictures;
        }
        
        [_timelapseSettings setTimeBetweenPicturesWithComponents:timeComponents];
        
        [self reloadSecondsPicker];
        [self setupExposurePicker:YES];
    } else {
        _timelapseSettings.exposure = [_exposureRange[row] doubleValue];
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
