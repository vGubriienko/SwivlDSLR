//
//  SWDistanceViewController.m
//  SwivlDSLR
//
//  Created by Sergei Me (mer.sergei@gmai.com) on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWDistanceController.h"

#import "SWTimelapseSettings.h"
#import "DKCircularSlider.h"

#define COMPONENTRECT CGRectMake(45, 45, DK_SLIDER_SIZE-90, DK_SLIDER_SIZE-90)

@interface SWDistanceController ()
{
    DKCircularSlider *_distanceSlider;
}
@end

@implementation SWDistanceController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configUI];
}

- (void)configUI
{
    _distanceSlider = [[DKCircularSlider alloc] initWithFrame:COMPONENTRECT
                                                   usingMax:360
                                                   usingMin:1
                                           withContentImage:[UIImage imageNamed:@"sensitivity"]
                                                  withTitle:@"Distance" withTarget:self usingSelector:@selector(sliderChange:)];
    [[self view] addSubview:_distanceSlider];
    [_distanceSlider movehandleToValue:_timelapseSettings.distance];
}

- (void)setTimelapseSettings:(SWTimelapseSettings *)timelapseSettings
{
    _timelapseSettings = timelapseSettings;
    [_distanceSlider movehandleToValue:_timelapseSettings.distance];
}

#pragma mark IBActions
-(void)sliderChange:(DKCircularSlider *)sender
{
    if (_distanceSlider) {
        _timelapseSettings.distance = sender.currentValue;
    }

    NSLog(@"Value Changed (%@)",[sender getTextValue]);
}

#pragma mark -
- (void)dealloc
{
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
