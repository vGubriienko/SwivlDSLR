//
//  SWSelectDriverController.m
//  SwivlDSLR
//
//  Created by Sergei Me (mer.sergei@gmai.com) on 5/12/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWSelectDriverController.h"

#import "SWAppDelegate.h"
#import "MVYSideMenuController.h"



@interface SWSelectDriverController()



@end

@implementation SWSelectDriverController

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [self loadUSBConfigurations];
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


#pragma mark - IBActions

- (IBAction)onCaptureInterfaceValueChanged
{
    [self loadUSBConfigurations];
}


#pragma mark - USB Drivers
- (void)loadUSBConfigurations
{
   
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [swAppDelegate.availableDSLRConfigurations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"USBDriverCell"];
    cell.textLabel.text = [swAppDelegate.availableDSLRConfigurations[indexPath.row] name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    swAppDelegate.currentDSLRConfiguration = swAppDelegate.availableDSLRConfigurations[indexPath.row];
}

#pragma mark - 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
