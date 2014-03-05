//
//  TimelapsSegue.m
//
//  Created by Sergei Me (mer.sergei@gmai.com) on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "TimelapsSegue.h"

@implementation TimelapsSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    CGRect _destinationFrame = CGRectMake(0, 0, 406, 320);
    // Add the destination view as a subview
    [sourceViewController.view addSubview:destinationViewController.view];
    destinationViewController.view.frame = _destinationFrame;
    
    _destinationFrame = destinationViewController.view.frame;
     NSLog(@"Frame = %@", NSStringFromCGRect(_destinationFrame));
    
}

@end
