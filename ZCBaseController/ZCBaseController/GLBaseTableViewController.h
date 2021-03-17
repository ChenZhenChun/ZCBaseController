//
//  GLBaseTableViewController.h
//  ZJJKMGDoctor
//
//  Created by gulu on 17/8/13.
//  Copyright (c) 2015年 zysoft. All rights reserved.
//
#import "UITableViewCell+Separator.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "GLBaseViewController.h"
#import "MJRefresh.h"

#define KGL_RefreshGif(func) MJRefreshNormalHeader *gifHeader = \
    [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(func)];\
    self.tableView.mj_header = gifHeader;

#define KGL_RefreshFooter(func) MJRefreshAutoNormalFooter *footer = \
[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(func)];\
footer.automaticallyRefresh = YES;\
self.tableView.mj_footer = footer;\
self.tableView.mj_footer.hidden = YES;

@interface GLBaseTableViewController : GLBaseViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate>

/**
 *  显示大量数据的控件
 */
@property (nonatomic,strong) UITableView *tableView;

/**
 *  初始化init的时候设置tableView的样式才有效
 */
@property (nonatomic,assign) UITableViewStyle tableViewStyle;

/**
 *  是否带有搜索框，yes带搜索框，no不带搜索框。
 */
@property (nonatomic) BOOL isShowSearchBar;

/**
 *  搜索框（isShowSearchBar＝yes时，搜索框会自动被初始化）,供子类调用。
 */
@property (nonatomic,readonly) UISearchBar *baseSearchBar;

/**
 *  界面配置项
 */
@property (nonatomic, strong) NSMutableArray *viewConfig;

/**
 *  cell渲染时需要的数据源
 */
@property (nonatomic, strong) NSMutableArray *dataSource;

/**
 *  带搜索框时这个属性是最大的数据源，dataSource是搜索过滤后的数据源
 */
@property (nonatomic,strong) NSMutableArray *searchDataSource;

@property (nonatomic,copy) void(^hideKeyBoard)(void);

/**
 *  加载本地或者网络数据源
 */
- (void)loadDataSource;

/**
 *  加载界面配置
 */
- (void)loadViewConfig;

- (void)setSeparatorInsetTemp:(UIEdgeInsets)edgeInsets;

@end
