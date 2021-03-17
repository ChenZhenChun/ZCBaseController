//
//  WebViewModel.h
//  ZJJKMGDoctor
//
//  Created by gulu on 2017/7/28.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLBaseWebViewController.h"

/**
 与h5交互处理类。
 */
@interface WebViewModel : NSObject
@property (nonatomic,readonly) GLBaseWebViewController  *vc;
- (instancetype)initWithController:(GLBaseWebViewController *)baseWebViewController;

/**
 本地是否安装了某个应用

 @param scheme
 @return
 */
+ (BOOL)isInstalledAppByScheme:(NSString *)scheme;

/**
 拨打电话

 @param phone 电话号码
 */
+ (void)glCallPhone:(NSString *)phone;

@end
