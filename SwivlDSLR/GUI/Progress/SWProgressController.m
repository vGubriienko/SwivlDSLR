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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startProgress)
                                                 name:AVSandboxScriptProgressNeedStartNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_progressTimer invalidate];
    _progressTimer = nil;
    
    [super viewWillDisappear:animated];
}

- (void)startProgress
{
    if (!_progressTimer) {
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    }
}

- (void)tick
{
    NSTimeInterval timePast = [[NSDate date] timeIntervalSinceDate:self.script.startDate];
    
    NSTimeInterval progress = timePast / [self.script scriptDuration];
    if (progress > 1) {
        _timeLabel.hidden = YES;
        [_progressTimer invalidate];
        _progressTimer = nil;
        progress = 1;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AVSandboxScriptProgressDidFinishNotification object:self];
    }
    _progressView.progress = progress;
    
    NSTimeInterval timeLeft = [self.script scriptDuration] - timePast;
    SWTimeComponents timeComps = SWTimeComponentsMake(timeLeft);
    _timeLabel.text = [NSString stringWithFormat:@"%.2li:%.2li:%.2li", (long)timeComps.hours, (long)timeComps.minutes, (long)timeComps.seconds];
}

#pragma mark -

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
