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
        self.distance = 180;
        self.stepSize = 0.99;
        self.clockwiseDirection = YES;
        self.recordingTime = [[NSDateComponents alloc] init];
        self.timeBetweenPictures = 2;
    }
    return self;
}

#pragma mark - Public methods

+ (NSArray *)availableStepSizes
{
    static NSArray *array = nil;
    if (!array) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
        for (double i = 0.11; i <= 11.0; i+= 0.11) {
            [tempArray addObject:[NSNumber numberWithFloat:i]];
        }
        array = [tempArray copy];
    }
    return array;
}

+ (NSArray *)availableTimesBtwnPictures
{
    static NSArray *array = nil;
    if (!array) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
        for (double i = 1.0; i <= 20.0; i++) {
            [tempArray addObject:[NSNumber numberWithFloat:i / 2]];
        }
        array = [tempArray copy];
    }
    return array;
}

+ (NSDictionary *)availableRecordingTime
{
    static NSDictionary *dict = nil;
    if (!dict) {
        
        NSMutableArray *hours = [NSMutableArray arrayWithCapacity:5];
        for (NSInteger i = 0; i <= 3; i++) {
            [hours addObject:[NSNumber numberWithInteger:i]];
        }
        NSMutableArray *minutesOrSeconds = [NSMutableArray arrayWithCapacity:60];
        for (NSInteger i = 0; i < 60; i++) {
            [minutesOrSeconds addObject:[NSNumber numberWithInteger:i]];
        }
        
        dict = @{@"hours" : hours, @"minutes" : minutesOrSeconds, @"seconds" : minutesOrSeconds};
    }
    return dict;
}

#pragma mark - Setters

- (void)setDistance:(NSInteger)distance
{
    if (distance >= SW_TIMELAPSE_MIN_DISTANCE && distance <= SW_TIMELAPSE_MAX_DISTANCE) {
        _distance = distance;
        
        if (_distance < self.stepSize) {
            self.stepSize = [self maxStepSizeForDistance:distance];
        }
        
        //recalculate time between pictures
        self.recordingTime = self.recordingTime;
    }
}

- (void)setStepSize:(CGFloat)stepSize
{
    NSArray *availableStepSizes = [SWTimelapseSettings availableStepSizes];
    NSUInteger stepSizeIndex = [availableStepSizes indexOfObject:[NSNumber numberWithFloat:stepSize]];
    BOOL isStepSizeAvailable = stepSizeIndex != NSNotFound;
    
    if (isStepSizeAvailable) {
        _stepSize = stepSize;
        
        if (stepSize > self.distance && stepSize <= SW_TIMELAPSE_MAX_DISTANCE) {
            self.distance = stepSize;
        }
        
        //recalculate time between pictures
        self.recordingTime = self.recordingTime;
    }
}

- (void)setTimeBetweenPictures:(CGFloat)timeBetweenPictures
{
    _timeBetweenPictures = timeBetweenPictures;
    
    //recalculate recording time
    CGFloat stepCount = self.distance / self.stepSize;
    NSInteger recordingTimeSeconds = timeBetweenPictures * stepCount;
    _recordingTime.hour = recordingTimeSeconds / 3600;
    _recordingTime.minute = (recordingTimeSeconds % 3600) / 60;
    _recordingTime.second = recordingTimeSeconds % 60;
}

- (void)setRecordingTime:(NSDateComponents *)recordingTime
{
    _recordingTime = recordingTime;
    
    //recalculate time between pictures
    CGFloat stepCount = self.distance / self.stepSize;
    _timeBetweenPictures = (recordingTime.second + recordingTime.minute * 60 + recordingTime.hour * 3600) / stepCount;
}

#pragma mark - Private methods

- (CGFloat)maxStepSizeForDistance:(NSInteger)distance
{
    __block CGFloat stepSize;
    
    NSArray *availableStepSizes = [SWTimelapseSettings availableStepSizes].reverseObjectEnumerator.allObjects;
    [availableStepSizes enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        stepSize = obj.floatValue;
        if (stepSize < distance) {
            (*stop) = YES;
        }
    }];
    return stepSize;
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
