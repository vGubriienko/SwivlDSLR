//
//  SWDegreesController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/6/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWStepsController.h"

#import "DKCircularSlider.h"

#import "SWTimelapseSettings.h"
#import "Countly.h"

@interface SWStepsController ()
{
    __weak IBOutlet UIView *_stepCountContainer;
    __weak IBOutlet UIView *_stepSizeContainer;
    __weak IBOutlet UILabel *_distanceLabel;

    DKCircularSlider *_stepCountSlider;
    DKCircularSlider *_stepSizeSlider;
    
    NSArray *_stepSizes;
}
@end

@implementation SWStepsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_stepCountContainer) {
        [self initStepsSlider];
    }
    
    if (_stepSizeContainer) {
        [self initStepSizeSlider];
    }
    
    [self reloadDistance];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
    [super viewDidAppear:animated];
}

- (void)initStepsSlider
{
    _stepCountSlider = [[DKCircularSlider alloc] initWithFrame:_stepCountContainer.bounds
                                                     usingMax:SW_TIMELAPSE_MAX_STEPCOUNT
                                                     usingMin:SW_TIMELAPSE_MIN_STEPCOUNT
                                             withContentImage:nil
                                                    withTitle:nil
                                                   withTarget:self
                                                usingSelector:@selector(stepsCountSliderDidChange:)];
    [_stepCountContainer addSubview:_stepCountSlider];
    [_stepCountSlider movehandleToValue:self.timelapseSettings.stepCount];
}

- (void)initStepSizeSlider
{
    _stepSizes = [SWTimelapseSettings availableStepSizes];
    NSMutableArray *elements = [@[] mutableCopy];
    [_stepSizes enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        CGFloat step = [obj floatValue];
        [elements addObject:[NSString stringWithFormat:@"%.2f", step]];
    }];
    
    _stepSizeSlider = [[DKCircularSlider alloc] initWithFrame:_stepSizeContainer.bounds
                                                 withElements:elements
                                             withContentImage:nil
                                                    withTitle:nil
                                                   withTarget:self
                                                usingSelector:@selector(stepSizeSliderDidChange:)];
    [_stepSizeContainer addSubview:_stepSizeSlider];
    [self selectCurrentStepSize];
}

- (void)selectCurrentStepSize
{
    NSInteger index = [_stepSizes indexOfObject:[NSNumber numberWithFloat:self.timelapseSettings.stepSize]];
    [_stepSizeSlider movehandleToValue:index + 1];
}

- (void)reloadDistance
{
    _distanceLabel.text = [NSString stringWithFormat:@"Total Distance: %li degrees", (long)self.timelapseSettings.distance];
}

#pragma mark - DKCircularSlider

- (void)stepsCountSliderDidChange:(DKCircularSlider *)stepsSlider
{
    if (self.timelapseSettings.stepCount == stepsSlider.currentValue) {
        return;
    }
    self.timelapseSettings.stepCount = stepsSlider.currentValue;
    [self reloadDistance];
}

- (void)stepSizeSliderDidChange:(DKCircularSlider *)stepSizeSlider
{
    if (stepSizeSlider.currentValue == 0) {
        return;
    }
    
    CGFloat value = [_stepSizes[stepSizeSlider.currentValue - 1] floatValue];
    if (self.timelapseSettings.stepSize != value) {
        self.timelapseSettings.stepSize = value;
        [self reloadDistance];
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
