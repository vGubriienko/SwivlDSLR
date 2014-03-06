//
//  SWRecordingTimeController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/6/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWRecordingTimeController.h"

#import "SWTimelapseSettings.h"

@interface SWRecordingTimeController ()
{
    __weak IBOutlet UIPickerView *_pickerView;
    
    NSArray *_components;
    NSDictionary *_availableTime;
    SWTimelapseSettings *_timelapseSettings;
}
@end

@implementation SWRecordingTimeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _components = @[@"hours", @"minutes", @"seconds"];
    
    _availableTime = [SWTimelapseSettings availableRecordingTime];
    
    NSInteger index = [_availableTime[@"hours"] indexOfObject:[NSString stringWithFormat:@"%i", _timelapseSettings.recordingTime.hour]];
    if (index != NSNotFound) {
        [_pickerView selectRow:index inComponent:0 animated:NO];
    }
    
    index = [_availableTime[@"minutes"] indexOfObject:[NSString stringWithFormat:@"%i", _timelapseSettings.recordingTime.minute]];
    if (index != NSNotFound) {
        [_pickerView selectRow:index inComponent:1 animated:NO];
    }
    
    index = [_availableTime[@"seconds"] indexOfObject:[NSString stringWithFormat:@"%i", _timelapseSettings.recordingTime.second]];
    if (index != NSNotFound) {
        [_pickerView selectRow:index inComponent:2 animated:NO];
    }
}

#pragma TimelapsSegueNavigation

- (void)setTimelapseSettings:(SWTimelapseSettings *)timelapseSettings
{
    _timelapseSettings = timelapseSettings;
}

#pragma mark UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSString *componentKey = _components[component];
    return [_availableTime[componentKey] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *componentKey = _components[component];
    return [_availableTime[componentKey] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *componentKey = _components[component];
    NSString *selectedValue = [_availableTime[componentKey] objectAtIndex:row];
    
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
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
