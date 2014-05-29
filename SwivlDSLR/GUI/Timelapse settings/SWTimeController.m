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
    __weak IBOutlet UILabel *_recordingTimeLabel;

    NSArray *_timeComponentsKeys;
    NSDictionary *_timeRanges;
}
@end

@implementation SWTimeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _timeRanges = [SWTimelapseSettings timeRanges];
    _timeComponentsKeys = @[@"hours", @"minutes", @"seconds"];

    [self setupTimePicker:NO];
    
    [self reloadRecordingTimeLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
    [super viewDidAppear:animated];
}

- (void)setupTimePicker:(BOOL)animated
{
    NSMutableArray *hoursRange = [_timeRanges[@"hours"] mutableCopy];
    NSNumber *hours = [NSNumber numberWithInteger:_timelapseSettings.timeBetweenPicturesComponents.hours];
    NSInteger index = [hoursRange indexOfObject:hours];
    [_timePicker selectRow:index inComponent:0 animated:animated];
    
    NSMutableArray *minutesRange = [_timeRanges[@"minutes"] mutableCopy];
    NSNumber *minutes = [NSNumber numberWithInteger:_timelapseSettings.timeBetweenPicturesComponents.minutes];
    index = [minutesRange indexOfObject:minutes];
    [_timePicker selectRow:index inComponent:1 animated:animated];
    
    NSMutableArray *secondsRange = [_timeRanges[@"seconds"] mutableCopy];
    NSNumber *seconds = [NSNumber numberWithInteger:_timelapseSettings.timeBetweenPicturesComponents.seconds];
    index = [secondsRange indexOfObject:seconds];
    [_timePicker selectRow:index inComponent:2 animated:animated];
}

#pragma mark UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return _timeComponentsKeys.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSString *componentKey = _timeComponentsKeys[component];
    return [_timeRanges[componentKey] count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *componentKey = _timeComponentsKeys[component];
    NSNumber *number = [_timeRanges[componentKey] objectAtIndex:row];
    NSString *title = number.stringValue;
   
    return [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *componentKey = _timeComponentsKeys[component];
    SWTimeComponents timeComponents = [_timelapseSettings timeBetweenPicturesComponents];
    NSString *selectedValue = [_timeRanges[componentKey] objectAtIndex:row];
    
    if ([componentKey isEqualToString:@"hours"]) {
        timeComponents.hours = [selectedValue integerValue];
    } else if ([componentKey isEqualToString:@"minutes"]) {
        timeComponents.minutes = [selectedValue integerValue];
    } else if ([componentKey isEqualToString:@"seconds"]) {
        timeComponents.seconds = [selectedValue integerValue];
    }

    [_timelapseSettings setTimeBetweenPicturesWithComponents:timeComponents];
    
    [self reloadRecordingTimeLabel];
}

- (void)reloadRecordingTimeLabel
{
    SWTimeComponents recordingTimeComps = [_timelapseSettings recordingTimeComponents];
    NSString *strTime = [NSString stringWithFormat:@"Recording Time: %.2li:%.2li:%.2li", (long)recordingTimeComps.hours, (long)recordingTimeComps.minutes, (long)recordingTimeComps.seconds];
    _recordingTimeLabel.text = strTime;
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
