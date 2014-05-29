//
//  SWTimelapseSettings.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/5/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SW_TIMELAPSE_MIN_STEPCOUNT 1
#define SW_TIMELAPSE_MAX_STEPCOUNT 3000

#define SW_TIMELAPSE_MIN_TILT -25
#define SW_TIMELAPSE_MAX_TILT 25

typedef struct SWTimeComponents SWTimeComponents;

struct SWTimeComponents {
    NSInteger hours;
    NSInteger minutes;
    NSInteger seconds;
};
typedef struct SWTimeComponents SWTimeComponents;

static inline SWTimeComponents SWTimeComponentsMake(NSInteger seconds)
{
    SWTimeComponents timeComps;
    timeComps.hours = seconds / 3600;
    timeComps.minutes = (seconds - timeComps.hours * 3600) / 60;
    timeComps.seconds = seconds - timeComps.hours * 3600 - timeComps.minutes * 60;
    return timeComps;
}

@interface SWTimelapseSettings : NSObject

@property (nonatomic, readonly) NSInteger distance;             //stepCount * stepSize
@property (nonatomic, readonly) NSInteger recordingTime;        //timeBetweenPictures * stepCount
@property (nonatomic, assign) NSInteger timeBetweenPictures;
@property (nonatomic, assign) CGFloat stepSize;
@property (nonatomic, assign) BOOL clockwiseDirection;
@property (nonatomic, assign) NSInteger startTiltAngle;
@property (nonatomic, assign) NSInteger endTiltAngle;
@property (nonatomic, assign) NSInteger stepCount;

+ (NSArray *)availableStepSizes;
+ (NSDictionary *)timeRanges;

- (SWTimeComponents)timeBetweenPicturesComponents;
- (SWTimeComponents)recordingTimeComponents;
- (void)setTimeBetweenPicturesWithComponents:(SWTimeComponents)timeBetweenPicturesComponents;

@end
