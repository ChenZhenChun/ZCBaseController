//
//  GLGroupedTableViewController.h
//  ZJJKMGDoctor
//
//  Created by gulu on 17/10/20.
//  Copyright (c) 2015年 zysoft. All rights reserved.
//

#import "GLBaseTableViewController.h"

@interface GLGroupedTableViewController : GLBaseTableViewController
/**
 *  是否显示显示分组索引（tableView右侧的那个索引条）
 */
@property (nonatomic, assign) BOOL showSectionIndexTitles;
/**
 *  初始分组索引title （例如A,B,C,D,E,……#）
 */
@property (nonatomic, strong) NSMutableArray *sectionIndexTitles;
/**
 *  初始化header的title
 */
@property (nonatomic, strong) NSMutableArray *sectionHeaderTitles;

@end
