//
//  SWScript.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/20/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWScript.h"

@implementation SWScript

#pragma mark - Init

- (instancetype)initWithTimelapseSettings:(SWTimelapseSettings *)timelapseSettings
{
    self = [super init];
    if (self) {
        _timelapseSettings = timelapseSettings;
    }
    return self;
}

#pragma mark - Public methods

- (char *)scriptWithLength:(NSInteger *)length
{
    return nil;
}

- (BOOL)isFinished
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.second = self.timelapseSettings.recordingTime;
    
    NSDate *finishDate = [[NSCalendar currentCalendar] dateByAddingComponents:comps
                                                                       toDate:self.startDate options:(0)];
    NSComparisonResult result = [finishDate compare:[NSDate date]];
    return result == NSOrderedAscending;
}

@end
