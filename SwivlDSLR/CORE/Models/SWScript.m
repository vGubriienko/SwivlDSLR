//
//  SWScript.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/20/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWScript.h"
#import "SWScript+Template.h"

#import "SWTimelapseSettings.h"
#import "SWCameraConfiguration.h"

@implementation SWScript

#pragma mark - Init

- (instancetype)initWithTimelapseSettings:(SWTimelapseSettings *)timelapseSettings
{
    self = [super init];
    if (self) {
        _timelapseSettings = timelapseSettings;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self) {
        _startDate = [decoder decodeObjectForKey:@"startDate"];
        _timelapseSettings = [decoder decodeObjectForKey:@"timelapseSettings"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_startDate forKey:@"startDate"];
    [encoder encodeObject:_timelapseSettings forKey:@"timelapseSettings"];
}

#pragma mark - Public methods

- (NSString *)generateScript
{
    NSString *scriptStr;
    if (self.scriptType == SWScriptTypeTimelapse) {
        if (self.connectionType == SWCameraInterfaceUSB) {
            scriptStr = [self generateScriptForUSBTimelapse];
        } else if (self.connectionType == SWCameraInterfaceTrigger) {
            scriptStr = [self generateScriptForTriggerTimelapse];
        } else {
            NSAssert(NO, @"Invalid connection type (script)");
        }
    } else if (self.scriptType == SWScriptTypeShot) {
        if (self.connectionType == SWCameraInterfaceUSB) {
            scriptStr = [self generateScriptForUSBShot];
        } else if (self.connectionType == SWCameraInterfaceTrigger) {
            scriptStr = [self generateScriptForTriggerShot];
        } else {
            NSAssert(NO, @"Invalid connection type (script)");
        }
    } else {
        NSAssert(NO, @"Invalid script type");
    }
    
    return [scriptStr stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (BOOL)isRunningFromStartDate
{
    if (!self.startDate) {
        return YES;
    }
    
    CGFloat timePast = [[NSDate date] timeIntervalSinceDate:self.startDate];
    return timePast < self.timelapseSettings.recordingTime;
}

- (NSString *)generateScriptForTriggerTimelapse
{
    NSInteger holdShutterTime = 2000;
    NSInteger protectionPause = 500;
    NSInteger timeBtwPictures = self.timelapseSettings.timeBetweenPictures * 1000 - holdShutterTime - protectionPause;
    if (timeBtwPictures < 0) {
        timeBtwPictures = 0;
    }
    
    NSInteger stepSize = (self.timelapseSettings.stepSize / 0.11) * 4;
    NSInteger speed = 2000; //MAX
    NSString *direction = self.timelapseSettings.clockwiseDirection ? @"" : @"%";
    
    NSString *script = [NSString stringWithFormat: [self scriptTemplateForTriggerTimelapse],
                        (long)self.timelapseSettings.stepCount,
                        (long)holdShutterTime,
                        (long)protectionPause,
                        (long)timeBtwPictures,
                        (long)speed,
                        (long)stepSize,
                        direction];
    
    return script;

}

- (NSString *)generateScriptForUSBTimelapse
{
    NSInteger timeBtwPictures = self.timelapseSettings.timeBetweenPictures * 1000;
    NSInteger stepSize = (self.timelapseSettings.stepSize / 0.11) * 4;
    NSString *direction = self.timelapseSettings.clockwiseDirection ? @"" : @"%";
    NSInteger speed = 2000; //MAX

    NSString *scriptTemplate;
    NSArray *ptpCommands = self.cameraConfiguration.ptpCommands;
    if (self.cameraConfiguration.ptpCommands.count == 1) {
        scriptTemplate = [self scriptTemplateForUSBTimelapse:ptpCommands[0]];
    } else if (self.cameraConfiguration.ptpCommands.count == 2) {
        scriptTemplate = [self scriptTemplateForUSBTimelapse:ptpCommands[0] ptpCommand2:ptpCommands[1]];
    }
    
    NSString *script = [NSString stringWithFormat:scriptTemplate,
                        (long)self.timelapseSettings.stepCount,
                        (long)timeBtwPictures,
                        (long)speed,
                        (long)stepSize,
                        direction];
    return script;
}

- (NSString *)generateScriptForTriggerShot
{
    NSString *script = [self scriptTemplateForTriggerShot];
    return script;
}

- (NSString *)generateScriptForUSBShot
{
    NSString *script;
    NSArray *ptpCommands = self.cameraConfiguration.ptpCommands;
    if (self.cameraConfiguration.ptpCommands.count == 1) {
        script = [self scriptTemplateForUSBTimelapse:ptpCommands[0]];
    } else if (self.cameraConfiguration.ptpCommands.count == 2) {
        script = [self scriptTemplateForUSBTimelapse:ptpCommands[0] ptpCommand2:ptpCommands[1]];
    }
    
    return script;
}

@end
