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
    
    NSArray *_timeComponentsKeys;
    NSMutableDictionary *_recordingTimeRanges;
    NSMutableDictionary *_timeBtwnPicturesRanges;
}
@end

@implementation SWTimeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _timeComponentsKeys = @[@"hours", @"minutes", @"seconds"];

    if (_recordingTimePicker) {
        [self setupRecordingTimePicker:NO];
    }
    
    if (_timeBtwnPicturesPicker) {
        [self setupTimeBtwnPicturesPicker:NO];
    }
}

- (void)setupRecordingTimePicker:(BOOL)animated
{
    _recordingTimeRanges = [[SWTimelapseSettings timeRanges] mutableCopy];

    [self setupPicker:_recordingTimePicker
       withTimeRanges:_recordingTimeRanges
        timeComponets:[_timelapseSettings recordingTimeComponents]
             animates:animated];
}

- (void)setupTimeBtwnPicturesPicker:(BOOL)animated
{
    _timeBtwnPicturesRanges = [[SWTimelapseSettings timeRanges] mutableCopy];

    [self setupPicker:_timeBtwnPicturesPicker
       withTimeRanges:_timeBtwnPicturesRanges
        timeComponets:[_timelapseSettings timeBetweenPicturesComponents]
             animates:animated];
}

- (void)setupPicker:(UIPickerView *)picker
     withTimeRanges:(NSMutableDictionary *)timeRages
      timeComponets:(SWTimeComponents)timeComps
           animates:(BOOL)animated
{
    NSMutableArray *hoursRange = [timeRages[@"hours"] mutableCopy];
    NSNumber *hours = [NSNumber numberWithInteger:timeComps.hours];
    NSInteger index = [hoursRange indexOfObject:hours];
    if (index == NSNotFound) {
        index = [self indexForNewTime:hours inTimeRange:hoursRange];
        [hoursRange insertObject:hours atIndex:index];
        [timeRages setObject:hoursRange forKey:@"hours"];
        [picker reloadComponent:0];
    }
    [picker selectRow:index inComponent:0 animated:animated];
    
    NSMutableArray *minutesRange = [timeRages[@"minutes"] mutableCopy];
    NSNumber *minutes = [NSNumber numberWithInteger:timeComps.minutes];
    index = [minutesRange indexOfObject:minutes];
    if (index == NSNotFound) {
        index = [self indexForNewTime:minutes inTimeRange:minutesRange];
        [minutesRange insertObject:minutes atIndex:index];
        [timeRages setObject:minutesRange forKey:@"minutes"];
        [picker reloadComponent:1];
    }
    [picker selectRow:index inComponent:1 animated:animated];

    NSMutableArray *secondsRange = [timeRages[@"seconds"] mutableCopy];
    NSNumber *seconds = [NSNumber numberWithFloat:timeComps.seconds];
    index = [secondsRange indexOfObject:seconds];
    if (index == NSNotFound) {
        index = [self indexForNewTime:seconds inTimeRange:secondsRange];
        [secondsRange insertObject:seconds atIndex:index];
        [timeRages setObject:secondsRange forKey:@"seconds"];
        [picker reloadComponent:2];
    }
    [picker selectRow:index inComponent:2 animated:animated];
}

- (NSUInteger)indexForNewTime:(NSNumber *)newTime inTimeRange:(NSArray *)timeRange
{
    return [timeRange indexOfObject:newTime
                      inSortedRange:NSMakeRange(0, timeRange.count)
                            options:NSBinarySearchingInsertionIndex
                    usingComparator:^(NSNumber *n1, NSNumber *n2) {
                        if (n1.floatValue > n2.floatValue) {
                            return NSOrderedDescending;
                          } else if (n1.floatValue < n2.floatValue) {
                              return NSOrderedAscending;
                          }
                          return NSOrderedSame;
                      }
             ];
}

#pragma mark UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return _timeComponentsKeys.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSString *componentKey = _timeComponentsKeys[component];

    if (pickerView == _recordingTimePicker) {
        return [_recordingTimeRanges[componentKey] count];
    } else {
        return [_timeBtwnPicturesRanges[componentKey] count];
    }
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *componentKey = _timeComponentsKeys[component];
    NSString *title;

    if (pickerView == _recordingTimePicker) {
        NSNumber *number = [_recordingTimeRanges[componentKey] objectAtIndex:row];
        title = number.stringValue;
    } else {
        NSNumber *number = [_timeBtwnPicturesRanges[componentKey] objectAtIndex:row];
        if ([componentKey isEqualToString:@"seconds"]) {
            title = [NSString stringWithFormat:@"%.2f", number.floatValue];
        } else {
            title = number.stringValue;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:title
                                           attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *componentKey = _timeComponentsKeys[component];
    SWTimeComponents timeComponents;
    NSString *selectedValue;
    
    if (pickerView == _recordingTimePicker) {
        timeComponents = [_timelapseSettings recordingTimeComponents];
        selectedValue = [_recordingTimeRanges[componentKey] objectAtIndex:row];
    } else {
        timeComponents = [_timelapseSettings timeBetweenPicturesComponents];
        selectedValue = [_timeBtwnPicturesRanges[componentKey] objectAtIndex:row];
    }
    
    if ([componentKey isEqualToString:@"hours"]) {
        timeComponents.hours = [selectedValue integerValue];
    } else if ([componentKey isEqualToString:@"minutes"]) {
        timeComponents.minutes = [selectedValue integerValue];
    } else if ([componentKey isEqualToString:@"seconds"]) {
        timeComponents.seconds = [selectedValue floatValue];
    }

    if (pickerView == _recordingTimePicker) {
        [_timelapseSettings setRecordingTimeWithComponents:timeComponents];
        if (_timeBtwnPicturesPicker) {
            [self setupTimeBtwnPicturesPicker:YES];
        }
    } else {
        [_timelapseSettings setTimeBetweenPicturesWithComponents:timeComponents];
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
