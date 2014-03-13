//
//  SWSideBar.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/12/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWSideBar.h"

typedef NS_ENUM(NSInteger, SWSideBarRow)
{
    SWSideBarRowTimeLapse = 0,
    SWSideBarRowSwivl,
    SWSideBarRowHelp,
    SWSideBarRowCount,
};

@interface SWSideBar ()
{
    SWSideBarRow _lastSelectedRow;
}
@end

@implementation SWSideBar

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _lastSelectedRow = SWSideBarRowTimeLapse;
    
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
}

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return SWSideBarRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SWSideBarCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SWSideBarCell"];
    }
    
    NSArray *menuTitles = @[@"Timelapse", @"Swivl", @"Help"];
    cell.textLabel.text = menuTitles[indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _lastSelectedRow && _lastSelectedRow != SWSideBarRowTimeLapse) {
        return;
    }
    
    switch (indexPath.row) {
            
        case SWSideBarRowTimeLapse:
        {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:SW_NEED_HIDE_SIDE_BAR_NOTIFICATION object:nil];
            break;
        }
            
        case SWSideBarRowSwivl:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SWSettingsController" bundle:nil];
            UIViewController *vc = [storyboard instantiateInitialViewController];
            
            [self.navigationController pushViewController:vc animated:NO];
            
            break;
        }
        case SWSideBarRowHelp:
        {
            break;
        }
    }
    
    _lastSelectedRow = indexPath.row;
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
