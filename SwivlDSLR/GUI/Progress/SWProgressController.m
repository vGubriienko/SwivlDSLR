//
//  SWProgressController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/27/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWProgressController.h"

#import "SWScript.h"
#import "SWTimelapseSettings.h"

#import "SWProgressView.h"
#import "Countly.h"

@interface SWProgressController()
{
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UIView *_progressViewContainer;

    SWProgressView *_progressView;
    NSTimer *_progressTimer;
}
@end

@implementation SWProgressController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _progressView = [[SWProgressView alloc] initWithFrame:self.view.bounds];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _progressView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:_progressView belowSubview:_timeLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(tick) userInfo:nil repeats:YES];

    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_progressTimer invalidate];
    
    [super viewWillDisappear:animated];
}

- (void)tick
{
    CGFloat timePast = [[NSDate date] timeIntervalSinceDate:self.script.startDate];
    
    CGFloat progress = timePast / self.script.timelapseSettings.recordingTime;
    if (progress > 1) {
        _timeLabel.hidden = YES;
        [_progressTimer invalidate];
        progress = 1;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AVSandboxScriptProgressDidFinishNotification object:self];
    }
    _progressView.progress = progress;
    
    CGFloat timeLeft = self.script.timelapseSettings.recordingTime - timePast;
    SWTimeComponents timeComps = SWTimeComponentsMake(timeLeft);
    _timeLabel.text = [NSString stringWithFormat:@"%.2li:%.2li:%.2li", (long)timeComps.hours, (long)timeComps.minutes, (long)timeComps.seconds];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
