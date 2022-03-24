//
//  GLBaseSearchController.m
//  ZJJKMGDoctor
//
//  Created by gulu on 2017/8/25.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import "GLBaseSearchController.h"
#import "MacroDefinition.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface GLBaseSearchController ()<UISearchControllerDelegate,UISearchResultsUpdating>
@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic,strong) UIView             *statusView;
@end

@implementation GLBaseSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    UIView *gbView = [[UIView alloc]initWithFrame:self.tableView.bounds];
    gbView.backgroundColor = self.view.backgroundColor;
    self.navigationController.view.backgroundColor = self.view.backgroundColor;
    self.tableView.backgroundView = gbView;
}

- (instancetype)initWithSearchResultsVC:(UIViewController *)resultsVC {
    self = [super init];
    if (self) {
        _resultsVC = resultsVC;
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if(self.searchController.active) {
        self.view.frame = CGRectMake(0,StatusBarHeight,ScreenWidth, ScreenHeight-StatusBarHeight);
//        self.fd_interactivePopDisabled = YES;
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }else{
        self.view.frame = CGRectMake(0,NAV_HEIGHT,ScreenWidth, ScreenHeight-NAV_HEIGHT);
//        self.fd_interactivePopDisabled = NO;
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

#pragma mark - UISearchResultsUpdating 搜索过滤
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"updateSearchResultsForSearchController");
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController
{
    if (_resultsVC) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [searchController.view addSubview:self.statusView];
//            self.statusView.frame = CGRectMake(0,(isiPhoneX?88:64)-(isiPhoneX?44:20),ScreenWidth,(isiPhoneX?44:20));
//            [UIView animateWithDuration:0.33 animations:^{
//                self.statusView.frame = CGRectMake(0,0,ScreenWidth,(isiPhoneX?44:20));
//            }];
//        });
        [searchController.view addSubview:self.statusView];
        if (@available(iOS 11.0, *)) {
            self.statusView.frame = CGRectMake(0,0,ScreenWidth,56+StatusBarHeight);
        } else {
           self.statusView.frame = CGRectMake(0,0,ScreenWidth,44+StatusBarHeight);
        }
        
    }
    NSLog(@"willPresentSearchController");
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    KNavBarTinColor_Black
    NSLog(@"didPresentSearchController");
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    if (_statusView) [_statusView removeFromSuperview];
    NSLog(@"willDismissSearchController");
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    KNavBarTinColor_White
    NSLog(@"didDismissSearchController");
}

- (void)presentSearchController:(UISearchController *)searchController
{
    NSLog(@"presentSearchController");
}


#pragma mark - Action

#pragma mark - Properties

- (UISearchController *)searchController {
    if (_searchController) return _searchController;
    //搜索结果页不单独设置（搜索结果页和当前是同一个页面）
    _searchController = [[UISearchController alloc]initWithSearchResultsController:_resultsVC];
    _searchController.delegate= self;
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.placeholder= @"搜索";
    [_searchController.searchBar sizeToFit];
    //背景色
    _searchController.searchBar.barTintColor = rgb(245, 245, 245);
    
    //去掉黑线
    UIImageView *barInmageViw = [[[_searchController.searchBar.subviews firstObject] subviews]firstObject];
    barInmageViw.layer.borderColor = rgb(245, 245, 245).CGColor;
    barInmageViw.layer.borderWidth = 1;
    
    //设置圆角
    UITextField *searchField = [_searchController.searchBar valueForKey:@"searchField"];
    searchField.layer.masksToBounds = YES;
    [[RACObserve(searchField,frame) distinctUntilChanged] subscribeNext:^(id x) {
        if (!CGRectIsEmpty(searchField.frame)) {
            searchField.layer.cornerRadius = searchField.frame.size.height/2.0;
        }
    }];
    
    
    _searchController.searchBar.delegate = self;
    //进入预编辑状态不加载半透明遮罩
    if(_resultsVC) {
        _searchController.dimsBackgroundDuringPresentation = YES;
    }else {
        _searchController.dimsBackgroundDuringPresentation = NO;
    }
    
    
    //修改文字颜色
    if ([[UIDevice currentDevice].systemVersion floatValue]<9.0) {
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:rgb(51,51,51)];
    }else {
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:rgb(51,51,51)];
    }
    return _searchController;
}


- (UIView *)statusView {
    if (_statusView) return _statusView;
    _statusView = [[UIView alloc]init];
    _statusView.backgroundColor = rgb(245, 245, 245);
    _statusView.alpha = 0.95;
    return _statusView;
}

- (void)dealloc {
    self.tableView.delegate = nil;
    _searchController.delegate = nil;
    _searchController.searchResultsUpdater = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.searchController.active) {
        KNavBarTinColor_Black
    }
}

@end
