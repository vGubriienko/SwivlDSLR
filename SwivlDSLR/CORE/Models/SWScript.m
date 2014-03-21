//
//  SWScript.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/20/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWScript.h"

#import "SWTimelapseSettings.h"

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
    NSInteger holdShutterTime = 2000;
    NSInteger protectionPause = 500;
    NSInteger timeBtwPictures = self.timelapseSettings.timeBetweenPictures * 1000 - holdShutterTime - protectionPause;
    NSInteger stepSize = self.timelapseSettings.stepSize * 728;
    
    NSString *script = [NSString stringWithFormat:  @"1:%x, 1M %x, 2M %x, 3M %x, 4M F(      \
                                                    2:T4L+9M 0, %x, 7D0, 5, 0, AR           \
                                                    3:AL3=                                  \
                                                    4:T9L-4< F( 1L1-,5= 1M2@                \
                                                    5:.                                     \
                                                    ;shutter                                \
                                                    F:FM 7S T2L+EM                          \
                                                    E:TEL-E< 3S T3L+EM                      \
                                                    D:TEL-D< FL)",
                        self.timelapseSettings.stepCount, holdShutterTime, protectionPause, timeBtwPictures, stepSize];
    return script;
}

- (BOOL)isFinished
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.second = self.timelapseSettings.recordingTime;
    
    NSDate *finishDate = [[NSCalendar currentCalendar] dateByAddingComponents:comps
                                                                       toDate:self.startDate options:(0)];
    NSComparisonResult result = [finishDate compare:[NSDate date]];
    return result == NSOrderedAscending;
}

@end
