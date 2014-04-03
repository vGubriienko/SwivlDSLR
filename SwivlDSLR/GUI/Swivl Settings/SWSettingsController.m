//
//  SettingsViewController.m
//  AVSandbox
//
//  Created by Geoff Chatterton on 9/29/11.
//  Copyright 2011 Duff Research LLC. All rights reserved.
//

#import "SWSettingsController.h"

#import "SWAppDelegate.h"
#import <Swivl-iOS-SDK/SwivlCommonLib.h>

#import "MVYSideMenuController.h"

#define DOCK_FW_VERSION_UNREPORTED  @"Dock Doesn't Report FW Version"

@interface SWSettingsController() <UITextFieldDelegate>
{
    __weak IBOutlet UILabel *_appVersion;
    __weak IBOutlet UILabel *_fwVersion;
    __weak IBOutlet UIView *_markerLevelView;
    __weak IBOutlet UIView *_baseLevelView;
    __weak IBOutlet UISegmentedControl *_camereInterface;

    NSString *_firmwareVersion;
    NSTimer *_updateTimer;
}

@end

@implementation SWSettingsController

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    _baseLevelView.clipsToBounds = _markerLevelView.clipsToBounds = YES;
    
    NSString *savedFirmwareVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"SwivlSettingsSavedFirmwareVersionKey"];
    _firmwareVersion = savedFirmwareVersion ? savedFirmwareVersion : DOCK_FW_VERSION_UNREPORTED;
    
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    _appVersion.text = bundleVersion;
    
    _camereInterface.selectedSegmentIndex = swAppDelegate.currentCameraInterface;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedSwivlAttached) name:AVSandboxSwivlDockAttached object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedSwivlDetached) name:AVSandboxSwivlDockDetached object:nil];
    if (swAppDelegate.swivl.dockFWVersion) {
        [self notifiedSwivlAttached];
    } else {
        [self notifiedSwivlDetached];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
#warning Temp solution
    
    NSInteger sideBarWidth = self.sideMenuController.menuFrame.size.width;
    CGRect frame = self.navigationController.view.bounds;
    frame.origin.x = sideBarWidth;
    frame.size.width -= sideBarWidth;
    self.view.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated
{
    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_updateTimer invalidate];
}

#pragma mark - IBActions

- (IBAction)onCaptureInterfaceValueChanged
{
    swAppDelegate.currentCameraInterface = _camereInterface.selectedSegmentIndex;
}

#pragma mark - Interface update

- (void)setBatteryLevel:(signed char)level forView:(UIView *)view
{
    level = MIN(100, level);
    level = MAX(0, level);
    
    NSInteger maxViewWidth = 109;
    CGRect frame = view.frame;
    frame.size.width = (maxViewWidth * level) / 100;
    view.frame = frame;
}

- (NSString *)hhmmss:(NSTimeInterval)interval // convert NSTimeInterval into a human-friendly string
{
    int seconds = (int)(interval + 0.5);
    
    int hh = seconds / 3600;
    seconds = seconds % 3600;
    int mm = seconds / 60;
    seconds = seconds % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hh, mm, seconds];
}

- (void)updateInterfaceElements
{
    if(swAppDelegate.swivl.swivlConnected)
    {
        NSLog(@"Marker: %d, Base: %d", swAppDelegate.swivl.markerBatteryLevel, swAppDelegate.swivl.baseBatteryLevel);
        
        [self setBatteryLevel:swAppDelegate.swivl.markerBatteryLevel forView:_markerLevelView];
        [self setBatteryLevel:swAppDelegate.swivl.baseBatteryLevel forView:_baseLevelView];
        
        if(![swAppDelegate.swivl.dockFWVersion isEqualToString:DOCK_FW_VERSION_UNREPORTED])
        {
            _firmwareVersion = swAppDelegate.swivl.dockFWVersion;
            [[NSUserDefaults standardUserDefaults] setObject:_firmwareVersion forKey:@"SwivlSettingsSavedFirmwareVersionKey"];
        } 
        _fwVersion.text = _firmwareVersion;
        _fwVersion.hidden = NO;
    }
    else
    {
        [self setBatteryLevel:0 forView:_markerLevelView];
        [self setBatteryLevel:0 forView:_baseLevelView];
        _fwVersion.hidden = YES;
    }
}

#pragma mark - Notifications

- (void)notifiedSwivlAttached
{
    [self updateInterfaceElements];
    
    [_updateTimer invalidate];
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                    target:self
                                                  selector:@selector(updateInterfaceElements)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)notifiedSwivlDetached
{
    [_updateTimer invalidate];
    
    [self updateInterfaceElements];
}

#pragma mark - 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_updateTimer invalidate];
}

@end
