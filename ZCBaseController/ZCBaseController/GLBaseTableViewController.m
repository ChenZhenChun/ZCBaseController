//
//  GLBaseTableViewController.m
//  ZJJKMGDoctor
//
//  Created by gulu on 17/8/13.
//  Copyright (c) 2015年 zysoft. All rights reserved.
//

#import "GLBaseTableViewController.h"
#import "MacroDefinition.h"
#import "UISearchBar+clear.h"

@interface GLBaseTableViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) UISearchBar            *searchBar;
@end

@implementation GLBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isShowSearchBar = NO;
    [self.view addSubview:self.tableView];
}

#pragma mark -init

- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat height = self.navigationController.navigationBar.translucent?ScreenHeight:ScreenHeight-NAV_HEIGHT;
        _tableView                  = [[UITableView alloc] initWithFrame:CGRectMake(0,0,ScreenWidth,height) style:self.tableViewStyle];
        _tableView.tableFooterView  = [[UIView alloc] init];
        _tableView.backgroundColor  = rgb(245, 245, 245);
        _tableView.delegate         = self;
        _tableView.dataSource       = self;
        [_tableView  setSeparatorColor:rgb(221,221,221)];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
        } else {
            // Fallback on earlier versions
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
        tap.cancelsTouchesInView = NO;
        tap.delegate = self;
        [_tableView addGestureRecognizer:tap];
    }
    return _tableView;
}

- (void)setIsShowSearchBar:(BOOL)isShowSearchBar {
    if (isShowSearchBar) {
        self.tableView.tableHeaderView = self.searchBar;
    }else {
        self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0.1)];
    }
    _isShowSearchBar = isShowSearchBar;
}
//搜索框
- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40)];
        _searchBar.placeholder=@"搜索";
        _searchBar.delegate = self;
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [UISearchBar setBackgroundForSearchBar:_searchBar withColor:rgb(245, 245, 245)];
    }
    return _searchBar;
}

- (UISearchBar *)baseSearchBar {
    return _searchBar;
}

//搜索所需要的数据源
- (NSMutableArray *)searchDataSource {
    if (!_searchDataSource) {
        _searchDataSource = [[NSMutableArray alloc]initWithCapacity:1];
    }
    return _searchDataSource;
}

//cell渲染所需要的数据源
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]initWithCapacity:1];
    }
    return _dataSource;
}

- (NSMutableArray *)viewConfig {
    if (!_viewConfig) {
        _viewConfig = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _viewConfig;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // in subClass
    return nil;
}


#pragma mark -UIScrollViewDelegate


#pragma mark -UISearchBarDelegate
//搜索框值改变触发事件
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //子类重写
}


#pragma mark - Action

- (void)loadDataSource {
    // subClasse
}

- (void)loadViewConfig {
    // subClasse
}

- (void)setSeparatorInsetTemp:(UIEdgeInsets)edgeInsets {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:edgeInsets];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        //ios8分割线顶头
        [self.tableView setLayoutMargins:edgeInsets];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *view = touch.view;
    if ([view isKindOfClass:NSClassFromString(@"UITextView")]
        ||[view isKindOfClass:NSClassFromString(@"YYTextView")]
        ||[view isKindOfClass:NSClassFromString(@"UITextField")]
        ||[view isKindOfClass:NSClassFromString(@"YYTextContainerView")]
        ) {
        return NO;
    }
    return YES;
}

- (void)hideKeyBoard:(UITapGestureRecognizer *)tap {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        if (self.hideKeyBoard) {
            self.hideKeyBoard();
        }
    });
}

@end
