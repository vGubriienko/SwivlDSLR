//
//  SettingsViewController.m
//  SwivlDSLR
//
//  Created by Sergei Me (mer.sergei@gmai.com) on 4/10/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWSettingsController.h"

#import "SWAppDelegate.h"
#import "SWDSLRConfiguration.h"
#import "SWBatteryLevelView.h"

#import "MVYSideMenuController.h"
#import <Swivl2Lib/SwivlCommonLib.h>

#define DOCK_FW_VERSION_UNREPORTED  @"Dock Doesn't Report FW Version"

@interface SWSettingsController() <UITextFieldDelegate>
{
    __weak IBOutlet UILabel *_appVersion;
    __weak IBOutlet UILabel *_fwVersion;
    __weak IBOutlet UILabel *_DSLRConfiguration;
    __weak IBOutlet SWBatteryLevelView *_markerLevelView;
    __weak IBOutlet SWBatteryLevelView *_baseLevelView;
    __weak IBOutlet UISegmentedControl *_cameraInterface;
    IBOutlet UITableViewCell *_driverUSBView;
    NSString *_firmwareVersion;
}

@end

@implementation SWSettingsController

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    NSString *savedFirmwareVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"SwivlSettingsSavedFirmwareVersionKey"];
    _firmwareVersion = savedFirmwareVersion ? savedFirmwareVersion : DOCK_FW_VERSION_UNREPORTED;
    
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    _appVersion.text = bundleVersion;
    
    _cameraInterface.selectedSegmentIndex = swAppDelegate.currentCameraInterface;
    [self onCaptureInterfaceValueChanged];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-white"]
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(menuButtonPressed)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInterfaceElements)
                                                 name:AVSandboxSwivlDockAttached
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInterfaceElements)
                                                 name:AVSandboxSwivlDockDetached
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInterfaceElements)
                                                 name:AVSandboxBaseBatteryLevelChanged
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInterfaceElements)
                                                 name:AVSandboxMarkerBatteryLevelChanged
                                               object:nil];
    [self updateInterfaceElements];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.hidesBackButton = YES;
    
    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];

    [self updateInterfaceElements];
}

#pragma mark - IBActions

- (IBAction)onCaptureInterfaceValueChanged
{
    swAppDelegate.currentCameraInterface = _cameraInterface.selectedSegmentIndex;
    [self cell:_driverUSBView setHidden: (swAppDelegate.currentCameraInterface != SWCameraInterfaceUSB)];
}

- (void)menuButtonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SW_NEED_SHOW_SIDE_BAR_NOTIFICATION object:self];
}

#pragma mark - Interface update

- (void)updateInterfaceElements
{
    _DSLRConfiguration.text = [swAppDelegate.currentDSLRConfiguration name];
    
    if(swAppDelegate.swivl.swivlConnected)
    {
        NSLog(@"Marker: %d, Base: %d", swAppDelegate.swivl.markerBatteryLevel, swAppDelegate.swivl.baseBatteryLevel);
        
        _baseLevelView.showPercentages = YES;
        _baseLevelView.level = swAppDelegate.swivl.baseBatteryLevel;
        
        if (swAppDelegate.swivl.primaryMarkerConnected) {
            _markerLevelView.showPercentages = YES;
            _markerLevelView.level = swAppDelegate.swivl.markerBatteryLevel;
        } else {
            _markerLevelView.showPercentages = NO;
            _markerLevelView.level = 0;
        }
        
        if(![swAppDelegate.swivl.dockFWVersion isEqualToString:DOCK_FW_VERSION_UNREPORTED]) {
            _firmwareVersion = swAppDelegate.swivl.dockFWVersion;
            [[NSUserDefaults standardUserDefaults] setObject:_firmwareVersion forKey:@"SwivlSettingsSavedFirmwareVersionKey"];
        } 
        _fwVersion.text = _firmwareVersion;
        _fwVersion.hidden = NO;
    }
    else
    {
        _markerLevelView.showPercentages = NO;
        _markerLevelView.level = 0;
        _baseLevelView.showPercentages = NO;
        _baseLevelView.level = 0;
        _fwVersion.hidden = YES;
    }
}

#pragma mark - Custom Table modifications

- (void)cell:(UITableViewCell *)cell setHidden:(BOOL)hidden
{
    if (hidden) {
        [(ABStaticTableViewController*)self deleteRowsAtIndexPaths:@[[self indexPathForCustomCell:cell]] withRowAnimation:UITableViewRowAnimationMiddle];
    } else {
        [(ABStaticTableViewController*)self insertRowsAtIndexPaths:@[[self indexPathForCustomCell:cell]] withRowAnimation:UITableViewRowAnimationMiddle];
    }
}

- (NSIndexPath *)indexPathForCustomCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath;
    //Draft indexPath // Can throw nil exeption
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if (cell == _driverUSBView) {
        indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    }
    
    return indexPath;
}

- (BOOL)isCellVisible:(UITableViewCell *)cell
{
    return [self isRowVisible:[self indexPathForCustomCell:cell]];
}

#pragma mark - 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
