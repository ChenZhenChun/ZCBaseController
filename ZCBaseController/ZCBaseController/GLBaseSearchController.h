//
//  GLBaseSearchController.h
//  ZJJKMGDoctor
//
//  Created by gulu on 2017/8/25.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import "GLBaseTableViewController.h"

@interface GLBaseSearchController : GLBaseTableViewController
@property (nonatomic,readonly) UISearchController *searchController;
@property (nonatomic,strong) UIViewController   *resultsVC;

- (instancetype)initWithSearchResultsVC:(UIViewController *)resultsVC;
@end
