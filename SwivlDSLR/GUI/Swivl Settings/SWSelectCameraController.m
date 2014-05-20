//
//  SWSelectCameraController.m
//  SwivlDSLR
//
//  Created by Sergei Me (mer.sergei@gmai.com) on 5/12/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWSelectCameraController.h"

#import "SWAppDelegate.h"
#import "MVYSideMenuController.h"

@interface SWSelectCameraController()

@end

@implementation SWSelectCameraController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = NO;

    [[Countly sharedInstance] recordEvent:NSStringFromClass([self class]) segmentation:@{@"open":@YES} count:1];
    
    [super viewDidAppear:animated];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
