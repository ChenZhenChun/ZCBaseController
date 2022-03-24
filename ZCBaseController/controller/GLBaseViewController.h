//
//  GLBaseViewController.h
//  ZJJKMGDoctor
//
//  Created by gulu on 17/12/24.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZOEEmptyPageDraw.h"

@interface GLBaseViewController : UIViewController 
@property (nonatomic,readonly)  ZOEEmptyPageDraw    *emptyPageDraw;//空页面处理类
@property (nonatomic,readonly)  UIBarButtonItem     *leftBar;
@property (nonatomic,assign) CGFloat                alpha;//0~1;
@property (nonatomic,assign) BOOL                   isLucency;
@property (nonatomic,assign) BOOL                   isHiddenNav;
@property (nonatomic,assign) BOOL                   zj_interactivePopDisabled;//YES禁止系统自带的侧滑返回(默认NO)
@property (nonatomic,copy) void(^glBaseCallBackBlock)(id sender);//子类中看情况实现
@property (nonatomic,copy) NSString                 *javaScript;//可能需要执行的脚本
@property (nonatomic,copy) void(^doubleClickTabBarItemBlock) (void);//tabBarItem第二次点击Block调用

/**
 返回
 */
- (void)backOnView;


/**
 刷新数据
 */
- (void)reloadViewData;


/**
 根据关键词刷新数据（子类实现）

 @param keyword
 */
- (void)reloadViewDataWithKeyworld:(NSString *)keyword;

/**
 监听手势滑动返回(子类重写实现监听)

 @param from 返回的起始页
 @param to 返回的结果页
 */
- (void)fullScreenPopGestureCompletedFrom:(UIViewController *)from to:(UIViewController *)to NS_REQUIRES_SUPER;

@end
