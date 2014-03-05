//
//  TimelapsSegue.h
//
//  Created by Sergei Me (mer.sergei@gmai.com) on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWTimelapseSettings;

@protocol TimelapsSegueNavigation <NSObject>

@optional
- (void)setTimelapseSettings:(SWTimelapseSettings *)timelapseSettings;

@end

@interface TimelapsSegue : UIStoryboardSegue

@end
