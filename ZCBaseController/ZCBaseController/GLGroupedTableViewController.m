//
//  GLGroupedTableViewController.m
//  ZJJKMGDoctor
//
//  Created by gulu on 17/10/20.
//  Copyright (c) 2015年 zysoft. All rights reserved.
//

#import "GLGroupedTableViewController.h"

@interface GLGroupedTableViewController ()

@end

@implementation GLGroupedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
//    self.tableView.sectionIndexBackgroundColor = [UIColor greenColor];//修改右边索引的背景色
//    self.tableView.sectionIndexColor = [UIColor orangeColor];//修改右边索引字体的颜色
//    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor orangeColor];//修改右边索引点击时候的背景色
}


#pragma mark -init

- (id)init {
    self = [super init];
    if (self) {
        self.tableViewStyle = UITableViewStyleGrouped;
    }
    return self;
}

- (NSMutableArray *)sectionIndexTitles{
    if(!_sectionIndexTitles){
        _sectionIndexTitles = [[NSMutableArray alloc] init];
    }
    return _sectionIndexTitles;
}

- (NSMutableArray *)sectionHeaderTitles{
    if(!_sectionHeaderTitles){
        _sectionHeaderTitles = [[NSMutableArray alloc] init];
    }
    return _sectionHeaderTitles;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.sectionHeaderTitles.count) {
        return self.sectionHeaderTitles[section];
    }else{
        return nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if(_showSectionIndexTitles){
        return self.sectionIndexTitles;
    }else{
        return nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
