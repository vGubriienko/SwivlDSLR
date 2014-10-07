//
//  SWTimelapseSettings.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/5/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SW_TIMELAPSE_MAX_TIME_BTWN_PICTURES 23 * 3600 + 59 * 60 + 59    //23 hours, 59 minutes, 59 seconds

#define SW_TIMELAPSE_MIN_EXPOSURE_USB 1
#define SW_TIMELAPSE_MAX_EXPOSURE 1000

#define SW_TIMELAPSE_MIN_STEPCOUNT 2
#define SW_TIMELAPSE_MAX_STEPCOUNT 3000

#define SW_TIMELAPSE_MIN_TILT -12
#define SW_TIMELAPSE_MAX_TILT 12

typedef struct SWTimeComponents SWTimeComponents;

struct SWTimeComponents {
    NSInteger hours;
    NSInteger minutes;
    NSTimeInterval seconds;
};
typedef struct SWTimeComponents SWTimeComponents;

static inline SWTimeComponents SWTimeComponentsMake(NSTimeInterval seconds)
{
    SWTimeComponents timeComps;
    timeComps.hours = seconds / 3600;
    timeComps.minutes = (seconds - timeComps.hours * 3600) / 60;
    timeComps.seconds = seconds - timeComps.hours * 3600 - timeComps.minutes * 60;
    return timeComps;
}

@interface SWTimelapseSettings : NSObject

@property (nonatomic, readonly) NSInteger distance;                     //(stepCount - 1) * stepSize
@property (nonatomic, readonly) NSTimeInterval recordingTime;           //timeBetweenPictures * (stepCount - 1)
@property (nonatomic, assign) NSTimeInterval timeBetweenPictures;
@property (nonatomic, readonly) NSTimeInterval holdShutterTime;         //Used only if SWCameraInterfaceTrigger (readonly now, custom in the future)
@property (nonatomic, assign) NSTimeInterval exposure;
@property (nonatomic, readonly) NSTimeInterval minimumExposure;
@property (nonatomic, readonly) NSTimeInterval minimumTimeBetweenPictures;
@property (nonatomic, assign) CGFloat stepSize;
@property (nonatomic, assign) BOOL clockwiseDirection;
@property (nonatomic, assign) NSInteger startTiltAngle;
@property (nonatomic, assign) NSInteger endTiltAngle;
@property (nonatomic, assign) NSInteger stepCount;

@property (nonatomic, assign) SWCameraInterface cameraInterface;

+ (NSArray *)availableStepSizes;

- (SWTimeComponents)timeBetweenPicturesComponents;
- (SWTimeComponents)recordingTimeComponents;
- (void)setTimeBetweenPicturesWithComponents:(SWTimeComponents)timeBetweenPicturesComponents;

@end
