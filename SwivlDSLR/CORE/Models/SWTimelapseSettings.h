//
//  SWTimelapseSettings.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/5/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWTimelapseSettings : NSObject

@property (nonatomic, assign) NSInteger distance;
@property (nonatomic, assign) NSInteger stepSize;
@property (nonatomic, assign) CGFloat timeBetweenPictures;
@property (nonatomic, assign) BOOL clockwiseDirection;
@property (nonatomic, strong) NSDateComponents *recordingTime;

//+ (NSArray *)availableStepSizes;
+ (NSArray *)availableTimesBtwnPictures;
+ (NSDictionary *)availableRecordingTime;

@end
