//
//  SWScript.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/20/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWTimelapseSettings;
@class SWDSLRConfiguration;

#define SW_SCRIPT_TIME_FOR_START_TILT 4.0

@interface SWScript : NSObject

@property (nonatomic, strong) SWTimelapseSettings *timelapseSettings;
@property (nonatomic, strong) SWDSLRConfiguration *dslrConfiguration;
@property (nonatomic, assign) SWScriptType scriptType;
@property (nonatomic, strong) NSDate *startDate;

- (NSString *)generateScriptForInterface:(SWCameraInterface)cameraInterface;

- (BOOL)isRunningFromStartDate;
- (NSTimeInterval)scriptDuration;

@end
