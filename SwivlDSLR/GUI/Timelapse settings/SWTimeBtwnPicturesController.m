//
//  SWTimeBtwnPicturesController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/6/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWTimeBtwnPicturesController.h"

#import "SWTimelapseSettings.h"

@interface SWTimeBtwnPicturesController ()
{
    __weak IBOutlet UIPickerView *_pickerView;
    
    NSArray *_availableTimes;
    SWTimelapseSettings *_timelapseSettings;
}
@end

@implementation SWTimeBtwnPicturesController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _availableTimes = [SWTimelapseSettings availableTimesBtwnPictures];
    
    NSInteger index = [_availableTimes indexOfObject:[NSString stringWithFormat:@"%.1f", _timelapseSettings.timeBetweenPictures]];
    if (index != NSNotFound) {
        [_pickerView selectRow:index inComponent:0 animated:NO];
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
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _availableTimes.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _availableTimes[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _timelapseSettings.timeBetweenPictures = [_availableTimes[row] floatValue];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
