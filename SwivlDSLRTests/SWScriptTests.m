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
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((NSInteger)90)] distance];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((CGFloat)10.0)] stepSize];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((NSInteger)9)] stepCount];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((CGFloat)36.0)] recordingTime];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE((CGFloat)4.0)] timeBetweenPictures];
    [[[_timeLapseSettings stub] andReturnValue:OCMOCK_VALUE(NO)] clockwiseDirection];

    _timeLapseSettingsClockWiseDirection = [OCMockObject mockForClass:[SWTimelapseSettings class]];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((NSInteger)0.11)] distance];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((CGFloat)0.11)] stepSize];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((NSInteger)1)] stepCount];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((CGFloat)7.5)] recordingTime];
    [[[_timeLapseSettingsClockWiseDirection stub] andReturnValue:OCMOCK_VALUE((CGFloat)7.5)] timeBetweenPictures];
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
    
    NSString *expectedScript = @"1:9,1M7D0,2M1F4,3M5DC,4MF(2:T4L+9M0,7D0,16C%,5,0,AR3:AL3=4:T9L-4<F(1L1-,5=1M2@5:.F:FM7ST2L+EME:TEL-E<3ST3L+EMD:TEL-D<FL)\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForTriggerTimelapseWithClockwiseDirection
{
    _script.connectionType = SWCameraInterfaceTrigger;
    _script.scriptType = SWScriptTypeTimelapse;
    _script.timelapseSettings = _timeLapseSettingsClockWiseDirection;
    
    NSString *expectedScript = @"1:1,1M7D0,2M1F4,3M1388,4MF(2:T4L+9M0,7D0,4,5,0,AR3:AL3=4:T9L-4<F(1L1-,5=1M2@5:.F:FM7ST2L+EME:TEL-E<3ST3L+EMD:TEL-D<FL)\0";
    
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
    
    NSString *expectedScript = @"1:9,1MFA0,2MT2L+9MF(2:0,7D0,16C%,5,0,AR3:AL3=4:T9L-4<T2L+9MF(1L1-,5=1M2@5:.F:FMD:910FP2019?D=E:FL)\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForUSBTimelapseWithOnePTPCommandAndClockwiseDirection
{
    _script.connectionType = SWCameraInterfaceUSB;
    _script.scriptType = SWScriptTypeTimelapse;
    _script.timelapseSettings = _timeLapseSettingsClockWiseDirection;
    _script.dslrConfiguration = _cameraConfiguration1;
    
    NSString *expectedScript = @"1:1,1M1D4C,2MT2L+9MF(2:0,7D0,4,5,0,AR3:AL3=4:T9L-4<T2L+9MF(1L1-,5=1M2@5:.F:FMD:910FP2019?D=E:FL)\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForUSBTimelapseWithTwoPTPCommands
{
    _script.connectionType = SWCameraInterfaceUSB;
    _script.scriptType = SWScriptTypeTimelapse;
    _script.timelapseSettings = _timeLapseSettings;
    _script.dslrConfiguration = _cameraConfiguration2;
    
    NSString *expectedScript = @"1:9,1MFA0,2MT2L+9MF(2:0,7D0,16C%,5,0,AR3:AL3=4:T9L-4<T2L+9MF(1L1-,5=1M2@5:.F:FMD:3,0,B9128P2019?D=2001-E#3,A9129PE:FL)\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

- (void)testGenerateScriptForUSBTimelapseWithTwoPTPCommandsAndClockwiseDirection
{
    _script.connectionType = SWCameraInterfaceUSB;
    _script.scriptType = SWScriptTypeTimelapse;
    _script.timelapseSettings = _timeLapseSettingsClockWiseDirection;
    _script.dslrConfiguration = _cameraConfiguration2;
    
    NSString *expectedScript = @"1:1,1M1D4C,2MT2L+9MF(2:0,7D0,4,5,0,AR3:AL3=4:T9L-4<T2L+9MF(1L1-,5=1M2@5:.F:FMD:3,0,B9128P2019?D=2001-E#3,A9129PE:FL)\0";
    
    NSString *resultScript = [_script generateScript];
    
    XCTAssertEqualObjects(expectedScript, resultScript, @"Generate script error");
}

@end
