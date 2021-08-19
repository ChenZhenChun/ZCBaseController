//
//  GLBaseWebViewController.m
//  AiyoyouProject
//
//  Created by gulu on 17/8/13.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import "GLBaseWebViewController.h"
#import "WebViewModel.h"
#import <AVFoundation/AVFoundation.h>
#import "JPVideoPlayerKit.h"
#import "ZOEAlertView.h"
#import "MJExtension.h"
#import "MacroDefinition.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Config.h"
#import "NSObject+GLHUD.h"
#import "NSString+Category.h"

/**
 xxxxxxxx.a.b.cn
 xxxxxxxx为自定义字符串，标识不同项目
 a.b.cn 域名，不能随便填写，微信支付地址中redirect_url后面的域名。如果填其他域名，域名需要再微信商务上加白名单授权
 这两部分组成了一个app的scheme（设定scheme为这个字符串，支付完成后能回跳到app）
 */
#define CompanyFirstDomainByWeChatRegister [Config sharedInstance].configDict[@"CompanyFirstDomainByWeChatRegister"]

@interface GLBaseWebViewController ()<WKScriptMessageHandler>
@property (nonatomic,strong) UIBarButtonItem            *closeItem;
@property (nonatomic,strong) UIBarButtonItem            *fixBar;

@property (nonatomic,strong) WKWebViewConfiguration     *config;//与js交互的配置对象
@property (nonatomic,strong) NSArray                    *scriptMessageArray;//与js交互注册的方法
@property (nonatomic,strong) WebViewModel               *webViewModel;//处理js交互的类
@property (nonatomic,strong) NSMutableURLRequest        *request;
@property (nonatomic,strong) GLPlayerView               *videoView;
@property (nonatomic,assign) BOOL                       keyBoardHide;
@end

@implementation GLBaseWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /// 监听将要弹起
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardWillShowNotification object:nil];
    /// 监听将要隐藏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHidden:) name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(endPlayVideo:)
//                                                 name:UIWindowDidBecomeHiddenNotification
//                                               object:self.view.window];
}

//根据本地html文件名加载html页面
- (void)loadWithHtmlName:(NSString *)htmlName {
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:htmlName ofType:@"html"];
    NSURL *bundleUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSError *error = nil;
    
    NSString *html = [[NSString alloc] initWithContentsOfFile:htmlPath encoding: NSUTF8StringEncoding error:&error];
    if (error == nil) {//数据加载没有错误情况下
        [self.webView loadHTMLString:html baseURL:bundleUrl];
    }
}

//根据url地址加载html页面
- (void)loadWithUrl:(NSString *)urlStr {
    _url = urlStr;
    [self.webView loadRequest:self.request];
}

- (void)loadWithNSURL:(NSURL *)url {
    _url = url.absoluteString;
    [self.webView loadRequest:self.request];
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self hud_showHudInView:self.view];
//    if (self.navigationItem.leftBarButtonItem) {
//        self.navigationItem.leftBarButtonItems = @[self.navigationItem.leftBarButtonItem];
//    }
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.titleView = nil;
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self hud_hide];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self hud_hide];
    //页面默认标签
    [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *title, NSError * _Nullable error) {
        if (!self.title.length) {
            self.title = title;
        }
    }];
    
//    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:^(id _Nullable a, NSError * _Nullable error) {
//
//    }];
//    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:^(id _Nullable b, NSError * _Nullable error) {
//
//    }];
    
    if (self.isHiddenNav) {
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:webView.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *tmpresponse = (NSHTTPURLResponse*)response;
            if (tmpresponse.statusCode>=400) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.title = [NSString stringWithFormat:@"%ld",(long)tmpresponse.statusCode];
                    [self.navigationController setNavigationBarHidden:NO animated:YES];
                });
            }
        }];
        [dataTask resume];
    }
    
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(nonnull NSError *)error {
    [self hud_hide];
    if(!webView.isLoading) {
//        [self hud_showHintError:@"加载失败"];
    }
}

//// 接收到服务器跳转请求之后调用
//- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
//
//}
//
//// 在收到响应后，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
//
//}

// 在发送请求之前，决定是否跳转
//打开一个页面之后，点击里面的内容就直接能跳转。而WKWebView一开始点里面的东西没反应，只要加了这个方法就好了。
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    
    NSURLRequest *request        = navigationAction.request;
    NSString     *scheme         = [request.URL scheme];
    // decode for all URL to avoid url contains some special character so that it wasn't load.
    NSString     *absoluteString = [navigationAction.request.URL.absoluteString stringByRemovingPercentEncoding];
    
    static NSString *endPayRedirectURL = nil;
    
    if ([NSString isBlankString:self.companyFirstDomainByWeChatRegister]) {
        self.companyFirstDomainByWeChatRegister = CompanyFirstDomainByWeChatRegister;
    }
    
    // Wechat Pay, Note : modify redirect_url to resolve we couldn't return our app from wechat client.
    if ([absoluteString hasPrefix:@"https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb"]
        && ![absoluteString hasSuffix:[NSString stringWithFormat:@"redirect_url=%@://",self.companyFirstDomainByWeChatRegister]]
        ) {
        decisionHandler(WKNavigationActionPolicyCancel);
        
#warning Note : The string "xiaodongxie.cn://" must be configured by wechat background. It must be your company first domin. You also should configure "URL types" in the Info.plist file.
        
        // 1. If the url contain "redirect_url" : We need to remember it to use our scheme replace it.
        // 2. If the url not contain "redirect_url" , We should add it so that we will could jump to our app.
        //  Note : 2. if the redirect_url is not last string, you should use correct strategy, because the redirect_url's value may contain some "&" special character so that my cut method may be incorrect.
        NSString *redirectUrl = nil;
        if ([absoluteString containsString:@"redirect_url="]) {
            NSRange redirectRange = [absoluteString rangeOfString:@"redirect_url"];
            endPayRedirectURL =  [absoluteString substringFromIndex:redirectRange.location+redirectRange.length+1];
            redirectUrl = [[absoluteString substringToIndex:redirectRange.location] stringByAppendingString:[NSString stringWithFormat:@"redirect_url=%@://",self.companyFirstDomainByWeChatRegister]];
        }else {
            redirectUrl = [absoluteString stringByAppendingString:[NSString stringWithFormat:@"&redirect_url=%@://",self.companyFirstDomainByWeChatRegister]];
        }
        
        NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:redirectUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
        newRequest.URL = [NSURL URLWithString:redirectUrl];
        [webView loadRequest:newRequest];
        return;
    }
    
    // Judge is whether to jump to other app.
    if (![scheme isEqualToString:@"https"] && ![scheme isEqualToString:@"http"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        if ([scheme isEqualToString:@"weixin"]) {
            // The var endPayRedirectURL was our saved origin url's redirect address. We need to load it when we return from wechat client.
            if (endPayRedirectURL) {
                [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:endPayRedirectURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10]];
            }
            BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:request.URL];
            if (canOpen) {
                [[UIApplication sharedApplication] openURL:request.URL];
            }
        }else if ([scheme isEqualToString:@"alipay"]) {
            // 截取 json 部分
            NSRange range = [absoluteString rangeOfString:@"{"];
            NSString *param1 = [absoluteString substringFromIndex:range.location];
            if ([param1 rangeOfString:@"\"fromAppUrlScheme\":"].length > 0) {
                id json = [param1 mj_JSONObject];
                if (![json isKindOfClass:[NSDictionary class]]) {
                    decisionHandler(WKNavigationActionPolicyAllow);
                    return;
                }
                
                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:json];
                dicM[@"fromAppUrlScheme"] = self.companyFirstDomainByWeChatRegister;
                
                NSString *encodedString = [[dicM mj_JSONString] mj_url].absoluteString;
                
                // 只替换 json 部分
                absoluteString = [absoluteString stringByReplacingCharactersInRange:NSMakeRange(range.location, absoluteString.length - range.location) withString:encodedString];
                
                BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:absoluteString]];
                if (canOpen) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:absoluteString]];
                }
            }
        }
        
        return;
    }
    
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}

#pragma mark - WKUIDelegate
//以下三个代理方法全都是与界面弹出提示框相关的，针对web界面的三种提示框（警告框，提示框，输入框）分别对应三种代理方法
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    ZOEAlertView *alertView = [[ZOEAlertView alloc]initWithTitle:@"alert" message:message cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView showWithBlock:^(NSInteger buttonIndex) {
        completionHandler();
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认框" message:@"调用confirm提示框" preferredStyle:UIAlertControllerStyleAlert];
    alert.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:alert animated:YES completion:NULL];
    ZOEAlertView *alertView = [[ZOEAlertView alloc]initWithTitle:@"confirm" message:message cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex!=alertView.cancelButtonIndex) {
            completionHandler(YES);
        }else {
            completionHandler(NO);
        }
    }];
}

//同步返回值给JS。messageHandler都是异步返回值给js，我们可以用这个回调方法拦截然后通过completionHandler同步返回值给js
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
//    ZOEAlertView *alertView = [[ZOEAlertView alloc]initWithTitle:@"alert" message:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];;
//    alertView.alertViewStyle = ZOEAlertViewStylePlainTextInput;
//    [alertView showWithBlock:^(NSInteger buttonIndex) {
//        completionHandler(alertView.textField.text);
//    }];
    dispatch_async_main_safe(^{
         completionHandler([self receiveScriptMessageName:prompt value:[defaultText mj_JSONObject]]);
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isLucency && _gradualY) {
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY > _gradualY-(isiPhoneX?88:64)) {
            self.navigationController.navigationBar.alpha = 1;
            self.alpha = MIN(1, 1 - ((_gradualY + (isiPhoneX?88:64) - offsetY) / (isiPhoneX?88:64)));
        } else {
            self.navigationController.navigationBar.alpha = 1;
            self.alpha = 0;
        }
    }
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray,
    // NSDictionary, and NSNull类型
    SEL sel;
    id value = message.body;
    if (value&&value!=[NSNull null]) {
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:",message.name]);
    }else {
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@",message.name]);
    }
    @weakify(self)
    if([self.webViewModel respondsToSelector:sel]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.webViewModel performSelector:sel withObject:value];//如果是有多个参数就要写多个withObject
#pragma clang diagnostic pop
        });
        
    }else {
        [self hud_showHintTip:[NSString stringWithFormat:@"%@ 方法未实现",NSStringFromSelector(sel)]];
    }
}


/**
 接收h5交互请求参数的处理
 
 @param name 需要与原生交互的方法名字
 @param value 交互的参数
 */
- (id)receiveScriptMessageName:(NSString *)name value:(id)value {
    SEL sel;
    if (value&&value!=[NSNull null]) {
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:",name]);
    }else {
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@",name]);
    }
    id result;
    if([self.webViewModel respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        result = [self.webViewModel performSelector:sel withObject:value];//如果是有多个参数就要写多个withObject
#pragma clang diagnostic pop
    }
    
    return result;
}


#pragma mark - Action

- (void)backOnView {
    @weakify(self)
    [self.webView evaluateJavaScript:@"canGoback()" completionHandler:^(id _Nullable canGoback, NSError * _Nullable error) {
        @strongify(self)
        if (error) {
            [self appGoback];
        }else {
            if (canGoback) {
                BOOL flag = [canGoback boolValue];
                if (flag) {
                    [self appGoback];
                }
            }else {
                [self appGoback];
            }
        }
    }];
}

- (void)appGoback {
    if ([self.webView canGoBack]) {
        [self refresh];
        [self.webView goBack];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refresh];
        });
        if (self.navigationItem.leftBarButtonItem) {
            self.navigationItem.leftBarButtonItems = @[self.navigationItem.leftBarButtonItem,self.fixBar,self.closeItem];
        }
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.titleView = nil;
    }else{
        [self popVC];
    }
}

- (void)refresh {
    [self.webView evaluateJavaScript:@"goBack()" completionHandler:^(id _Nullable q, NSError * _Nullable error) {
        
    }];
}

#pragma mark - Action
#pragma mark - 关闭一个浏览器
- (void)popVC {
    [super backOnView];
    [self removeScriptMessageHandler];
}

- (void)removeScriptMessageHandler {
    for (NSString *name in self.scriptMessageArray) {
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:name];
    }
}

#pragma mark - 导航栏上的rightBarButtonItem的点击事件处理
- (void)rightItemAction {
    if (_barItemClickBlock) {
        _barItemClickBlock(self.rightBarButtonItem);
    }
}

#pragma mark - Properties

- (WKWebView *)webView {
    if (!_webView) {
        CGRect webViewFrame = self.view.bounds;
        if (self.configWebViewFrame) {
            webViewFrame = self.configWebViewFrame(self.view.bounds);
        }
        _webView = [[WKWebView alloc]initWithFrame:webViewFrame configuration:self.config];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.opaque = NO;
        _webView.scrollView.bounces = NO;
        _webView.scrollView.alwaysBounceVertical = YES;
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        _webView.scrollView.delegate = self;
        [_webView setBackgroundColor:rgb(245, 245, 245)];
        [_webView.scrollView setShowsVerticalScrollIndicator:NO];
        [_webView.scrollView setShowsHorizontalScrollIndicator:NO];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (WKWebViewConfiguration *)config {
    if (_config) return _config;
    _config = [WKWebViewConfiguration new];
    _config.userContentController = [WKUserContentController new];
    //processPoll使用单例解决localstorage存储问题
    _config.processPool = [GLBaseWebViewController singleWkProcessPool];
    //初始化偏好设置属性：preferences
    _config.preferences = [WKPreferences new];
    //The minimum font size in points default is 0;
    _config.preferences.minimumFontSize = 10;
    //是否支持JavaScript
    _config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    _config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    _config.allowsInlineMediaPlayback = YES;
    // 注入JS对象名称senderModel，当JS通过senderModel来调用时，我们可以在WKScriptMessageHandler代理中接收到
    for (NSString *name in self.scriptMessageArray) {
        [_config.userContentController addScriptMessageHandler:self name:name];
    }
    return _config;
}

+ (WKProcessPool *)singleWkProcessPool {
    static dispatch_once_t onceToken;
    static WKProcessPool *sharePool;
    dispatch_once(&onceToken, ^{
        sharePool = [[WKProcessPool alloc] init];
    });
    return sharePool;
}

#pragma mark -- js交互方法注册
- (NSArray *)scriptMessageArray {
    if (_scriptMessageArray) return _scriptMessageArray;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GLscriptMessageArray" ofType:@"plist"];
    _scriptMessageArray = [[NSArray alloc] initWithContentsOfFile:path];
    return _scriptMessageArray;
}

- (WebViewModel *)webViewModel {
    if (_webViewModel) return _webViewModel;
        _webViewModel = [[WebViewModel alloc]initWithController:self];
    return _webViewModel;
}

- (NSMutableURLRequest *)request {
    if (_request) return _request;
    _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                   timeoutInterval:10];
    
    //创建一个 NSMutableURLRequest 添加 header
    NSString *token = [Config sharedInstance].commonsSessionId;
    [_request addValue:token forHTTPHeaderField:@"Commons-Session"];
    [_request addValue:[Config sharedInstance].appCode forHTTPHeaderField:@"App-Code"];
    [_request addValue:[Config sharedInstance].orgCode forHTTPHeaderField:@"Org-Code"];
    [_request addValue:AppVersion forHTTPHeaderField:@"Version"];
    [_request addValue:[NSString stringWithFormat:@"%f",StatusBarHeight] forHTTPHeaderField:@"StatusBarHeightPx"];
    return _request;
}

/**
 WKWebView设置userAgent一定要在WKWebView alloc 之前，所以这边APP启动的时候全局设置UA。
 因为设置UA是异步的，所以如果在没有设置UA之前就初始化了WKWebView进行h5页面展示，h5就无法获取到自定义的UA字符串。
 所以如果是启动app需要马上进入h5页面流量的页面最好要先调用configGlobalUserAgent进行UA设置完成之后再做h5页面跳转

 @param completeHandle
 */
+ (void)configGlobalUserAgent:(void (^)(WKWebView *))completeHandle {
    static WKWebView *webView2;
    static dispatch_once_t onceToken;
    static NSString *executableFile;
    dispatch_once(&onceToken, ^{
        webView2 = [[WKWebView alloc] initWithFrame:CGRectZero];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        executableFile = [infoDictionary objectForKey:(NSString *)kCFBundleExecutableKey];
    });
    
    @weakify(webView2)
    [webView2 evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *secretAgent, NSError *error) {
        @strongify(webView2)
        if (![secretAgent containsString:[NSString stringWithFormat:@"native_%@",executableFile]]) {
            NSString *newUagent;
            if ([UIScreen mainScreen].scale==2 && [UIScreen mainScreen].nativeScale!=2) {
                newUagent = [NSString stringWithFormat:@"%@ no_nativeScale_%@",secretAgent,executableFile];
            }
            newUagent = [NSString stringWithFormat:@"%@ native_%@_%@",newUagent?newUagent:secretAgent,executableFile,AppVersion];
            NSDictionary *dictionary = [[NSDictionary alloc]
                                        initWithObjectsAndKeys:newUagent, @"UserAgent",nil,nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if ([webView2 respondsToSelector:@selector(setCustomUserAgent:)]) {
                [webView2 setCustomUserAgent:newUagent];
            }
        }
        if (completeHandle) {
            completeHandle(webView2);
        }
    }];
}

//视频横屏播放直接退出后状态栏会被隐藏，所以这里要设置一下状态栏显示(目前h5用的是原声自定义播放器，所以没用到这个方法)
//- (void)endPlayVideo:(NSNotification *)notification {
//    if ([[UIApplication sharedApplication].keyWindow isMemberOfClass:[UIWindow class]]){
//        [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    }
//}


- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame=CGRectMake(0,10,40,20);
        [_closeBtn addTarget:self action:@selector(popVC)
         forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _closeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _closeItem = [[UIBarButtonItem alloc] initWithCustomView:_closeBtn];
    }
    return _closeItem;
}

- (UIBarButtonItem *)fixBar {
    if (_fixBar)return _fixBar;
    _fixBar = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    _fixBar.width = 15;
    return _fixBar;
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    self.webView.scrollView.bounces = _bounces;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.webView.scrollView.delegate == nil) {
        self.webView.scrollView.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.webView.scrollView.delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_videoView.videoPlayView) {
        [_videoView.videoPlayView jp_stopPlay];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        });
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_videoView.videoPlayView.jp_videoPlayerView) {
        [_videoView playVideo];
    }
}

//监听手势滑动返回。from：返回的起始页，to：返回的结果页
- (void)fullScreenPopGestureCompletedFrom:(UIViewController *)from to:(UIViewController *)to {
    [super fullScreenPopGestureCompletedFrom:from to:to];
    if ([to respondsToSelector:@selector(refresh)]) {
        [to performSelector:@selector(refresh)];
    }
    if ([from respondsToSelector:@selector(removeScriptMessageHandler)]) {
        [from performSelector:@selector(removeScriptMessageHandler)];
    }
}

#pragma mark - addObserverKeyboard
///// 键盘将要弹起
- (void)keyBoardShow {
    self.keyBoardHide = NO;
}
///// 键盘将要隐藏
- (void)keyBoardHidden:(NSNotification *)notification {
   self.keyBoardHide = YES;
    CGFloat actionDelayTime = 0.04;
    CGFloat navH = self.isHiddenNav?0:NAV_HEIGHT;
    __block double pianYi = self.webView.scrollView.contentOffset.y + (ScreenHeight-navH) - self.webView.scrollView.contentSize.height;
    __block CGPoint ontentOffset = CGPointMake(0, self.webView.scrollView.contentSize.height - (ScreenHeight-navH));
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(actionDelayTime * NSEC_PER_SEC)),dispatch_get_global_queue(0, 0), ^{
        if (self.keyBoardHide) {
            NSDictionary *userInfo = notification.userInfo;
            // 动画的持续时间
            double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            if (@available(iOS 12.0, *)) {
                  
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration-actionDelayTime) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [UIView animateWithDuration:(duration-actionDelayTime) animations:^{
                          UIScrollView *scrollView = [self.webView scrollView];
                          if (pianYi > 0) {
                              [scrollView setContentOffset:ontentOffset];
                          }
                      }];
                  });
 
             }
            
        }
    });
    
}


- (GLPlayerView *)videoView {
    if (_videoView) return _videoView;
    _videoView = [[GLPlayerView alloc] init];
    return _videoView;
}

- (void)dealloc {
    _config = nil;
    _webViewModel = nil;
}

@end
