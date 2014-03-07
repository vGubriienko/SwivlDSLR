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
        _distance = 45;
        _stepSize = 5;
        _clockwiseDirection = YES;
        _timeBetweenPictures = 4.5;
        _recordingTime = [[NSDateComponents alloc] init];
        _recordingTime.hour = 1;
        _recordingTime.minute = 30;
        _recordingTime.second = 45;
    }
    return self;
}

#pragma mark - Public methods

//+ (NSArray *)availableStepSizes
//{
//    static NSArray *array = nil;
//    if (!array) {
//        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
//        for (NSInteger i = 1; i <= 20; i++) {
//            [tempArray addObject:[NSString stringWithFormat:@"%i", i]];
//        }
//        array = [tempArray copy];
//    }
//    return array;
//}

+ (NSArray *)availableTimesBtwnPictures
{
    static NSArray *array = nil;
    if (!array) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
        for (NSInteger i = 1; i <= 20; i++) {
            [tempArray addObject:[NSString stringWithFormat:@"%.1f", (float)i / 2]];
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
            [hours addObject:[NSString stringWithFormat:@"%i", i]];
        }
        NSMutableArray *minutesOrSeconds = [NSMutableArray arrayWithCapacity:60];
        for (NSInteger i = 0; i < 60; i++) {
            [minutesOrSeconds addObject:[NSString stringWithFormat:@"%i", i]];
        }
        
        dict = @{@"hours" : hours, @"minutes" : minutesOrSeconds, @"seconds" : minutesOrSeconds};
    }
    return dict;
}

#pragma mark - Setters

- (void)setDistance:(NSInteger)distance
{
    if (distance >= 1 && distance <= 360) {
        _distance = distance;
    }
    
    //recalculate time between pictures
    self.recordingTime = self.recordingTime;
}

- (void)setStepSize:(NSInteger)stepSize
{
    if (stepSize >= 1 && stepSize <= self.distance) {
        _stepSize = stepSize;
    }
    
    //recalculate time between pictures
    self.recordingTime = self.recordingTime;
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
