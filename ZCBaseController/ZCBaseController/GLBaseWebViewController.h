//
//  GLBaseWebViewController.h
//  AiyoyouProject
//
//  Created by gulu on 17/8/13.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "GLPlayerView.h"
#import "GLBaseViewController.h"

@interface GLBaseWebViewController : GLBaseViewController<WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate>

/**
 WKWebView
 */
@property (nonatomic,strong) WKWebView *webView;

/**
 页面弹动，default is yes。
 */
@property (nonatomic,assign,getter=isBounces) BOOL bounces;

@property (nonatomic,strong) UIBarButtonItem *rightBarButtonItem;
/**
 导航栏上的按钮被点击了
 */
@property (nonatomic,copy)   void(^barItemClickBlock)(id target);
@property (nonatomic,copy)   NSString *rightItemJavaScript;

@property (nonatomic,copy)   CGRect(^configWebViewFrame)(CGRect frame);

@property (nonatomic,readonly) GLPlayerView *videoView;//视频播放视图(外界使用initFrame初始化然后赋值)
@property (nonatomic,assign) CGFloat    gradualY;//导航栏开始渐变的y值（默认0不渐变，导航栏不可透明不渐变）
@property (nonatomic,copy) NSString     *url;//地址预赋值。

/**
 根据本地html文件名加载html页面

 @param htmlName 本地html名字
 */
- (void)loadWithHtmlName:(NSString*)htmlName NS_REQUIRES_SUPER;

/**
 *
 *
 *  @param urlString Url地址
 */

/**
 根据url地址加载html页面

 @param urlString 地址
 */
- (void)loadWithUrl:(NSString *)urlStr NS_REQUIRES_SUPER;

/**
 根据url地址加载html页面
 
 @param NSURL 地址
 */
- (void)loadWithNSURL:(NSURL *)url NS_REQUIRES_SUPER;

/// 刷新H5页面
- (void)refresh;


/**
 WKWebView设置userAgent一定要在WKWebView alloc 之前，所以这边APP启动的时候全局设置UA。
 因为设置UA是异步的，所以如果在没有设置UA之前就初始化了WKWebView进行h5页面展示，h5就无法获取到自定义的UA字符串。
 所以如果是启动app需要马上进入h5页面流量的页面最好要先调用configGlobalUserAgent进行UA设置完成之后再做h5页面跳转
 
 @param completeHandle
 */
+ (void)configGlobalUserAgent:(void (^)(WKWebView *webView))completeHandle;

@property (nonatomic,strong) UIButton            *closeBtn;//关闭按钮
@end
