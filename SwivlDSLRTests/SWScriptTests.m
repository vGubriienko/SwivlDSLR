//
//  SWScriptTests.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 5/13/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "SWScript.h"
#import "SWDSLRConfiguration.h"
#import "SWTimelapseSettings.h"

@interface SWScriptTests : XCTestCase
{
    id _timeLapseSettings;
    id _timeLapseSettingsClockWiseDirection;

    id _cameraConfiguration1;
    id _cameraConfiguration2;
    
    SWScript *_script;
}
@end

@implementation SWScriptTests

- (void)setUp
{
    [super setUp];

    _timeLapseSettings = [OCMockObject mockForClass:[SWTimelapseSettings class]];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((CGFloat)10.0)] stepSize];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((NSInteger)10)] stepCount];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((NSInteger)4)] timeBetweenPictures];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((NSInteger)36)] recordingTime];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((NSInteger)0)] startTiltAngle];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((NSInteger)25)] endTiltAngle];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((NSInteger)1)] exposure];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE(NO)] clockwiseDirection];

    _timeLapseSettingsClockWiseDirection = [OCMockObject mockForClass:[SWTimelapseSettings class]];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((CGFloat)0.11)] stepSize];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((NSInteger)2)] stepCount];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((NSInteger)7)] timeBetweenPictures];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((NSInteger)7)] recordingTime];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((NSInteger)-12)] startTiltAngle];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((NSInteger)12)] endTiltAngle];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((NSInteger)2)] exposure];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE(YES)] clockwiseDirection];
    
    _cameraConfiguration1 = [OCMockObject mockForClass:[SWDSLRConfiguration class]];
    [[[_cameraConfiguration1 stub] andReturn:@"Canon1"] name];
    [[[_cameraConfiguration1 stub] andReturn:@[@"910F"]] ptpCommands];
    
    _cameraConfiguration2 = [OCMockObject mockForClass:[SWDSLRConfiguration class]];
    [[[_cameraConfiguration2 stub] andReturn:@"Canon2"] name];
    [[[_cameraConfiguration2 stub] andReturn:@[@"9128", @"9129"]] ptpCommands];
    
    _script = [SWScript new];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testScriptDurationIsRecordingTimePlusTimeForStartPosition
{
    _script.timelapseSettings = _timeLapseSettings;
    XCTAssertEqual([_script scriptDuration], 40, @"Wrong scriptDuration");
}

- (void)testScriptDurationIsRecordingTimePlusTimeForStartPosition2
{
    _script.timelapseSettings = _timeLapseSettingsClockWiseDirection;
    XCTAssertEqual([_script scriptDuration], 11, @"Wrong scriptDuration");
}

- (void)testGenerateScriptForTriggerShot
{
    _script.connectionType = SWCameraInterfaceTrigger;
    _script.scriptType = SWScriptTypeShot;
    
    NSString *expectedScript = @"1:7ST7D0+1M2:T1L-2<3S.\0";
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForTriggerTimelapse
{
    _script.connectionType = SWCameraInterfaceTrigger;
    _script.scriptType = SWScriptTypeTimelapse;
    _script.timelapseSettings = _timeLapseSettings;
    
    NSString *expectedScript = @"1:9,0MBB8,1M194%,2M320,3M0,4M160,5M1F4,6M1F4,7MFA0,8M8L3L4L6,1,9R2:9L2=T3E8+8M3:T8L-3<F(4:0L7=T1L+8M1L3L2L5,0,9R1L3L5L5,1,CR5:9L5=CL5=6:T8L-6<F(0L1-0M4@7:.F:FM7ST6L+8ME:T8L-E<3ST7L+8MD:T8L-D<FL)\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForTriggerTimelapseWithClockwiseDirection
{
    _script.connectionType = SWCameraInterfaceTrigger;
    _script.scriptType = SWScriptTypeTimelapse;
    _script.timelapseSettings = _timeLapseSettingsClockWiseDirection;
    
    NSString *expectedScript = @"1:1,0M1388,1M4,2M320,3M5F0%,4MBE0,5M5DC,6M1F4,7MFA0,8M8L3L4L6,1,9R2:9L2=T3E8+8M3:T8L-3<F(4:0L7=T1L+8M1L3L2L5,0,9R1L3L5L5,1,CR5:9L5=CL5=6:T8L-6<F(0L1-0M4@7:.F:FM7ST6L+8ME:T8L-E<3ST7L+8MD:T8L-D<FL)\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForUSBShotWithOnePTPCommand
{
    _script.connectionType = SWCameraInterfaceUSB;
    _script.scriptType = SWScriptTypeShot;
    _script.dslrConfiguration = _cameraConfiguration1;
    
    NSString *expectedScript = @"1:910FP2019?1=.\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForUSBShotWithTwoPTPCommands
{
    _script.connectionType = SWCameraInterfaceUSB;
    _script.scriptType = SWScriptTypeShot;
    _script.dslrConfiguration = _cameraConfiguration2;
    
    NSString *expectedScript = @"1:3,0,B9128P2019?1=2001-2#3,A9129P2:.\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForUSBTimelapseWithOnePTPCommand
{
    _script.connectionType = SWCameraInterfaceUSB;
    _script.scriptType = SWScriptTypeTimelapse;
    _script.timelapseSettings = _timeLapseSettings;
    _script.dslrConfiguration = _cameraConfiguration1;
    
     NSString *expectedScript = @"1:9,0MFA0,1M194%,2M320,3M0,4M160,5MFA0,6M3E8,7M6L3L4L6,1,AR2:AL2=T3E8+8M3:T8L-3<F(4:0L7=1L3L2L5,0,AR1L3L5L5,1,DR5:AL5=DL5=6:T8L-6<F(0L1-0M4@7:.F:FMT1L+8MT7L+9MD:910FP2019?D=E:T9L-E<FL)\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForUSBTimelapseWithOnePTPCommandAndClockwiseDirection
{
    _script.connectionType = SWCameraInterfaceUSB;
    _script.scriptType = SWScriptTypeTimelapse;
    _script.timelapseSettings = _timeLapseSettingsClockWiseDirection;
    _script.dslrConfiguration = _cameraConfiguration1;
    
    NSString *expectedScript = @"1:1,0M1B58,1M4,2M320,3M5F0%,4MBE0,5MFA0,6M7D0,7M6L3L4L6,1,AR2:AL2=T3E8+8M3:T8L-3<F(4:0L7=1L3L2L5,0,AR1L3L5L5,1,DR5:AL5=DL5=6:T8L-6<F(0L1-0M4@7:.F:FMT1L+8MT7L+9MD:910FP2019?D=E:T9L-E<FL)\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForUSBTimelapseWithTwoPTPCommands
{
    _script.connectionType = SWCameraInterfaceUSB;
    _script.scriptType = SWScriptTypeTimelapse;
    _script.timelapseSettings = _timeLapseSettings;
    _script.dslrConfiguration = _cameraConfiguration2;
    
    NSString *expectedScript = @"1:9,0MFA0,1M194%,2M320,3M0,4M160,5MFA0,6M3E8,7M6L3L4L6,1,AR2:AL2=T3E8+8M3:T8L-3<F(4:0L7=1L3L2L5,0,AR1L3L5L5,1,DR5:AL5=DL5=6:T8L-6<F(0L1-0M4@7:.F:FMT1L+8MT7L+9MD:3,0,B9128P2019?D=2001-E#3,A9129PE:T9L-E<FL)\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForUSBTimelapseWithTwoPTPCommandsAndClockwiseDirection
{
    _script.connectionType = SWCameraInterfaceUSB;
    _script.scriptType = SWScriptTypeTimelapse;
    _script.timelapseSettings = _timeLapseSettingsClockWiseDirection;
    _script.dslrConfiguration = _cameraConfiguration2;
    
    NSString *expectedScript = @"1:1,0M1B58,1M4,2M320,3M5F0%,4MBE0,5MFA0,6M7D0,7M6L3L4L6,1,AR2:AL2=T3E8+8M3:T8L-3<F(4:0L7=1L3L2L5,0,AR1L3L5L5,1,DR5:AL5=DL5=6:T8L-6<F(0L1-0M4@7:.F:FMT1L+8MT7L+9MD:3,0,B9128P2019?D=2001-E#3,A9129PE:T9L-E<FL)\0";

    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

@end
