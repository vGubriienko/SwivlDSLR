//
//  SWTimelapseSettingsTests.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/6/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SWTimelapseSettings.h"

@interface SWTimelapseSettingsTests : XCTestCase
{
    SWTimelapseSettings *_timelapseSettings;
}
@end

@implementation SWTimelapseSettingsTests

- (void)setUp
{
    [super setUp];
    
    _timelapseSettings = [[SWTimelapseSettings alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Step size

- (void)testStepSizeDoesNotChangesAfterSettingInvalidValue
{
    _timelapseSettings.stepSize = 6.75;
    
    _timelapseSettings.stepSize = -1;
    XCTAssertEqualWithAccuracy(_timelapseSettings.stepSize, 6.75, FLT_EPSILON, @"Invalid stepSize value");
    _timelapseSettings.stepSize = 21;
    XCTAssertEqualWithAccuracy(_timelapseSettings.stepSize, 6.75, FLT_EPSILON, @"Invalid stepSize value");
}

- (void)testStepSizeHasValidInitValue
{
    NSNumber *stepSize = [NSNumber numberWithFloat:_timelapseSettings.stepSize];
    BOOL isStepSizeAvailable = [[SWTimelapseSettings availableStepSizes] containsObject:stepSize];
    XCTAssertTrue(isStepSizeAvailable, @"StepSize has invalid init value");
}

#pragma mark - Step Count

- (void)testStepCountDoesNotChangesAfterSettingInvalidValue
{
    _timelapseSettings.stepCount = 1000;
    
    _timelapseSettings.stepCount = 0;
    XCTAssertEqual(_timelapseSettings.stepCount, 1000, @"Invalid stepCount value");
    _timelapseSettings.stepCount = 1;
    XCTAssertEqual(_timelapseSettings.stepCount, 1000, @"Invalid stepCount value");
    _timelapseSettings.stepCount = -1;
    XCTAssertEqual(_timelapseSettings.stepCount, 1000, @"Invalid stepCount value");
    _timelapseSettings.stepCount = 3001;
    XCTAssertEqual(_timelapseSettings.stepCount, 1000, @"Invalid stepCount value");
}

- (void)testStepCountSizeHasValidInitValue
{
    XCTAssertTrue(_timelapseSettings.stepCount >= SW_TIMELAPSE_MIN_STEPCOUNT, @"StepCount has invalid init value");
    XCTAssertTrue(_timelapseSettings.stepCount <= SW_TIMELAPSE_MAX_STEPCOUNT, @"StepCount has invalid init value");
}

#pragma mark - Time between pictures

- (void)testTimeBtwnPicturesHasValidInitValue
{
    XCTAssertTrue(_timelapseSettings.timeBetweenPictures >= SW_TIMELAPSE_MIN_TIME_BTWN_PICTURES, @"TimeBetweenPictures has invalid init value");
    XCTAssertTrue(_timelapseSettings.timeBetweenPictures <= SW_TIMELAPSE_MAX_TIME_BTWN_PICTURES, @"TimeBetweenPictures has invalid init value");
}

- (void)testTimeBtwnPicturesDoesNotChangeAfterSettingInvalidValue
{
    _timelapseSettings.timeBetweenPictures = 10;
    _timelapseSettings.timeBetweenPictures = 1;
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, 10, @"Invalid timeBetweenPictures value");
    
    _timelapseSettings.timeBetweenPictures = 23 * 3600 + 59 * 60 + 59 + 1;
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, 10, @"Invalid timeBetweenPictures value");
}

- (void)testSettingTimeBtwnPicturesDecreasesExposureIfNeeded
{
    _timelapseSettings.timeBetweenPictures = 10;
    _timelapseSettings.exposure = 8;
    _timelapseSettings.timeBetweenPictures = 3;

    XCTAssertEqual(_timelapseSettings.exposure, 2, @"exposure should be bigger then timeBetweenPictures");
}

#pragma mark - Recording time

- (void)testRecordingTimeCalculatesCorrectly
{
    _timelapseSettings.timeBetweenPictures = 3;
    _timelapseSettings.stepCount = 10;
    XCTAssertEqual(_timelapseSettings.recordingTime, 27, @"Wrong recordingTime");
}

#pragma mark - Distance

- (void)testDistanceCalculatesCorrectly
{
    _timelapseSettings.stepCount = 101;
    _timelapseSettings.stepSize = 6.75;
    XCTAssertEqual(_timelapseSettings.distance, 675, @"Wrong distance");
}

- (void)testDistanceIsRounded
{
    _timelapseSettings.stepCount = 11;
    _timelapseSettings.stepSize = 6.75;
    XCTAssertEqual(_timelapseSettings.distance, 68, @"Wrong distance");
}

#pragma mark - Time components

- (void)testRecordigTimeComponents
{
    _timelapseSettings.timeBetweenPictures = 5;
    _timelapseSettings.stepCount = 21;

    SWTimeComponents timeComponents = [_timelapseSettings recordingTimeComponents];
    XCTAssertEqual(timeComponents.hours, 0, @"Incorrect recordingTime hours");
    XCTAssertEqual(timeComponents.minutes, 1, @"Incorrect recordingTime minutes");
    XCTAssertEqual(timeComponents.seconds, 40, @"Incorrect recordingTime seconds");
}

- (void)testTimeBetweenPicturesComponents
{
    _timelapseSettings.timeBetweenPictures = 5145;
    SWTimeComponents timeComponents = [_timelapseSettings timeBetweenPicturesComponents];
    XCTAssertEqual(timeComponents.hours, 1, @"Incorrect timeBetweenPictures hours");
    XCTAssertEqual(timeComponents.minutes, 25, @"Incorrect timeBetweenPictures minutes");
    XCTAssertEqual(timeComponents.seconds, 45, @"Incorrect timeBetweenPictures seconds");
}

- (void)testSetTimeBetweenPicturesWithComponents
{
    SWTimeComponents timeComponents;
    timeComponents.hours = 2;
    timeComponents.minutes = 0;
    timeComponents.seconds = 30;
    
    [_timelapseSettings setTimeBetweenPicturesWithComponents:timeComponents];
    
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, 7230, @"Incorrect timeBetweenPictures seconds");
}

#pragma mark - Tilt

- (void)testStartTiltIsZeroAfterInit
{
    XCTAssertEqual(_timelapseSettings.startTiltAngle, 0, @"Invalid initial start tilt value");
}

- (void)testEndTiltIsZeroAfterInit
{
    XCTAssertEqual(_timelapseSettings.endTiltAngle, 0, @"Invalid initial end tilt value");
}

- (void)testStartTiltDoesNotChangesAfterSettingInvalidValue
{
    _timelapseSettings.startTiltAngle = -12;
    
    _timelapseSettings.startTiltAngle = -13;
    XCTAssertEqual(_timelapseSettings.startTiltAngle, -12, @"Invalid start tilt value");
    _timelapseSettings.startTiltAngle = 13;
    XCTAssertEqual(_timelapseSettings.startTiltAngle, -12, @"Invalid start tilt value");
}

- (void)testEndTiltDoesNotChangesAfterSettingInvalidValue
{
    _timelapseSettings.endTiltAngle = 12;
    
    _timelapseSettings.endTiltAngle = 13;
    XCTAssertEqual(_timelapseSettings.endTiltAngle, 12, @"Invalid end tilt value");
    _timelapseSettings.endTiltAngle = 13;
    XCTAssertEqual(_timelapseSettings.endTiltAngle, 12, @"Invalid end tilt value");
}

#pragma mark - Exposure

- (void)testExposureHasValidInitValue
{
    XCTAssertTrue(_timelapseSettings.exposure >= SW_TIMELAPSE_MIN_EXPOSURE, @"Exposure has invalid init value");
    XCTAssertTrue(_timelapseSettings.exposure <= SW_TIMELAPSE_MAX_EXPOSURE, @"Exposure has invalid init value");
}

- (void)testExposureDoesNotChangesAfterSettingInvalidValue
{
    _timelapseSettings.exposure = 10;
    _timelapseSettings.exposure = 0;
    XCTAssertEqual(_timelapseSettings.exposure, 10, @"Invalid exposure value");
    
    _timelapseSettings.exposure = 100;
    _timelapseSettings.exposure = 1001;
    XCTAssertEqual(_timelapseSettings.exposure, 100, @"Invalid exposure value");
}

- (void)testSettingExposureIncreasesTimeBtwnPicturesIfNeeded
{
    _timelapseSettings.timeBetweenPictures = 5;
    _timelapseSettings.exposure = 10;
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, 11, @"timeBetweenPictures should be bigger then exposure");
}

#pragma mark - Save & Restore

- (void)testSavingIsCorrect
{
    _timelapseSettings.stepCount = 1000;
    _timelapseSettings.stepSize = 6.75;
    _timelapseSettings.timeBetweenPictures = 200;
    _timelapseSettings.clockwiseDirection = YES;
    _timelapseSettings.startTiltAngle = -10;
    _timelapseSettings.endTiltAngle = -12;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_timelapseSettings];
    _timelapseSettings = (SWTimelapseSettings *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqual(_timelapseSettings.stepCount, 1000, @"Invalid distance value after save & restore");
    XCTAssertEqualWithAccuracy(_timelapseSettings.stepSize, 6.75, FLT_EPSILON, @"Invalid stepSize value after save & restore");
    XCTAssertEqual(_timelapseSettings.clockwiseDirection, YES, @"Invalid clockwiseDirection value after save & restore");
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, 200, @"Invalid recordingTime value after save & restore");
    XCTAssertEqual(_timelapseSettings.startTiltAngle, -10, @"Invalid startTiltAngle value after save & restore");
    XCTAssertEqual(_timelapseSettings.endTiltAngle, -12, @"Invalid endTiltAngle value after save & restore");
}

@end
