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
    NSString *scriptStr;
    if (self.type == SWCameraInterfaceUSB) {
        scriptStr = [self generateScriptForUSB];
    } if (self.type == SWCameraInterfaceTrigger) {
        scriptStr = [self generateScriptForTrigger];
    } else {
        NSAssert(NO, @"Invalid script type");
    }
    
    return [scriptStr stringByReplacingOccurrencesOfString:@" " withString:@""];
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

- (NSString *)generateScriptForTrigger
{
    NSInteger holdShutterTime = 2000;
    NSInteger protectionPause = 500;
    NSInteger timeBtwPictures = self.timelapseSettings.timeBetweenPictures * 1000 - holdShutterTime - protectionPause;
    NSInteger stepSize = self.timelapseSettings.stepSize * 728;
    NSString *direction = self.timelapseSettings.clockwiseDirection ? @"" : @"%";
    
    NSString *script = [NSString stringWithFormat:
                        
                        @"1:%x, 1M %x, 2M %x, 3M %x, 4M F(      \
                        2:T4L+9M 0, %x%@, 7D0, 5, 0, AR         \
                        3:AL3=                                  \
                        4:T9L-4< F( 1L1-,5= 1M2@                \
                        5:.                                     \
                        ;shutter                                \
                        F:FM 7S T2L+EM                          \
                        E:TEL-E< 3S T3L+EM                      \
                        D:TEL-D< FL)\0",
                        self.timelapseSettings.stepCount, holdShutterTime, protectionPause, timeBtwPictures, stepSize, direction];
    return script;

}

- (NSString *)generateScriptForUSB
{
    NSInteger timeBtwPictures = self.timelapseSettings.timeBetweenPictures * 1000;
    NSInteger stepSize = self.timelapseSettings.stepSize * 728;
    NSString *direction = self.timelapseSettings.clockwiseDirection ? @"" : @"%";

    NSString *script = [NSString stringWithFormat:
                        @"1:%x, 1M %x, 2M T2L+9M F(             \
                        2:%x%@, 320, 7D0, 5, 0, AR              \
                        3:AL3=                                  \
                        4:T9L-4< T2L+9M F( 1L1-, 5= 1M2@        \
                        5:.                                     \
                        ;PTP shutter                            \
                        F:FM                                    \
                        D:3, 0, B9128P2019?D=2001-E#3, A9129P   \
                        E:FL)\0",
                        
                        self.timelapseSettings.stepCount,
                        timeBtwPictures,
                        stepSize,
                        direction];
    return script;
}

@end
