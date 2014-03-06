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

- (void)testRecordingTimeIsCorrectAfterSettingTimeBtwnPictures
{
    _timelapseSettings.stepSize = 5;
    _timelapseSettings.distance = 360;
    _timelapseSettings.timeBetweenPictures = 3;
    
    //step count = 360 / 5 = 72
    //seconds: 72 * 3 = 216
    //216 seconds = 00:03:36
    XCTAssertEqual(_timelapseSettings.recordingTime.hour, (NSInteger)0, @"Incorrect recordingTime after setting timeBetweenPictures");
    XCTAssertEqual(_timelapseSettings.recordingTime.minute, (NSInteger)3, @"Incorrect recordingTime after setting timeBetweenPictures");
    XCTAssertEqual(_timelapseSettings.recordingTime.second, (NSInteger)36, @"Incorrect recordingTime after setting timeBetweenPictures");
}

- (void)testTimeBtwnPicturesIsCorrectAfterSettingRecordingTime
{
    NSDateComponents *newRecordingTime = [[NSDateComponents alloc] init];
    newRecordingTime.hour = 1;
    newRecordingTime.minute = 30;
    newRecordingTime.second = 45;
    
    _timelapseSettings.distance = 270;
    _timelapseSettings.stepSize = 2;
    _timelapseSettings.recordingTime = newRecordingTime;
    
    //step count = 270 / 2 = 135
    //seconds: 3600 + 30 * 60 + 45 = 5445
    //time btwn pictures = 5445 / 135  = 40,3333..
    XCTAssertEqual((NSInteger)_timelapseSettings.timeBetweenPictures, (NSInteger)40, @"Incorrect timeBetweenPictures time after setting recordingTime");
}

- (void)testRecordingTimeWasNotChangedAfterSettingStepSize
{
    NSDateComponents *recordingTime = [[NSDateComponents alloc] init];
    recordingTime.hour = 0;
    recordingTime.minute = 15;
    recordingTime.second = 30;
    
    _timelapseSettings.stepSize = 5;
    _timelapseSettings.distance = 360;
    _timelapseSettings.timeBetweenPictures = 3;
    _timelapseSettings.recordingTime = recordingTime;
    
    _timelapseSettings.stepSize = 10;
    XCTAssertEqual(_timelapseSettings.recordingTime.hour, (NSInteger)0, @"RecordingTime was changed after setting stepSize");
    XCTAssertEqual(_timelapseSettings.recordingTime.minute, (NSInteger)15, @"RecordingTime was changed after setting stepSize");
    XCTAssertEqual(_timelapseSettings.recordingTime.second, (NSInteger)30, @"RecordingTime was changed after setting stepSize");
}

- (void)testTimeBtwnPicturesIsCorrectAfterSettingStepSize
{
    NSDateComponents *newRecordingTime = [[NSDateComponents alloc] init];
    newRecordingTime.hour = 0;
    newRecordingTime.minute = 40;
    newRecordingTime.second = 15;
    
    _timelapseSettings.distance = 180;
    _timelapseSettings.stepSize = 1;
    _timelapseSettings.recordingTime = newRecordingTime;
    
    //step count = 180 / 1 = 180
    //seconds: 40 * 60 + 15 = 2415
    //time btwn pictures = 2415 / 180  = 13,41..
    XCTAssertEqual((NSInteger)_timelapseSettings.timeBetweenPictures, (NSInteger)13, @"Incorrect timeBetweenPictures time after setting recordingTime");
    
    _timelapseSettings.stepSize = 2;
    //step count = 180 / 2 = 90
    //time btwn pictures = 2415 / 90  = 26,83..
    XCTAssertEqual((NSInteger)_timelapseSettings.timeBetweenPictures, (NSInteger)26, @"Incorrect timeBetweenPictures time after setting stepSize");
}

@end
