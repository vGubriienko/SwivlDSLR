//
//  SWTimeController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/6/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWTimeController.h"

#import "SWTimelapseSettings.h"

@interface SWTimeController ()
{
    __weak IBOutlet UIPickerView *_recordingTimePicker;
    __weak IBOutlet UIPickerView *_timeBtwnPicturesPicker;
    
    NSArray *_recordingTimeComponents;
    NSDictionary *_availableRecordingTime;
    
    NSArray *_availableTimesBtwnPictures;
}
@end

@implementation SWTimeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_recordingTimePicker) {
        
        _recordingTimeComponents = @[@"hours", @"minutes", @"seconds"];
        _availableRecordingTime = [SWTimelapseSettings availableRecordingTime];
        
        [self setupRecordingTimePicker:NO];
    }
    
    if (_timeBtwnPicturesPicker) {
        
        _availableTimesBtwnPictures = [SWTimelapseSettings availableTimesBtwnPictures];

        [self setupTimeBtwnPicturesPicker:NO];
    }
}

- (void)setupRecordingTimePicker:(BOOL)animated
{
    NSInteger index = [_availableRecordingTime[@"hours"] indexOfObject:[NSNumber numberWithInteger:_timelapseSettings.recordingTime.hour]];
    if (index != NSNotFound) {
        [_recordingTimePicker selectRow:index inComponent:0 animated:animated];
    }
    
    index = [_availableRecordingTime[@"minutes"] indexOfObject:[NSNumber numberWithInteger:_timelapseSettings.recordingTime.minute]];
    if (index != NSNotFound) {
        [_recordingTimePicker selectRow:index inComponent:1 animated:animated];
    }
    
    index = [_availableRecordingTime[@"seconds"] indexOfObject:[NSNumber numberWithInteger:_timelapseSettings.recordingTime.second]];
    if (index != NSNotFound) {
        [_recordingTimePicker selectRow:index inComponent:2 animated:animated];
    }
}

- (void)setupTimeBtwnPicturesPicker:(BOOL)animated
{
    NSInteger index = [_availableTimesBtwnPictures indexOfObject:[NSNumber numberWithFloat: _timelapseSettings.timeBetweenPictures]];
    if (index != NSNotFound) {
        [_timeBtwnPicturesPicker selectRow:index inComponent:0 animated:animated];
    }
}

#pragma mark UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == _recordingTimePicker) {
        return 3;
    } else {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _recordingTimePicker) {
        NSString *componentKey = _recordingTimeComponents[component];
        return [_availableRecordingTime[componentKey] count];
    } else {
        return _availableTimesBtwnPictures.count;
    }
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSNumber *value;
    if (pickerView == _recordingTimePicker) {
        NSString *componentKey = _recordingTimeComponents[component];
        value = [_availableRecordingTime[componentKey] objectAtIndex:row];
    } else {
        value = _availableTimesBtwnPictures[row];
    }
    
    NSString *title = value.stringValue;
    return [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == _recordingTimePicker) {
        NSString *componentKey = _recordingTimeComponents[component];
        NSString *selectedValue = [_availableRecordingTime[componentKey] objectAtIndex:row];
        
        NSDateComponents *newRecordingTime = [[NSDateComponents alloc] init];
        newRecordingTime.hour = _timelapseSettings.recordingTime.hour;
        newRecordingTime.minute = _timelapseSettings.recordingTime.minute;
        newRecordingTime.second = _timelapseSettings.recordingTime.second;
        
        if ([componentKey isEqualToString:@"hours"]) {
            newRecordingTime.hour = [selectedValue integerValue];
        } else if ([componentKey isEqualToString:@"minutes"]) {
            newRecordingTime.minute = [selectedValue integerValue];
        } else if ([componentKey isEqualToString:@"seconds"]) {
            newRecordingTime.second = [selectedValue integerValue];
        }
        
        _timelapseSettings.recordingTime = newRecordingTime;
        
        if (_timeBtwnPicturesPicker) {
            [self setupTimeBtwnPicturesPicker:YES];
        }
    } else {
        _timelapseSettings.timeBetweenPictures = [_availableTimesBtwnPictures[row] floatValue];
        
        if (_recordingTimePicker) {
            [self setupRecordingTimePicker:YES];
        }
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
