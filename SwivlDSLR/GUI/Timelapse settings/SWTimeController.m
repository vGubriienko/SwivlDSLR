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
    __weak IBOutlet UIPickerView *_recordingTimePicker;
    
    NSArray *_timeComponentsKeys;
    NSDictionary *_recordingTimeRanges;
}
@end

@implementation SWTimeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _recordingTimeRanges = [SWTimelapseSettings timeRanges];
    _timeComponentsKeys = @[@"hours", @"minutes", @"seconds"];

    [self setupRecordingTimePicker:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
    [super viewDidAppear:animated];
}

- (void)setupRecordingTimePicker:(BOOL)animated
{
    NSMutableArray *hoursRange = [_recordingTimeRanges[@"hours"] mutableCopy];
    NSNumber *hours = [NSNumber numberWithInteger:_timelapseSettings.recordingTimeComponents.hours];
    NSInteger index = [hoursRange indexOfObject:hours];
    [_recordingTimePicker selectRow:index inComponent:0 animated:animated];
    
    NSMutableArray *minutesRange = [_recordingTimeRanges[@"minutes"] mutableCopy];
    NSNumber *minutes = [NSNumber numberWithInteger:_timelapseSettings.recordingTimeComponents.minutes];
    index = [minutesRange indexOfObject:minutes];
    [_recordingTimePicker selectRow:index inComponent:1 animated:animated];
    
    NSMutableArray *secondsRange = [_recordingTimeRanges[@"seconds"] mutableCopy];
    NSNumber *seconds = [NSNumber numberWithFloat:_timelapseSettings.recordingTimeComponents.seconds];
    index = [secondsRange indexOfObject:seconds];
    [_recordingTimePicker selectRow:index inComponent:2 animated:animated];
}

#pragma mark UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return _timeComponentsKeys.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSString *componentKey = _timeComponentsKeys[component];
    return [_recordingTimeRanges[componentKey] count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *componentKey = _timeComponentsKeys[component];
    NSNumber *number = [_recordingTimeRanges[componentKey] objectAtIndex:row];
    NSString *title = number.stringValue;
   
    return [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *componentKey = _timeComponentsKeys[component];
    SWTimeComponents timeComponents = [_timelapseSettings recordingTimeComponents];
    NSString *selectedValue = [_recordingTimeRanges[componentKey] objectAtIndex:row];
    
    if ([componentKey isEqualToString:@"hours"]) {
        timeComponents.hours = [selectedValue integerValue];
    } else if ([componentKey isEqualToString:@"minutes"]) {
        timeComponents.minutes = [selectedValue integerValue];
    } else if ([componentKey isEqualToString:@"seconds"]) {
        timeComponents.seconds = [selectedValue floatValue];
    }

    [_timelapseSettings setRecordingTimeWithComponents:timeComponents];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
