//
//  SWScript.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/20/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWTimelapseSettings.h"

@interface SWScript : NSObject

- (instancetype)initWithTimelapseSettings:(SWTimelapseSettings *)timelapseSettings;

@property (nonatomic, readonly) SWTimelapseSettings *timelapseSettings;
@property (nonatomic, strong) NSDate *startDate;

- (char *)scriptWithLength:(NSInteger *)length;
- (BOOL)isFinished;

@end
