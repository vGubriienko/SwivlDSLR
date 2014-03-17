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
    XCTAssertEqual(_timelapseSettings.distance, (NSInteger)180, @"Invalid distance value");
    _timelapseSettings.distance = -1;
    XCTAssertEqual(_timelapseSettings.distance, (NSInteger)180, @"Invalid distance value");
    _timelapseSettings.distance = 361;
    XCTAssertEqual(_timelapseSettings.distance, (NSInteger)180, @"Invalid distance value");
}

- (void)testDistanceReducesStepSize
{
    _timelapseSettings.distance = 180;
    _timelapseSettings.stepSize = 11;
    _timelapseSettings.distance = 5;
    
    XCTAssertTrue(_timelapseSettings.stepSize <= _timelapseSettings.distance, @"StepSize is bigger than distance");
}

- (void)testDistanceRecalculatesOnlyTimeBtwnPictures
{
    _timelapseSettings.distance = 180;
    _timelapseSettings.stepSize = 11;
    
    NSDateComponents *recordingTime = [[NSDateComponents alloc] init];
    recordingTime.hour = 0;
    recordingTime.minute = 15;
    recordingTime.second = 0;
    _timelapseSettings.recordingTime = recordingTime;
    
    CGFloat prevTimeBtwnPictures = _timelapseSettings.timeBetweenPictures;
    _timelapseSettings.distance = 99;
    
    XCTAssertNotEqual(_timelapseSettings.timeBetweenPictures, prevTimeBtwnPictures, @"TimeBetweenPictures wasn't changed after setting new distance");
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, (NSInteger)100, @"Incorrect timeBetweenPictures time after setting distance");
    
    XCTAssertEqual(_timelapseSettings.recordingTime.hour, 0, @"RecordingTime was changed after setting distance");
    XCTAssertEqual(_timelapseSettings.recordingTime.minute, (NSInteger)15, @"RecordingTime was changed after setting distance");
    XCTAssertEqual(_timelapseSettings.recordingTime.second, (NSInteger)0, @"RecordingTime was changed after setting distance");
}

#pragma StepSize

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
    
    NSDateComponents *recordingTime = [[NSDateComponents alloc] init];
    recordingTime.hour = 0;
    recordingTime.minute = 15;
    recordingTime.second = 0;
    _timelapseSettings.recordingTime = recordingTime;
    
    CGFloat prevTimeBtwnPictures = _timelapseSettings.timeBetweenPictures;

    _timelapseSettings.stepSize = 11;
    
    XCTAssertNotEqual(_timelapseSettings.timeBetweenPictures, prevTimeBtwnPictures, @"TimeBetweenPictures wasn't changed after setting new stepSize");
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, (NSInteger)50, @"Incorrect timeBetweenPictures time after setting step size");
    
    XCTAssertEqual(_timelapseSettings.recordingTime.hour, 0, @"RecordingTime was changed after setting stepSize");
    XCTAssertEqual(_timelapseSettings.recordingTime.minute, (NSInteger)15, @"RecordingTime was changed after setting stepSize");
    XCTAssertEqual(_timelapseSettings.recordingTime.second, (NSInteger)0, @"RecordingTime was changed after setting stepSize");
}

#pragma mark - Time between pictures

- (void)testTimeBtwnPicturesRecalculatesRecordingTime
{
    _timelapseSettings.stepSize = 11;
    _timelapseSettings.distance = 99;
    _timelapseSettings.timeBetweenPictures = 50;
    
    XCTAssertEqual(_timelapseSettings.recordingTime.hour, (NSInteger)0, @"Incorrect recordingTime after setting timeBetweenPictures");
    XCTAssertEqual(_timelapseSettings.recordingTime.minute, (NSInteger)7, @"Incorrect recordingTime after setting timeBetweenPictures");
    XCTAssertEqual(_timelapseSettings.recordingTime.second, (NSInteger)30, @"Incorrect recordingTime after setting timeBetweenPictures");
}

#pragma mark - Recording time

- (void)testRecordingTimeRecalculatesTimeBtwnPictures
{
    NSDateComponents *newRecordingTime = [[NSDateComponents alloc] init];
    newRecordingTime.hour = 0;
    newRecordingTime.minute = 30;
    newRecordingTime.second = 0;
    
    _timelapseSettings.distance = 198;
    _timelapseSettings.stepSize = 11;
    _timelapseSettings.recordingTime = newRecordingTime;
    
    XCTAssertEqual(_timelapseSettings.timeBetweenPictures, 100.0, @"Incorrect timeBetweenPictures time after setting recordingTime");
}

@end
