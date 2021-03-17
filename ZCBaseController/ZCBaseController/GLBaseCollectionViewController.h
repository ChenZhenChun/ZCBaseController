//
//  GLBaseCollectionViewController.h
//  ZJJKMGDoctor
//
//  Created by gulu on 2018/10/15.
//  Copyright © 2018年 gulu. All rights reserved.
//

#import "GLBaseViewController.h"

#define ZJ_CollectionViewRefreshHeader(func) MJRefreshNormalHeader *gifHeader = \
[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(func)];\
self.collectionView.mj_header = gifHeader;

#define ZJ_CollectionViewRefreshFooter(func) MJRefreshAutoNormalFooter *footer = \
[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(func)];\
footer.automaticallyRefresh = YES;\
self.collectionView.mj_footer = footer;\
self.collectionView.mj_footer.hidden = YES;

@interface GLBaseCollectionViewController : GLBaseViewController<UICollectionViewDataSource,UICollectionViewDelegate>

- (UICollectionView *)collectionViewWithItemSize:(CGSize)size;

/**
 *  显示大量数据的控件
 */
@property (nonatomic,readonly) UICollectionView           *collectionView;

/**
 布局
 */
@property (nonatomic,readonly) UICollectionViewFlowLayout *flowLayout;

/**
 *  cell渲染时需要的数据源
 */
@property (nonatomic, strong) NSMutableArray *dataSource;
/**
 *  带搜索框时这个属性是最大的数据源，dataSource是搜索过滤后的数据源
 */
@property (nonatomic,strong) NSMutableArray *searchDataSource;

@property (nonatomic,copy) void(^hideKeyBoard)(void);

@end
