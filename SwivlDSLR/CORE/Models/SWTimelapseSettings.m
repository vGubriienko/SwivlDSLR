//
//  SWTimelapseSettings.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/5/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWTimelapseSettings.h"

@implementation SWTimelapseSettings

- (id)init
{
    self = [super init];
    if (self) {
        _distance = 360;
        _stepSize = 1;
        _clockwiseDirection = YES;
        _timeBetweenPictures = 0;
        _recordingTime = [[NSDateComponents alloc] init];
        _recordingTime.hour = _recordingTime.minute = _recordingTime.second = 0;
    }
    return self;
}

#pragma mark - Setters

- (void)setDistance:(NSInteger)distance
{
    if (distance < 0) {
        _distance = 0;
    } else if (distance > 360) {
        _distance = 360;
    } else {
        _distance = distance;
    }
}

- (void)setStepSize:(NSInteger)stepSize
{
    if (stepSize < 0) {
        _stepSize = 0;
    } else if (stepSize > self.distance) {
        _stepSize = self.distance;
    } else {
        _stepSize = stepSize;
    }
}

- (void)setTimeBetweenPictures:(CGFloat)timeBetweenPictures
{
    _timeBetweenPictures = timeBetweenPictures;
    
    CGFloat stepCount = self.distance / self.stepSize;
    NSInteger recordingTimeSeconds = timeBetweenPictures * stepCount;
    _recordingTime.hour = recordingTimeSeconds / 3600;
    _recordingTime.minute = (recordingTimeSeconds % 3600) / 60;
    _recordingTime.second = recordingTimeSeconds % 60;
}

- (void)setRecordingTime:(NSDateComponents *)recordingTime
{
    _recordingTime = recordingTime;
    
    CGFloat stepCount = self.distance / self.stepSize;
    _timeBetweenPictures = (recordingTime.second + recordingTime.minute * 60 + recordingTime.hour * 3600) / stepCount;
}

#pragma mark - Dependencies

+ (NSSet *)keyPathsForValuesAffectingTimeBetweenPictures
{
    return [NSSet setWithObject:@"recordingTime"];
}

+ (NSSet *)keyPathsForValuesAffectingRecordingTime
{
    return [NSSet setWithObject:@"timeBetweenPictures"];
}


@end
