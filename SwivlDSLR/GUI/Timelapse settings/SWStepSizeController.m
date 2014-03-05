//
//  SWStepSizeController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/5/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWStepSizeController.h"

#import "SWTimelapseSettings.h"

@interface SWStepSizeController ()
{
    __weak IBOutlet UIPickerView *_pickerView;
    
    NSArray *_availableStepSizes;
    SWTimelapseSettings *_timelapseSettings;
}
@end

@implementation SWStepSizeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _availableStepSizes = [SWTimelapseSettings availableStepSizes];
    
    NSInteger index = [_availableStepSizes indexOfObject:[NSString stringWithFormat:@"%i", _timelapseSettings.stepSize]];
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
    return _availableStepSizes.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _availableStepSizes[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _timelapseSettings.stepSize = [_availableStepSizes[row] integerValue];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
