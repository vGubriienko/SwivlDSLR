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
    DKCircularSlider *distanceSlider = [[DKCircularSlider alloc] initWithFrame:_distanceContainer.bounds
                                                                      usingMax:360
                                                                      usingMin:1
                                                              withContentImage:nil
                                                                     withTitle:@"degrees" withTarget:self usingSelector:@selector(distanceSliderDidChange:)];
    [_distanceContainer addSubview:distanceSlider];
    [distanceSlider movehandleToValue:self.timelapseSettings.distance];
}

- (void)initStepSizeSlider
{
    DKCircularSlider *stepSizeSlider = [[DKCircularSlider alloc] initWithFrame:_stepSizeContainer.bounds
                                                                      usingMax:45
                                                                      usingMin:1
                                                              withContentImage:nil
                                                                     withTitle:@"degrees" withTarget:self usingSelector:@selector(stepSizeSliderDidChange:)];
    [_stepSizeContainer addSubview:stepSizeSlider];
    [stepSizeSlider movehandleToValue:self.timelapseSettings.stepSize];
}

#pragma mark - DKCircularSlider

- (void)distanceSliderDidChange:(DKCircularSlider *)distanceSlider
{
    self.timelapseSettings.distance = distanceSlider.currentValue;
}

- (void)stepSizeSliderDidChange:(DKCircularSlider *)stepSizeSlider
{
    self.timelapseSettings.stepSize = stepSizeSlider.currentValue;
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
