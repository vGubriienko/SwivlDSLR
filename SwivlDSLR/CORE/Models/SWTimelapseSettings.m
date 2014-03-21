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
        self.recordingTime = 100;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self) {
        _stepSize = [[decoder decodeObjectForKey:@"stepSize"] floatValue];
        _distance = [[decoder decodeObjectForKey:@"distance"] integerValue];
        _recordingTime = [[decoder decodeObjectForKey:@"recordingTime"] floatValue];
        _clockwiseDirection = [[decoder decodeObjectForKey:@"clockwiseDirection"] boolValue];
        _timeBetweenPictures = [[decoder decodeObjectForKey:@"timeBetweenPictures"] floatValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[NSNumber numberWithFloat:_stepSize] forKey:@"stepSize"];
    [encoder encodeObject:[NSNumber numberWithInteger:_distance] forKey:@"distance"];
    [encoder encodeObject:[NSNumber numberWithFloat:_recordingTime] forKey:@"recordingTime"];
    [encoder encodeObject:[NSNumber numberWithBool:_clockwiseDirection] forKey:@"clockwiseDirection"];
    [encoder encodeObject:[NSNumber numberWithFloat:_timeBetweenPictures] forKey:@"timeBetweenPictures"];
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

+ (NSDictionary *)timeRanges
{
    static NSDictionary *dict = nil;
    if (!dict) {
        
        NSMutableArray *hours = [NSMutableArray arrayWithCapacity:24];
        for (NSInteger i = 0; i < 24; i++) {
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

- (SWTimeComponents)recordingTimeComponents
{
    SWTimeComponents timeComps;
    timeComps.hours = self.recordingTime / 3600;
    timeComps.minutes = (self.recordingTime - timeComps.hours * 3600) / 60;
    timeComps.seconds = self.recordingTime - timeComps.hours * 3600 - timeComps.minutes * 60;
    return timeComps;
}

- (SWTimeComponents)timeBetweenPicturesComponents
{
    SWTimeComponents timeComps;
    timeComps.hours = self.timeBetweenPictures / 3600;
    timeComps.minutes = (self.timeBetweenPictures - timeComps.hours * 3600) / 60;
    timeComps.seconds = self.timeBetweenPictures - timeComps.hours * 3600 - timeComps.minutes * 60;
    return timeComps;
}

- (void)setRecordingTimeWithComponents:(SWTimeComponents)recordingTimeComponents
{
    CGFloat seconds = recordingTimeComponents.hours * 3600 + recordingTimeComponents.minutes * 60 + recordingTimeComponents.seconds;
    self.recordingTime = seconds;
}

- (void)setTimeBetweenPicturesWithComponents:(SWTimeComponents)timeBtwnPicturesComponents
{
    CGFloat seconds = timeBtwnPicturesComponents.hours * 3600 + timeBtwnPicturesComponents.minutes * 60 + timeBtwnPicturesComponents.seconds;
    self.timeBetweenPictures = seconds;
}

#pragma mark - Properties

- (void)setDistance:(NSInteger)distance
{
    if (distance >= SW_TIMELAPSE_MIN_DISTANCE && distance <= SW_TIMELAPSE_MAX_DISTANCE) {
        _distance = distance;
        
        if (_distance < self.stepSize) {
            self.stepSize = [self maxStepSizeForDistance:distance];
        }
        [self recalculateTimeBtwnPictures];
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
            self.distance = ceil(stepSize);
        }
        [self recalculateTimeBtwnPictures];
    }
}

- (void)setTimeBetweenPictures:(CGFloat)timeBetweenPictures
{
    _timeBetweenPictures = timeBetweenPictures;
    [self recalculateRecordingTime];
}

- (void)setRecordingTime:(CGFloat)recordingTime
{
    _recordingTime = recordingTime;
    [self recalculateTimeBtwnPictures];
}

- (NSInteger)stepCount
{
    return (NSInteger) self.distance / self.stepSize;
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

- (void)recalculateTimeBtwnPictures
{
    _timeBetweenPictures = _recordingTime / self.stepCount;
}

- (void)recalculateRecordingTime
{
    _recordingTime = _timeBetweenPictures * self.stepCount;
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

+ (NSSet *)keyPathsForValuesAffectingStepSize
{
    return [NSSet setWithObject:@"timeBetweenPictures"];
}

+ (NSSet *)keyPathsForValuesAffectingDistance
{
    return [NSSet setWithObject:@"timeBetweenPictures"];
}

@end
