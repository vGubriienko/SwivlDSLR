//
//  SWScript.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/20/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWTimelapseSettings;
@class SWCameraConfiguration;

@interface SWScript : NSObject

- (instancetype)initWithTimelapseSettings:(SWTimelapseSettings *)timelapseSettings;

@property (nonatomic, readonly) SWTimelapseSettings *timelapseSettings;
@property (nonatomic, strong) SWCameraConfiguration *cameraConfiguration;
@property (nonatomic, assign) SWCameraInterface connectionType;
@property (nonatomic, assign) SWScriptType scriptType;
@property (nonatomic, strong) NSDate *startDate;

- (NSString *)generateScript;
- (BOOL)isRunningFromStartDate;

@end
