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

@interface SWScript : NSObject

@property (nonatomic, strong) SWTimelapseSettings *timelapseSettings;
@property (nonatomic, strong) SWDSLRConfiguration *dslrConfiguration;
@property (nonatomic, assign) SWCameraInterface connectionType;
@property (nonatomic, assign) SWScriptType scriptType;
@property (nonatomic, strong) NSDate *startDate;

- (NSString *)generateScript;
- (BOOL)isRunningFromStartDate;

@end
