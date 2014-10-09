//
//  SWTimelapseSettings.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/5/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWTimelapseSettings.h"

@interface SWTimelapseSettings ()

@property (nonatomic, assign) NSTimeInterval holdShutterTime;

@end

@implementation SWTimelapseSettings

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cameraInterface = SWCameraInterfaceUSB;

        self.stepCount = 10;
        self.stepSize = 6.75;
        self.clockwiseDirection = YES;
        self.timeBetweenPictures = 5.0;
        self.startTiltAngle = 0;
        self.endTiltAngle = 0;
        self.holdShutterTime = 2.0;
        self.exposure = self.minimumExposure;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self) {
        self.holdShutterTime = 2.0;
        
        NSNumber *savedCameraInterface = [decoder decodeObjectForKey:@"cameraInterface"];
        self.cameraInterface = savedCameraInterface ? [savedCameraInterface integerValue] : SWCameraInterfaceUSB;
        
        NSNumber *savedExposure = [decoder decodeObjectForKey:@"exposure"];
        self.exposure = savedExposure ? [savedExposure doubleValue] : [self minimumExposure];
        
        self.timeBetweenPictures = [[decoder decodeObjectForKey:@"timeBetweenPictures"] doubleValue];

        _stepSize = [[decoder decodeObjectForKey:@"stepSize"] floatValue];
        NSInteger distance = [[decoder decodeObjectForKey:@"distance"] integerValue];
        if (distance > 0) {
            _stepCount = (NSInteger)roundf(distance / _stepSize) + 1;
        } else {
            _stepCount = [[decoder decodeObjectForKey:@"stepCount"] integerValue];
        }
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
    [encoder encodeObject:[NSNumber numberWithDouble:_timeBetweenPictures] forKey:@"timeBetweenPictures"];
    [encoder encodeObject:[NSNumber numberWithBool:_clockwiseDirection] forKey:@"clockwiseDirection"];
    [encoder encodeObject:[NSNumber numberWithInteger:_startTiltAngle] forKey:@"startTiltAngle"];
    [encoder encodeObject:[NSNumber numberWithInteger:_endTiltAngle] forKey:@"endTiltAngle"];
    [encoder encodeObject:[NSNumber numberWithDouble:_exposure] forKey:@"exposure"];
    [encoder encodeObject:[NSNumber numberWithInteger:_cameraInterface] forKey:@"cameraInterface"];
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

- (void)setCameraInterface:(SWCameraInterface)cameraInterface
{
    _cameraInterface = cameraInterface;
    if (self.exposure < self.minimumExposure) {
        self.exposure = self.minimumExposure;
    }
    
    if (cameraInterface == SWCameraInterfaceUSB) {
        self.exposure = floor(self.exposure);
        self.timeBetweenPictures = floor(self.timeBetweenPictures);
    }
}

- (SWTimeComponents)timeBetweenPicturesComponents
{
    return SWTimeComponentsMake(self.timeBetweenPictures);
}

- (SWTimeComponents)recordingTimeComponents
{
    return SWTimeComponentsMake(self.recordingTime);
}

- (void)setTimeBetweenPictures:(NSTimeInterval)timeBetweenPictures
{
    if (timeBetweenPictures >= self.minimumTimeBetweenPictures && timeBetweenPictures <= SW_TIMELAPSE_MAX_TIME_BTWN_PICTURES) {
        _timeBetweenPictures = timeBetweenPictures;
        
        if (_timeBetweenPictures != self.minimumTimeBetweenPictures) {
            _timeBetweenPictures = floor(_timeBetweenPictures);
        }
        
        if (_timeBetweenPictures < self.exposure) {
            self.exposure = _timeBetweenPictures;
        }
    }
}

- (void)setTimeBetweenPicturesWithComponents:(SWTimeComponents)timeBetweenPicturesComponents
{
    NSTimeInterval seconds = timeBetweenPicturesComponents.hours * 3600 + timeBetweenPicturesComponents.minutes * 60 + timeBetweenPicturesComponents.seconds;
    self.timeBetweenPictures = seconds;
}

- (void)setExposure:(NSTimeInterval)exposureTime
{
    if (exposureTime >= self.minimumExposure && exposureTime <= SW_TIMELAPSE_MAX_EXPOSURE) {
        _exposure = exposureTime;
        
        if (_exposure != self.minimumExposure) {
            _exposure = floor(_exposure);
        }
        
        if (self.timeBetweenPictures < _exposure) {
            self.timeBetweenPictures = _exposure;
        }
    }
}

- (NSTimeInterval)minimumExposure
{
    switch (self.cameraInterface) {
        case SWCameraInterfaceTrigger:
            return self.holdShutterTime + SW_TIMELAPSE_MIN_PROTECTION_PAUSE;
            break;
        case SWCameraInterfaceUSB:
            return SW_TIMELAPSE_MIN_EXPOSURE_USB;
            break;
        default:
            return 0;
            break;
    }
}

- (NSTimeInterval)minimumTimeBetweenPictures
{
    return [self minimumExposure];
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

- (NSTimeInterval)recordingTime
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
