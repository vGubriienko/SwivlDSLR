//
//  SWSettingsBackSegue.m
//
//  Created by Sergei Me (mer.sergei@gmai.com) on 5/12/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWSettingsBackSegue.h"

@implementation SWSettingsBackSegue

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.navigationController popViewControllerAnimated:YES];
}

@end
