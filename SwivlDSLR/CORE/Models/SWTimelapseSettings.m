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
        self.stepCount = 10;
        self.stepSize = 6.75;
        self.clockwiseDirection = YES;
        self.timeBetweenPictures = 5;
        self.startTiltAngle = 0;
        self.endTiltAngle = 0;
        self.exposure = 1;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self) {
        _stepSize = [[decoder decodeObjectForKey:@"stepSize"] floatValue];
        NSInteger distance = [[decoder decodeObjectForKey:@"distance"] integerValue];
        if (distance > 0) {
            _stepCount = (NSInteger)roundf(distance / _stepSize) + 1;
        } else {
            _stepCount = [[decoder decodeObjectForKey:@"stepCount"] integerValue];
        }
        _timeBetweenPictures = [[decoder decodeObjectForKey:@"timeBetweenPictures"] integerValue];
        _clockwiseDirection = [[decoder decodeObjectForKey:@"clockwiseDirection"] boolValue];
        _startTiltAngle = [[decoder decodeObjectForKey:@"startTiltAngle"] integerValue];
        _endTiltAngle = [[decoder decodeObjectForKey:@"endTiltAngle"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[NSNumber numberWithFloat:_stepSize] forKey:@"stepSize"];
    [encoder encodeObject:[NSNumber numberWithInteger:_stepCount] forKey:@"stepCount"];
    [encoder encodeObject:[NSNumber numberWithInteger:_timeBetweenPictures] forKey:@"timeBetweenPictures"];
    [encoder encodeObject:[NSNumber numberWithBool:_clockwiseDirection] forKey:@"clockwiseDirection"];
    [encoder encodeObject:[NSNumber numberWithInteger:_startTiltAngle] forKey:@"startTiltAngle"];
    [encoder encodeObject:[NSNumber numberWithInteger:_endTiltAngle] forKey:@"endTiltAngle"];
}

#pragma mark - Public methods

+ (NSArray *)availableStepSizes
{
    static NSArray *array = nil;
    if (!array) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
        [tempArray addObject:@(0.0)];
        for (double i = SW_PAN_DEGREES_PER_ONE_MOTOR_STEP * 4; i < 20.0; i+= SW_PAN_DEGREES_PER_ONE_MOTOR_STEP) {
            [tempArray addObject:[NSNumber numberWithFloat:i]];
        }
        [tempArray addObject:@20.0];
        array = [tempArray copy];
    }
    return array;
}

#pragma mark - Properties

- (SWTimeComponents)timeBetweenPicturesComponents
{
    return SWTimeComponentsMake(self.timeBetweenPictures);
}

- (SWTimeComponents)recordingTimeComponents
{
    return SWTimeComponentsMake(self.recordingTime);
}

- (void)setTimeBetweenPictures:(NSInteger)timeBetweenPictures
{
    if (timeBetweenPictures >= SW_TIMELAPSE_MIN_TIME_BTWN_PICTURES && timeBetweenPictures <= SW_TIMELAPSE_MAX_TIME_BTWN_PICTURES) {
        _timeBetweenPictures = timeBetweenPictures;
        if (self.exposure >= timeBetweenPictures) {
            self.exposure = timeBetweenPictures - 1;
        }
    }
}

- (void)setTimeBetweenPicturesWithComponents:(SWTimeComponents)timeBetweenPicturesComponents
{
    NSInteger seconds = timeBetweenPicturesComponents.hours * 3600 + timeBetweenPicturesComponents.minutes * 60 + timeBetweenPicturesComponents.seconds;
    self.timeBetweenPictures = seconds;
}

- (void)setExposure:(NSInteger)exposureTime
{
    if (exposureTime >= SW_TIMELAPSE_MIN_EXPOSURE && exposureTime <= SW_TIMELAPSE_MAX_EXPOSURE) {
        _exposure = exposureTime;
        if (exposureTime >= self.timeBetweenPictures) {
            self.timeBetweenPictures = exposureTime + 1;
        }
    }
}

- (void)setStepSize:(CGFloat)stepSize
{
    NSArray *availableStepSizes = [SWTimelapseSettings availableStepSizes];
    NSUInteger stepSizeIndex = [availableStepSizes indexOfObject:[NSNumber numberWithFloat:stepSize]];
    BOOL isStepSizeAvailable = stepSizeIndex != NSNotFound;
    
    if (isStepSizeAvailable) {
        _stepSize = stepSize;
    }
}

- (void)setStepCount:(NSInteger)stepCount
{
    if (stepCount >= SW_TIMELAPSE_MIN_STEPCOUNT && stepCount <= SW_TIMELAPSE_MAX_STEPCOUNT) {
        _stepCount = stepCount;
    }
}

- (NSInteger)distance
{
    return (NSInteger)roundf((self.stepCount - 1) * self.stepSize);
}

- (NSInteger)recordingTime
{
    return (self.stepCount - 1) * self.timeBetweenPictures;
}

- (void)setStartTiltAngle:(NSInteger)startTiltAngle
{
    if (startTiltAngle >= SW_TIMELAPSE_MIN_TILT && startTiltAngle <= SW_TIMELAPSE_MAX_TILT) {
        _startTiltAngle = startTiltAngle;
    }
}

- (void)setEndTiltAngle:(NSInteger)endTiltAngle
{
    if (endTiltAngle >= SW_TIMELAPSE_MIN_TILT && endTiltAngle <= SW_TIMELAPSE_MAX_TILT) {
        _endTiltAngle = endTiltAngle;
    }
}

#pragma mark - Dependencies

+ (NSSet *)keyPathsForValuesAffectingRecordingTime
{
    return [NSSet setWithObjects:@"timeBetweenPictures", @"stepCount", nil];
}

+ (NSSet *)keyPathsForValuesAffectingDistance
{
    return [NSSet setWithObjects:@"stepCount", @"stepSize", nil];
}

@end
