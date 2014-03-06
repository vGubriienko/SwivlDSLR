//
//  SWStepSizeController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/5/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWStepSizeController.h"

#import "SWTimelapseSettings.h"
#import "DKCircularSlider.h"

#define COMPONENTRECT CGRectMake(88, 82, DK_SLIDER_SIZE-90, DK_SLIDER_SIZE-90)

@interface SWStepSizeController ()
{
    DKCircularSlider *_distanceSlider;
    SWTimelapseSettings *_timelapseSettings;
}
@end

@implementation SWStepSizeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configUI];
}

- (void)configUI
{
    _distanceSlider = [[DKCircularSlider alloc] initWithFrame:COMPONENTRECT
                                                     usingMax:45
                                                     usingMin:1
                                             withContentImage:nil
                                                    withTitle:@"degrees" withTarget:self usingSelector:@selector(sliderChange:)];
    [[self view] addSubview:_distanceSlider];
    [_distanceSlider movehandleToValue:_timelapseSettings.stepSize];
}

#pragma TimelapsSegueNavigation

- (void)setTimelapseSettings:(SWTimelapseSettings *)timelapseSettings
{
    _timelapseSettings = timelapseSettings;
}

#pragma mark IBActions
-(void)sliderChange:(DKCircularSlider *)sender
{
    if (_distanceSlider) {
        _timelapseSettings.stepSize = sender.currentValue;
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
