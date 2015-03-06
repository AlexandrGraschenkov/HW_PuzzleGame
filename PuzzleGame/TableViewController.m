//
//  TableViewController.m
//  PuzzleGame
//
//  Created by Гена on 27.02.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import "TableViewController.h"
#import "DetailViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Game.h"

@interface TableViewController () {
    NSArray *titles;
}

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadIfNescessary) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadIfNescessary];
}

- (void)loadData
{
    [[Game sharedInstance] getTitlesOfImages:^(NSArray *arr) {
        titles = arr;
        [self.refreshControl endRefreshing];
        if (!titles) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText = @"Please check internet connection";
            [hud hide:YES afterDelay:1.5];
        }
        [self.tableView reloadData];
    }];
}

- (void)reloadIfNescessary
{
    [self.refreshControl beginRefreshing];
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = titles[indexPath.row];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    [[Game sharedInstance] setupGameWithImageNamed:titles[indexPath.row]];
}


@end
