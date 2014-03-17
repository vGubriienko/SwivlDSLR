//
//  SWTimelapseSettings.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/5/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SW_TIMELAPSE_MIN_DISTANCE 1
#define SW_TIMELAPSE_MAX_DISTANCE 360

@interface SWTimelapseSettings : NSObject

@property (nonatomic, assign) NSInteger distance;
@property (nonatomic, assign) CGFloat stepSize;
@property (nonatomic, assign) CGFloat timeBetweenPictures;
@property (nonatomic, assign) BOOL clockwiseDirection;
@property (nonatomic, strong) NSDateComponents *recordingTime;

+ (NSArray *)availableStepSizes;
+ (NSArray *)availableTimesBtwnPictures;
+ (NSDictionary *)availableRecordingTime;

@end
