//
//  SWDegreesController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/6/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWDegreesController.h"

#import "DKCircularSlider.h"

#import "SWTimelapseSettings.h"
#import "Countly.h"

@interface SWDegreesController ()
{
    __weak IBOutlet UIView *_stepsContainer;
    __weak IBOutlet UIView *_stepSizeContainer;
    
    DKCircularSlider *_stepsSlider;
    DKCircularSlider *_stepSizeSlider;
    
    NSArray *_stepSizes;
}
@end

@implementation SWDegreesController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_stepsContainer) {
        [self initStepsSlider];
    }
    
    if (_stepSizeContainer) {
        [self initStepSizeSlider];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
    [super viewDidAppear:animated];
}

- (void)initStepsSlider
{
    _stepsSlider = [[DKCircularSlider alloc] initWithFrame:_stepsContainer.bounds
                                                     usingMax:SW_TIMELAPSE_MAX_STEPCOUNT
                                                     usingMin:SW_TIMELAPSE_MIN_STEPCOUNT
                                             withContentImage:nil
                                                    withTitle:nil
                                                   withTarget:self
                                                usingSelector:@selector(stepsCountSliderDidChange:)];
    [_stepsContainer addSubview:_stepsSlider];
    //Max is 360°
    _stepsSlider.maxValue =  (NSInteger)roundf(360 / self.timelapseSettings.stepSize);
    [_stepsSlider movehandleToValue:self.timelapseSettings.stepCount];
}

- (void)initStepSizeSlider
{
    _stepSizes = [SWTimelapseSettings availableStepSizes];
    NSMutableArray *elements = [@[] mutableCopy];
    [_stepSizes enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        [elements addObject:[obj stringValue]];
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

#pragma mark - DKCircularSlider

- (void)stepsCountSliderDidChange:(DKCircularSlider *)stepsSlider
{
    if (self.timelapseSettings.stepCount == stepsSlider.currentValue) {
        return;
    }
    self.timelapseSettings.stepCount = stepsSlider.currentValue;
    if (_stepSizeSlider) {
        [self selectCurrentStepSize];
    }
}

- (void)stepSizeSliderDidChange:(DKCircularSlider *)stepSizeSlider
{
    if (stepSizeSlider.currentValue == 0) {
        return;
    }
    
    CGFloat value = [_stepSizes[stepSizeSlider.currentValue - 1] floatValue];
    if (self.timelapseSettings.stepSize != value) {
        self.timelapseSettings.stepSize = value;
        if (_stepsSlider) {
            _stepsSlider.maxValue =  (NSInteger)roundf(360 / self.timelapseSettings.stepSize);
            [_stepsSlider movehandleToValue:self.timelapseSettings.stepCount];
        };
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
