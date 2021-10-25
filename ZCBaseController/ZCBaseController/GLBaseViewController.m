//
//  GLBaseViewController.m
//  ZJJKMGDoctor
//
//  Created by gulu on 17/12/24.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import "GLBaseViewController.h"
#import "UMMobClick/MobClick.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MacroDefinition.h"
#import "GLBaseWebViewController.h"
#import "NSArray+Category.h"

@interface GLBaseViewController () {
    RACDisposable *_handler;
}
@property (nonatomic,strong) UIBarButtonItem    *leftBar;
@property (nonatomic,strong) ZOEEmptyPageDraw   *emptyPageDraw;
@property (nonatomic,strong) UIView             *barBackgroundView;
@end

@implementation GLBaseViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.navigationItem.leftBarButtonItem = self.leftBar;
        _alpha = 1;
        _isLucency = NO;
    }
    DLog(@"\nclass name>> %@\n",NSStringFromClass([self class]));
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.navigationController.navigationBar.translucent) {
        self.view.frame = CGRectMake(0,0,ScreenWidth,ScreenHeight);
    }else {
        self.view.frame = CGRectMake(0,0,ScreenWidth,ScreenHeight-NAV_HEIGHT);
    }
    self.view.backgroundColor   =  rgb(245, 245, 245);
}

- (void)reloadViewData {
    //子类重写
}

- (void)reloadViewDataWithKeyworld:(NSString *)keyword {
    //子类重新
}

#pragma mark - Action

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)backOnView {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    UIViewController *presentVC = self.presentingViewController;//presentingViewController表示的是present的起始控制器（presentedViewController 表示的是present的结束控制器）
    UINavigationController *nav = self.navigationController;//当前控制器是否有导航栏
    if ((presentVC && !nav)
        ||(presentVC && nav.viewControllers.count==1)
        ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        if (nav) {
            [nav popViewControllerAnimated:YES];
        }else {
            nav = [UIApplication sharedApplication].keyWindow.rootViewController;
            if ([nav isKindOfClass:[UITabBarController class]]) {
                nav = ((UITabBarController *)nav).selectedViewController;
            }
            if ([nav isKindOfClass:[UINavigationController class]]) {
                [nav popViewControllerAnimated:YES];
            }
        }
    }
    GLBaseWebViewController *baseWeb = [[self.navigationController viewControllers] lastObject];
    if ([baseWeb isKindOfClass:[GLBaseWebViewController class]]) {
        [baseWeb refresh];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *)) {
        if (_handler) {
            [_handler dispose];
            _handler = nil;
        }
    }
    [MobClick endLogPageView:self.navigationItem.title?:NSStringFromClass([self class])];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.alpha = _alpha;
    [self.navigationController setNavigationBarHidden:self.isHiddenNav];
    self.navigationController.navigationBar.alpha = 1;
    [self autoNavBarStatus];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:self.navigationItem.title?:NSStringFromClass([self class])];
}

// 只支持竖屏
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)dealInteractionChanges:(id<UIViewControllerTransitionCoordinatorContext>)context coor:(id<UIViewControllerTransitionCoordinator>)coor  {
    // 随着滑动的过程设置导航栏透明度渐变
    UIViewController *fromVC = [coor viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [coor viewControllerForKey:UITransitionContextToViewControllerKey];
    if ([fromVC isKindOfClass:NSClassFromString(@"RTContainerController")]) {
        fromVC = [fromVC valueForKeyPath:@"contentViewController"];
    }
    if ([toVC isKindOfClass:NSClassFromString(@"RTContainerController")]) {
        toVC = [toVC valueForKeyPath:@"contentViewController"];
    }
    if ([toVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVC = (UITabBarController *)toVC;
        toVC = tabBarVC.selectedViewController;
        if ([toVC isKindOfClass:NSClassFromString(@"RTContainerController")]) {
            toVC = [toVC valueForKeyPath:@"contentViewController"];
        }
    }
    if ([context isCancelled]) {
        // 自动取消了返回手势
    }else {
        // 自动完成了返回手势
        if (fromVC && [fromVC respondsToSelector:@selector(fullScreenPopGestureCompletedFrom:to:)]) {
            [fromVC performSelector:@selector(fullScreenPopGestureCompletedFrom:to:) withObject:fromVC withObject:toVC];
        }
    }
}

#pragma mark - Properties
//空页面对象
- (ZOEEmptyPageDraw *)emptyPageDraw {
    if (_emptyPageDraw) return _emptyPageDraw;
    _emptyPageDraw = [[ZOEEmptyPageDraw alloc]init];
    return _emptyPageDraw;
}

- (UIBarButtonItem *)leftBar {
    if (_leftBar) return _leftBar;
    _leftBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"goBack"] style:UIBarButtonItemStyleDone target:self action:@selector(backOnView)];
    return _leftBar;
}

- (void)setAlpha:(CGFloat)alpha {
    _alpha = alpha;
    if (_alpha<0) {
        _alpha = 0;
    }else if (_alpha>1) {
        _alpha = 1;
    }
    [self autoNavBarStatus];
//    DLog(@"-----alpha=%f",_alpha);
    self.barBackgroundView.alpha = alpha;
    if (@available(iOS 11.0, *)) {
        if (!_handler) {
            @weakify(self)
            _handler = [[RACObserve(self.barBackgroundView,alpha)distinctUntilChanged] subscribeNext:^(id x) {
                @strongify(self)
                if (self.alpha!=self.barBackgroundView.alpha) {
                    self.barBackgroundView.alpha = self.alpha;
//                    DLog(@"---%@--bar_alpha=%f",NSStringFromClass([self class]),self.barBackgroundView.alpha);
                }
            }];
        }
    }
}

- (UIView *)barBackgroundView {
    if (_barBackgroundView) return _barBackgroundView;
    _barBackgroundView = [[self.navigationController.navigationBar subviews] objectAtIndexCheck:0];
    return _barBackgroundView;
}

- (void)autoNavBarStatus {
    KNavBarTinColor_White
//    if (_alpha<0.5) {
//        KNavBarTinColor_White
//    }else {
//        KNavBarTinColor_Black
//    }
}

- (void)setZj_interactivePopDisabled:(BOOL)zj_interactivePopDisabled {
    _zj_interactivePopDisabled = zj_interactivePopDisabled;
    if (_zj_interactivePopDisabled) {
        //禁用侧滑返回上一页
        id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
        [self.view addGestureRecognizer:pan];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//监听手势滑动返回。from：返回的起始页，to：返回的结果页
- (void)fullScreenPopGestureCompletedFrom:(UIViewController *)from to:(UIViewController *)to {
    //子类重写；
}

@end
