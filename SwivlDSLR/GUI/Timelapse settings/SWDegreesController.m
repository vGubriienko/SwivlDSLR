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

@interface SWDegreesController ()
{
    __weak IBOutlet UIView *_distanceContainer;
    __weak IBOutlet UIView *_stepSizeContainer;
    DKCircularSlider *_distanceSlider;
    DKCircularSlider *_stepSizeSlider;
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

- (void)initDistanceSlider
{
    _distanceSlider = [[DKCircularSlider alloc] initWithFrame:_distanceContainer.bounds
                                                                      usingMax:360
                                                                      usingMin:1
                                                              withContentImage:nil
                                                                     withTitle:@"degrees" withTarget:self usingSelector:@selector(distanceSliderDidChange:)];
    [_distanceContainer addSubview:_distanceSlider];
    [_distanceSlider movehandleToValue:self.timelapseSettings.distance];
}

- (void)initStepSizeSlider
{
    _stepSizeSlider = [[DKCircularSlider alloc] initWithFrame:_stepSizeContainer.bounds
                                                        usingMax:45
                                                        usingMin:1
                                                withContentImage:nil
                                                       withTitle:@"degrees" withTarget:self usingSelector:@selector(stepSizeSliderDidChange:)];
    [_stepSizeContainer addSubview:_stepSizeSlider];
    [_stepSizeSlider movehandleToValue:self.timelapseSettings.stepSize];
}

#pragma mark - DKCircularSlider

- (void)distanceSliderDidChange:(DKCircularSlider *)distanceSlider
{
    if (self.timelapseSettings.distance == distanceSlider.currentValue) {
        return;
    }
    self.timelapseSettings.distance = distanceSlider.currentValue;
    if (_stepSizeSlider) {
       [_stepSizeSlider movehandleToValue:self.timelapseSettings.stepSize];
    }
}

- (void)stepSizeSliderDidChange:(DKCircularSlider *)stepSizeSlider
{
    if (self.timelapseSettings.stepSize == stepSizeSlider.currentValue) {
        return;
    }
    self.timelapseSettings.stepSize = stepSizeSlider.currentValue;
    if (_distanceSlider) {
        [_distanceSlider movehandleToValue:self.timelapseSettings.distance];
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
