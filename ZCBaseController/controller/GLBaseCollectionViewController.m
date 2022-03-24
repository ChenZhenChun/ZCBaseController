//
//  GLBaseCollectionViewController.m
//  ZJJKMGDoctor
//
//  Created by gulu on 2018/10/15.
//Copyright © 2018年 gulu. All rights reserved.
//

#import "GLBaseCollectionViewController.h"
#import "MacroDefinition.h"

@interface GLBaseCollectionViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) UICollectionView           *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@end

@implementation GLBaseCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark -界面构成
- (void)setupContentView {
    
}

#pragma mark -界面数据加载
- (void)reloadViewData {
    
}

#pragma mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark - Action

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

#pragma mark - Properties
- (UICollectionView *)collectionViewWithItemSize:(CGSize)size {
    if (!_collectionView){
        self.flowLayout.itemSize = size;
        CGFloat height = self.navigationController.navigationBar.translucent?ScreenHeight:ScreenHeight-NAV_HEIGHT;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0,ScreenWidth,height) collectionViewLayout:self.flowLayout];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInset = UIEdgeInsetsZero;
        _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
        tap.cancelsTouchesInView = NO;
        tap.delegate = self;
        [_collectionView addGestureRecognizer:tap];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (_flowLayout) return _flowLayout;
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.minimumLineSpacing = 0;
    _flowLayout.minimumInteritemSpacing = 0;
    _flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    return _flowLayout;
}


- (NSMutableArray *)dataSource {
    if (_dataSource) return _dataSource;
    _dataSource = [[NSMutableArray alloc] init];
    return _dataSource;
}

- (NSMutableArray *)searchDataSource {
    if (_searchDataSource) return _searchDataSource;
    _searchDataSource = [[NSMutableArray alloc] init];
    return _searchDataSource;
}

@end
