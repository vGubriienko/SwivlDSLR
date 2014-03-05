//
//  SWMainViewController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWMainViewController.h"

@interface SWMainViewController ()
{
    __weak IBOutlet UIButton *_distanceBtn;
    __weak IBOutlet UIButton *_directionBtn;
    __weak IBOutlet UIButton *_stepSizeBtn;
    __weak IBOutlet UIButton *_recordingTimeBtn;
    __weak IBOutlet UIButton *_timeBetweenPicturesBtn;
    
}
@end

@implementation SWMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma IBActions

- (IBAction)onDistanceBtnTapped
{
    
}

- (IBAction)onDirectionBtnTapped
{
    _directionBtn.selected = !_directionBtn.selected;
}

- (IBAction)onStepSizeBtnTapped
{
    
}

- (IBAction)onRecordingBtnTapped
{
    
}

- (IBAction)onTimeBetweenPicturesBtnTapped
{
    
}

#pragma -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
