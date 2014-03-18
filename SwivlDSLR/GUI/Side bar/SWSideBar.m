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

#define SW_SIDE_BAR_ROW_NAMES @"Timelapse", @"Swivl", @"Help"

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
    self.tableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_lastSelectedRow inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - UITableViewDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

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
    
    NSArray *menuTitles = @[SW_SIDE_BAR_ROW_NAMES];
    cell.textLabel.text = menuTitles[indexPath.row];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor lightTextColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:25];
    
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
    backView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = backView;
    
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