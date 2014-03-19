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

#pragma mark - Distance

- (void)testDistanceHasValidInitValue
{
    XCTAssertTrue(_timelapseSettings.distance >= SW_TIMELAPSE_MIN_DISTANCE, @"Distance has invalid init value");
    XCTAssertTrue(_timelapseSettings.distance <= SW_TIMELAPSE_MAX_DISTANCE, @"Distance has invalid init value");
}

- (void)testDistanceDoesNotChangesAfterSettingInvalidValue
{
    _timelapseSettings.distance = 180;
    
    _timelapseSettings.distance = 0;
    XCTAssertEqual(_timelapseSettings.distance, 180, @"Invalid distance value");
    _timelapseSettings.distance = -1;
    XCTAssertEqual(_timelapseSettings.distance, 180, @"Invalid distance value");
    _timelapseSettings.distance = 361;
    XCTAssertEqual(_timelapseSettings.distance, 180, @"Invalid distance value");
}

- (void)testDistanceReducesStepSize
{
    _timelapseSettings.distance = 180;
    _timelapseSettings.stepSize = 11.0;
    _timelapseSettings.distance = 5;
    
    XCTAssertTrue(_timelapseSettings.stepSize <= _timelapseSettings.distance, @"StepSize is bigger than distance");
}

- (void)testDistanceRecalculatesOnlyTimeBtwnPictures
{
    _timelapseSettings.distance = 180;
    _timelapseSettings.stepSize = 11.0;
    _timelapseSettings.recordingTime = 900.0;
    
    CGFloat prevTimeBtwnPictures = _timelapseSettings.timeBetweenPictures;
    _timelapseSettings.distance = 99;
    
    XCTAssertNotEqual(_timelapseSettings.timeBetweenPictures, prevTimeBtwnPictures, @"TimeBetweenPictures wasn't changed after setting new distance");
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, 100.0, @"Incorrect timeBetweenPictures time after setting distance");
    
    XCTAssertEqual(_timelapseSettings.recordingTime, 900.0, @"RecordingTime was changed after setting distance");
}

#pragma mark - StepSize

- (void)testStepSizeHasValidInitValue
{
    NSNumber *stepSize = [NSNumber numberWithFloat:_timelapseSettings.stepSize];
    BOOL isStepSizeAvailable = [[SWTimelapseSettings availableStepSizes] containsObject:stepSize];
    XCTAssertTrue(isStepSizeAvailable, @"StepSize has invalid init value");
}

- (void)testStepSizeDoesNotChangesAfterSettingInvalidValue
{
    _timelapseSettings.stepSize = 11.0;
    
    _timelapseSettings.stepSize = 0.0;
    XCTAssertEqual(_timelapseSettings.stepSize, 11.0, @"Invalid stepSize value");
    _timelapseSettings.distance = -1.0;
    XCTAssertEqual(_timelapseSettings.stepSize, 11.0, @"Invalid stepSize value");
    _timelapseSettings.distance = 11.1;
    XCTAssertEqual(_timelapseSettings.stepSize, 11.0, @"Invalid stepSize value");
}

- (void)testStepSizeRecalculatesOnlyTimeBtwnPictures
{
    _timelapseSettings.stepSize = 0.11;
    _timelapseSettings.distance = 198;
    _timelapseSettings.recordingTime = 900.0;
    
    CGFloat prevTimeBtwnPictures = _timelapseSettings.timeBetweenPictures;

    _timelapseSettings.stepSize = 11.0;
    
    XCTAssertNotEqual(_timelapseSettings.timeBetweenPictures, prevTimeBtwnPictures, @"TimeBetweenPictures wasn't changed after setting new stepSize");
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, 50.0, @"Incorrect timeBetweenPictures time after setting step size");
    XCTAssertEqual(_timelapseSettings.recordingTime, 900.0, @"RecordingTime was changed after setting stepSize");
}

#pragma mark - Time between pictures

- (void)testTimeBtwnPicturesRecalculatesRecordingTime
{
    _timelapseSettings.stepSize = 11.0;
    _timelapseSettings.distance = 99;
    _timelapseSettings.timeBetweenPictures = 50.0;
    
    XCTAssertEqual(_timelapseSettings.recordingTime, 450.0, @"Incorrect recordingTime after setting timeBetweenPictures");
}

#pragma mark - Recording time

- (void)testRecordingTimeRecalculatesTimeBtwnPictures
{
    _timelapseSettings.distance = 198;
    _timelapseSettings.stepSize = 11.0;
    _timelapseSettings.recordingTime = 1800.0;
    
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, 100.0, @"Incorrect timeBetweenPictures time after setting recordingTime");
}

#pragma mark - Time components

- (void)testRecordingTimeComponents
{
    _timelapseSettings.recordingTime = 5145;
    SWTimeComponents timeComponents = [_timelapseSettings recordingTimeComponents];
    XCTAssertEqual(timeComponents.hours, 1, @"Incorrect recordingTime hours");
    XCTAssertEqual(timeComponents.minutes, 25, @"Incorrect recordingTime minutes");
    XCTAssertEqual(timeComponents.seconds, 45.0, @"Incorrect recordingTime seconds");
}

- (void)testTimeBetweenPicturesComponents
{
    _timelapseSettings.timeBetweenPictures = 1815.5;
    SWTimeComponents timeComponents = [_timelapseSettings timeBetweenPicturesComponents];
    XCTAssertEqual(timeComponents.hours, 0, @"Incorrect timeBetweenPictures hours");
    XCTAssertEqual(timeComponents.minutes, 30, @"Incorrect timeBetweenPictures minutes");
    XCTAssertEqual(timeComponents.seconds, 15.5, @"Incorrect timeBetweenPictures seconds");
}

- (void)testSetRecordingTimeWithComponents
{
    SWTimeComponents timeComponents;
    timeComponents.hours = 1;
    timeComponents.minutes = 10;
    timeComponents.seconds = 35.0;
    
    [_timelapseSettings setRecordingTimeWithComponents:timeComponents];
    
    XCTAssertEqual(_timelapseSettings.recordingTime, 4235.0, @"Incorrect timeBetweenPictures seconds");
}

- (void)testSetTimeBetweenPicturesWithComponents
{
    SWTimeComponents timeComponents;
    timeComponents.hours = 2;
    timeComponents.minutes = 0;
    timeComponents.seconds = 30.0;
    
    [_timelapseSettings setRecordingTimeWithComponents:timeComponents];
    
    XCTAssertEqual(_timelapseSettings.recordingTime, 7230.0, @"Incorrect timeBetweenPictures seconds");
}

@end
