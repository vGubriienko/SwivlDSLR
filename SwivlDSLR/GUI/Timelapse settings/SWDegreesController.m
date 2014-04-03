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
    __weak IBOutlet UIView *_distanceContainer;
    __weak IBOutlet UIView *_stepSizeContainer;
    
    DKCircularSlider *_distanceSlider;
    DKCircularSlider *_stepSizeSlider;
    
    NSArray *_stepSizes;
}
@end

@implementation SWDegreesController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_distanceContainer) {
        [self initDistanceSlider];
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

- (void)initDistanceSlider
{
    _distanceSlider = [[DKCircularSlider alloc] initWithFrame:_distanceContainer.bounds
                                                     usingMax:360
                                                     usingMin:1
                                             withContentImage:nil
                                                    withTitle:nil
                                                   withTarget:self
                                                usingSelector:@selector(distanceSliderDidChange:)];
    [_distanceContainer addSubview:_distanceSlider];
    [_distanceSlider movehandleToValue:self.timelapseSettings.distance];
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

- (void)distanceSliderDidChange:(DKCircularSlider *)distanceSlider
{
    if (self.timelapseSettings.distance == distanceSlider.currentValue) {
        return;
    }
    self.timelapseSettings.distance = distanceSlider.currentValue;
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
        if (_distanceSlider) {
            [_distanceSlider movehandleToValue:self.timelapseSettings.distance];
        };
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
