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
    _timelapseSettings.stepSize = 0.11;
    
    _timelapseSettings.stepSize = 0;
    XCTAssertEqualWithAccuracy(_timelapseSettings.stepSize, 0.11, FLT_EPSILON, @"Invalid stepSize value");
    _timelapseSettings.stepSize = -1;
    XCTAssertEqualWithAccuracy(_timelapseSettings.stepSize, 0.11, FLT_EPSILON, @"Invalid stepSize value");
    _timelapseSettings.stepSize = 12;
    XCTAssertEqualWithAccuracy(_timelapseSettings.stepSize, 0.11, FLT_EPSILON, @"Invalid stepSize value");
    _timelapseSettings.stepSize = 10;
    XCTAssertEqualWithAccuracy(_timelapseSettings.stepSize, 0.11, FLT_EPSILON, @"Invalid stepSize value");
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
    _timelapseSettings.stepCount = -1;
    XCTAssertEqual(_timelapseSettings.stepCount, 1000, @"Invalid stepCount value");
    _timelapseSettings.stepCount = 3001;
    XCTAssertEqual(_timelapseSettings.stepCount, 1000, @"Invalid stepCount value");
}

- (void)testStepCountSizeHasValidInitValue
{
    XCTAssertTrue(_timelapseSettings.stepCount > 0, @"StepCount has invalid init value");
    XCTAssertTrue(_timelapseSettings.stepCount <= 3000, @"StepCount has invalid init value");
}

#pragma mark - Time btwn pictures

- (void)testTimeBtwnPicturesCalculatesCorrectly
{
    _timelapseSettings.recordingTime = 200;
    _timelapseSettings.stepCount = 10;
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, 20, @"Wrong timeBtwnPictures");
}

- (void)testTimeBtwnPicturesIsNOTRounded
{
    _timelapseSettings.recordingTime = 515;
    _timelapseSettings.stepCount = 100;
    XCTAssertEqualWithAccuracy(_timelapseSettings.timeBetweenPictures, 5.15, FLT_EPSILON, @"Wrong timeBtwnPictures");
}

#pragma mark - Distance

- (void)testDistanceCalculatesCorrectly
{
    _timelapseSettings.stepCount = 10;
    _timelapseSettings.stepSize = 0.11;
    XCTAssertEqual(_timelapseSettings.distance, 1, @"Wrong distance");
}

- (void)testDistanceIsRounded
{
    _timelapseSettings.stepCount = 10;
    _timelapseSettings.stepSize = 10.89;
    XCTAssertEqual(_timelapseSettings.distance, 109, @"Wrong distance");
}

#pragma mark - Time components

- (void)testRecordingTimeComponents
{
    _timelapseSettings.recordingTime = 5145;
    SWTimeComponents timeComponents = [_timelapseSettings recordingTimeComponents];
    XCTAssertEqual(timeComponents.hours, 1, @"Incorrect recordingTime hours");
    XCTAssertEqual(timeComponents.minutes, 25, @"Incorrect recordingTime minutes");
    XCTAssertEqual(timeComponents.seconds, 45, @"Incorrect recordingTime seconds");
}

- (void)testSetRecordingTimeWithComponents
{
    SWTimeComponents timeComponents;
    timeComponents.hours = 1;
    timeComponents.minutes = 10;
    timeComponents.seconds = 35;
    
    [_timelapseSettings setRecordingTimeWithComponents:timeComponents];
    
    XCTAssertEqual(_timelapseSettings.recordingTime, 4235, @"Incorrect timeBetweenPictures seconds");
}

- (void)testSetTimeBetweenPicturesWithComponents
{
    SWTimeComponents timeComponents;
    timeComponents.hours = 2;
    timeComponents.minutes = 0;
    timeComponents.seconds = 30;
    
    [_timelapseSettings setRecordingTimeWithComponents:timeComponents];
    
    XCTAssertEqual(_timelapseSettings.recordingTime, 7230, @"Incorrect timeBetweenPictures seconds");
}

#pragma mark - Tilt

- (void)testStartTiltDoesNotChangesAfterSettingInvalidValue
{
    _timelapseSettings.startTiltAngle = 20;
    
    _timelapseSettings.startTiltAngle = -1;
    XCTAssertEqual(_timelapseSettings.startTiltAngle, 20, @"Invalid start tilt value");
    _timelapseSettings.startTiltAngle = 26;
    XCTAssertEqual(_timelapseSettings.startTiltAngle, 20, @"Invalid start tilt value");
}

- (void)testEndTiltDoesNotChangesAfterSettingInvalidValue
{
    _timelapseSettings.endTiltAngle = 10;
    
    _timelapseSettings.endTiltAngle = -1;
    XCTAssertEqual(_timelapseSettings.endTiltAngle, 10, @"Invalid end tilt value");
    _timelapseSettings.endTiltAngle = 26;
    XCTAssertEqual(_timelapseSettings.endTiltAngle, 10, @"Invalid end tilt value");
}

#pragma mark - Save & Restore

- (void)testSavingIsCorrect
{
    _timelapseSettings.stepCount = 1000;
    _timelapseSettings.stepSize = 0.11;
    _timelapseSettings.recordingTime = 200;
    _timelapseSettings.clockwiseDirection = YES;
    _timelapseSettings.startTiltAngle = 10;
    _timelapseSettings.endTiltAngle = 24;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_timelapseSettings];
    _timelapseSettings = (SWTimelapseSettings *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqual(_timelapseSettings.stepCount, 1000, @"Invalid distance value after save & restore");
    XCTAssertEqualWithAccuracy(_timelapseSettings.stepSize, 0.11, FLT_EPSILON, @"Invalid stepSize value after save & restore");
    XCTAssertEqual(_timelapseSettings.clockwiseDirection, YES, @"Invalid clockwiseDirection value after save & restore");
    XCTAssertEqual(_timelapseSettings.recordingTime, 200, @"Invalid recordingTime value after save & restore");
    XCTAssertEqual(_timelapseSettings.startTiltAngle, 10, @"Invalid startTiltAngle value after save & restore");
    XCTAssertEqual(_timelapseSettings.endTiltAngle, 24, @"Invalid endTiltAngle value after save & restore");
}

@end
