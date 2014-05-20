//
//  SWTimelapseSettings.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/5/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SW_TIMELAPSE_MIN_STEPCOUNT 1
#define SW_TIMELAPSE_MAX_STEPCOUNT 3272

#define SW_TIMELAPSE_MIN_DISTANCE 1
#define SW_TIMELAPSE_MAX_DISTANCE 360

struct SWTimeComponents {
    NSInteger hours;
    NSInteger minutes;
    CGFloat seconds;
};
typedef struct SWTimeComponents SWTimeComponents;

static inline SWTimeComponents SWTimeComponentsMake(CGFloat seconds)
{
    SWTimeComponents timeComps;
    timeComps.hours = seconds / 3600;
    timeComps.minutes = (seconds - timeComps.hours * 3600) / 60;
    timeComps.seconds = seconds - timeComps.hours * 3600 - timeComps.minutes * 60;
    return timeComps;
}

@interface SWTimelapseSettings : NSObject

@property (nonatomic, readonly) NSInteger distance; //stepCount * stepSize
@property (nonatomic, assign) CGFloat stepSize;
@property (nonatomic, assign) BOOL clockwiseDirection;
@property (nonatomic, assign) CGFloat recordingTime;
@property (nonatomic, assign) CGFloat timeBetweenPictures;

@property (nonatomic, assign) NSInteger stepCount;

+ (NSArray *)availableStepSizes;
+ (NSDictionary *)timeRanges;

- (SWTimeComponents)recordingTimeComponents;
- (SWTimeComponents)timeBetweenPicturesComponents;
- (void)setRecordingTimeWithComponents:(SWTimeComponents)recordingTimeComponents;
- (void)setTimeBetweenPicturesWithComponents:(SWTimeComponents)timeBetweenPicturesComponents;

@end
