//
//  SWCameraConfigurationTests.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 5/13/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SWCameraConfiguration.h"

@interface SWCameraConfigurationTests : XCTestCase
{

}
@end

@implementation SWCameraConfigurationTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCameraConfigurationInitWithDictionarySaveDictionary
{
    NSDictionary *dictionary = @{@"name"        :       @"Canon",
                                 @"commands"    :       @[@"9128"]};
    
    SWCameraConfiguration *cameraConfig = [SWCameraConfiguration configurationWithDictionary:dictionary];
    
    XCTAssertEqualObjects(dictionary, cameraConfig.dictionary, @"Wrong configuration dictionary");
}

- (void)testCameraConfigurationInitWithDictionaryWithOneCommand
{
    NSDictionary *dictionary = @{@"name"        :       @"Canon",
                                 @"commands"    :       @[@"9128"]};
    
    SWCameraConfiguration *cameraConfig = [SWCameraConfiguration configurationWithDictionary:dictionary];

    XCTAssertEqualObjects(@"Canon", cameraConfig.name, @"Wrong configuration name");
    
    XCTAssertEqual(1, cameraConfig.ptpCommands.count, @"Wrong PTP commands count");
    XCTAssertEqualObjects(@"9128", cameraConfig.ptpCommands[0], @"Wrong PTP command");
}

- (void)testCameraConfigurationInitWithDictionaryWithTwoCommands
{
    NSDictionary *dictionary = @{@"name"        :       @"Canon",
                                 @"commands"    :       @[@"9128", @"9129"]};
    
    SWCameraConfiguration *cameraConfig = [SWCameraConfiguration configurationWithDictionary:dictionary];

    XCTAssertEqualObjects(@"Canon", cameraConfig.name, @"Wrong configuration name");
    
    XCTAssertEqual(2, cameraConfig.ptpCommands.count, @"Wrong PTP commands count");
    XCTAssertEqualObjects(@"9128", cameraConfig.ptpCommands[0], @"Wrong first PTP command");
    XCTAssertEqualObjects(@"9129", cameraConfig.ptpCommands[1], @"Wrong second PTP command");
}

- (void)testCameraConfigurationThrowsExceptionIfNoCommand
{
    NSDictionary *wrongDictionary = @{@"name"        :       @"Canon",
                                      @"commands"    :       @[]};
    
    XCTAssertThrows([SWCameraConfiguration configurationWithDictionary:wrongDictionary],
                    @"ConfigurationWithDictionary should throw exception if no PTP command");
}

- (void)testCameraConfigurationThrowsExceptionIfMoreCommand
{
    NSDictionary *wrongDictionary = @{@"name"        :       @"Canon",
                                      @"commands"    :       @[@"9128", @"9129", @"0000"]};
    
    XCTAssertThrows([SWCameraConfiguration configurationWithDictionary:wrongDictionary],
                    @"ConfigurationWithDictionary should throw exception if no PTP command");
}

@end
