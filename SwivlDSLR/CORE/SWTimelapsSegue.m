//
//  SWTimelapsSegue.m
//
//  Created by Sergei Me (mer.sergei@gmai.com) on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWTimelapsSegue.h"

#import "SWMainViewController.h"

@implementation SWTimelapsSegue

- (void)perform
{
    SWMainViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    CGRect contentViewFrame = sourceViewController.contentView.bounds;
    destinationViewController.view.frame = contentViewFrame;
    destinationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [sourceViewController.contentView addSubview:destinationViewController.view];
}

@end
