//
//  WebViewModel.m
//  ZJJKMGDoctor
//
//  Created by gulu on 2017/7/28.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import "WebViewModel.h"
#import "ZOEAlertView.h"
#import "ZOEActionSheet.h"
#import "NSString+Category.h"
#import "MJExtension.h"
#import "MacroDefinition.h"
#import "UIColor+Hex.h"
#import "NSArray+Category.h"
#import "NSObject+GLHUD.h"

@interface WebViewModel()
{
    NSArray                 *_menuKey;//小控件的key
}
@property (nonatomic,weak) GLBaseWebViewController *vc;
@end

@implementation WebViewModel

- (instancetype)initWithController:(GLBaseWebViewController *)baseWebViewController {
    self = [super init];
    if (self) {
        _vc = baseWebViewController;
        _menuKey = @[@"SelectPhoto",@"PickView",@"KeyboardAccessoryView"];
    }
    return self;
}

/**
 弹出alert窗口
 
 @param dic
 {
 "title": "提醒标题",
 "message": "我是主要内容",
 "cancelBtn": "取消",
 "otherBtn": [
 "我知道了！",
 "去添加"
 ],
 "callbacks": "sayHelloFunCallback();",//如果需要返回点击的按钮索引，这样写sayHelloFunCallback(#);
 "btnColorByIndex": [
 null,
 "#FFB6C1",
 "#4682B4"
 ],
 "messageTextAlignment":0, //0左 1中 2右 默认居中
 "lineSpacing":5,//默认5
 "animated": true
 }
 */
#pragma mark - AlertView
- (void)showAlertView:(NSDictionary *)dic {
    if (dic) {
        ZOEAlertView *alertView = [[ZOEAlertView alloc] initWithTitle:dic[@"title"] message:dic[@"message"] cancelButtonTitle:dic[@"cancelBtn"] otherButtonTitles:nil, nil];
        NSString *messageTextAlignment             = [dic[@"messageTextAlignment"] stringValue];
        NSString *lineSpacing             = [dic[@"lineSpacing"] stringValue];
        NSArray *btnArray = [NSString mj_objectArrayWithKeyValuesArray:dic[@"otherBtn"]];
        
        if (![NSString isBlankString:messageTextAlignment]) {
            alertView.messageTextAlignment = [messageTextAlignment integerValue];
        }
        
        if (![NSString isBlankString:lineSpacing]) {
            alertView.lineSpacing = [lineSpacing integerValue];
        }
        
        //添加按钮
        for (NSString *btn in btnArray) {
            [alertView addButtonWithTitle:btn];
        }
        
        //显示控件
        [alertView showWithBlock:^(NSInteger buttonIndex) {
            NSString *callback = dic[@"callbacks"];
            if (![NSString isBlankString:callback]) {
                callback = [callback stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"%ld",(long)buttonIndex]];
                [_vc.webView evaluateJavaScript:callback completionHandler:nil];
            }
        } animated:[dic[@"animated"]boolValue]];
        
        //设置按钮颜色(如果是用addButtonWithTitle添加的按钮，颜色只能放在showWithBlock后面)
        if (btnArray &&btnArray.count>0) {
            [alertView setButtonTextColor:rgb(71, 133, 255) buttonIndex:1];
            if (![NSString isBlankString:dic[@"cancelBtn"]]) {
                [alertView setButtonTextColor:rgb(51,51,51) buttonIndex:0];
            }
        }else {
            [alertView setButtonTextColor:rgb(71, 133, 255) buttonIndex:0];
        }
        
        NSArray *colorBtnAryy = [NSString mj_objectArrayWithKeyValuesArray:dic[@"btnColorByIndex"]];
        for (int i = 0; i<colorBtnAryy.count;i++) {
            NSString *hexString = colorBtnAryy[i];
            if ([NSString isBlankString:hexString]) continue;
            UIColor *textColor = [UIColor uks_colorWithHexString:hexString];
            [alertView setButtonTextColor:textColor buttonIndex:i];
        }
    }
}


/**
 关闭一个浏览器窗口
 */
#pragma mark - 关闭浏览器
- (void)goback {
    [_vc backOnView];
}


/**
 调用原生小控件
 
 @param dic
 {
 //分享菜单
 "menuType":"ShareView",//控件类型 eg. ShareView(分享)、SelectPhoto（图片选择）、PickView（日期选择）、KeyboardAccessoryView（键盘附带view）
 "callbacks": "sayHelloFunCallback(#);",//回调函数,
 "errorCallbacks":"sayHelloFunCallback(#);",//错误的回调函数
 "parameters":{
    "isHasYanxu":true,//是否有优科室分享，default is true
    "isHasCopy":true,//是否有复制链接，default is true
    "type":"fist-text",
    "contentUrl":"",//分享链接地址
    "imageUrl":"",//分享的图片（默认为优科室icon）
    "title":"",//标题
    "detailText":""//副标题（优科室分享需要）
 }
 
 }
 */
#pragma mark - 调用原生小控件
- (void)showMenuView:(NSDictionary *)dic {
    NSString *menuType = [dic objectForKey:@"menuType"];
    //分享菜单
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"push%@:",menuType]);
    if ([self respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:sel withObject:dic];
#pragma clang diagnostic pop
    }else {
        NSString *errorCallbacks = [dic objectForKey:@"errorCallbacks"];
        if (![NSString isBlankString:errorCallbacks]) {
            NSString *errorStr = [NSString stringWithFormat:@"%@ is undefined",menuType];
            errorCallbacks = [errorCallbacks stringByReplacingOccurrencesOfString:@"#" withString:errorStr];
            [self.vc.webView evaluateJavaScript:errorCallbacks completionHandler:nil];
        }
    }
}


/**
 赋值到剪贴板

 @param dic {
 "string":""
 }
 */
#pragma mark - 赋值到剪贴板
- (void)generalPasteboard:(NSDictionary *)dic {
    NSString *string = dic[@"string"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = string;
}


/**
 本地是否安装了某app

 @param dic {
    "scheme":"", // eg. "taobao" | "taobao://"
    "callback":"xxxxxxx(#)"
 }
 */
#pragma mark - 本地是否安装了某app
- (void)isHasAppByScheme:(NSDictionary *)dic {
    NSString *scheme = [dic objectForKey:@"scheme"];
    NSString *callback = dic[@"callback"];
    BOOL flag = NO;
    if ([WebViewModel isInstalledAppByScheme:scheme]) {
        flag = YES;
    }
    if (![NSString isBlankString:callback]) {
        callback = [callback stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"%d",flag]];
        [_vc.webView evaluateJavaScript:callback completionHandler:nil];
    }
}


/**
 h5网页视频横屏播放
 */
#pragma mark - h5网页视频横屏播放
- (void)videoPlayerFullScreen {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

/**
 调用播放器
 
 @param dic {
    "videoUrl":"http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4",
    "x":0,//默认0
    "y":0,//默认0
    "height":200,//不传默认是(width*9/16);
    "width":320,//不传默认是屏幕宽度
    "title":"海贼王",
    "fixed":true,固定
    "autoPlay":true,
    "cover":"url string"
 }
 */
#pragma mark - 调用播放器
- (void)initGLPlayer:(NSDictionary *)dic {
    NSString *videoUrl      = dic[@"videoUrl"];
//    NSString *title         = dic[@"title"];
    NSString *cover         = dic[@"cover"];
    CGFloat   x             = [dic[@"x"] floatValue];
    CGFloat   y             = [dic[@"y"] floatValue];
    CGFloat   width         = [dic[@"width"]floatValue];
    CGFloat   height        = [dic[@"height"]floatValue];
    CGFloat   fixed         = [dic[@"fixed"]floatValue];
    NSString  *autoPlayStr  = [dic[@"autoPlay"]stringValue];
    BOOL      autoPlay      = true;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (width==0) {
        width = ScreenWidth;
    }else {
       width = width/scale;
    }
    if (height==0) {
        height = width*9/16.0;
    }else {
        height = height/2.0;
    }
    
    x = x/scale;
    y = y/scale;
    
    if (y==0 && fixed) {
        [_vc.webView evaluateJavaScript:[NSString stringWithFormat:@"document.querySelector(\".doc-details-video-components-content\").style.marginTop=\"%fpx\"",(height+10)*scale]
                      completionHandler:^(id _Nullable a, NSError * _Nullable error) {
                          if (error) {
                              DLog(@"%@",error);
                          }
                      }];
    }
    
    if (![NSString isBlankString:autoPlayStr]) {
        autoPlay = [autoPlayStr boolValue];
    }
    
    _vc.videoView.frame = CGRectMake(x,y,width,height);
    if (fixed) {
        [_vc.webView addSubview:_vc.videoView];
    }else {
        [_vc.webView.scrollView addSubview:_vc.videoView];
    }
    if (![NSString isBlankString:cover]) {
        _vc.videoView.cover = cover;
    }
    
    _vc.videoView.url = [NSURL URLWithString:videoUrl];
    
    if (autoPlay) {
        [_vc.videoView playVideo];
    }
}

/**
 控制播放器行为

 @param dic
 {
    "command":["stop","pause","resume","mute","noMute"]
 }
 */
#pragma mark - 控制播放器行为
- (void)controlGLPlayer:(NSDictionary *)dic {
    UIView *jp_videoLayerView = [_vc.webView valueForKey:@"jp_videoLayerView"];
    if (jp_videoLayerView) {
        NSArray *array = [NSString mj_objectArrayWithKeyValuesArray:dic[@"command"]];
        SEL sel = NULL;
        id value;
        for (NSString *keyName in array) {
            if ([@"stop"isEqualToString:keyName]) {
                sel = NSSelectorFromString(@"jp_stopPlay");
            }else if ([@"pause"isEqualToString:keyName]) {
                sel = NSSelectorFromString(@"jp_pause");
            }else if ([@"resume"isEqualToString:keyName]) {
                sel = NSSelectorFromString(@"jp_resume");
            }else if ([@"mute"isEqualToString:keyName]) {
                sel = NSSelectorFromString(@"jp_setPlayerMute:");
                value = @(YES);
            }else if ([@"noMute"isEqualToString:keyName]) {
                sel = NSSelectorFromString(@"jp_setPlayerMute:");
                value = @(NO);
            }else if ([@"startPlay"isEqualToString:keyName]) {
                sel = NSSelectorFromString(@"playVideo");
            }
            if (sel&&[jp_videoLayerView respondsToSelector:sel]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.002 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [jp_videoLayerView performSelector:sel withObject:value];
#pragma clang diagnostic pop
                    
                });
            }else {
                [self hud_showHintTip:@"无效播放器命令"];
            }
        }
    }
}

/**
 拨打电话
 
 @param dic
 {
    "phone":"13328308137"
 }
 */
#pragma mark - 拨打电话
- (void)glCallPhone:(NSDictionary *)dic {
    NSString *phone = dic[@"phone"];
    if ([NSString isBlankString:phone]) return;
    [WebViewModel glCallPhone:phone];
}

#pragma mark - 去地图展示路线

/**
 跳转到第三方地图应用规划路线
 百度地图与高德地图、苹果地图采用的坐标系不一样，故高德和苹果只能用地名不能用百度坐标
 @param dic
 {
 "address":"智业软件",
 "latitude":24.493194995896609,
 "longitude":118.18647499659619
 }
 */
- (void)gotoMap:(NSDictionary *)dic {
    // 百度地图与高德地图、苹果地图采用的坐标系不一样，故高德和苹果只能用地名不能用百度坐标
    NSString *address = dic[@"address"]; // 送达地址
    CGFloat latitude = [dic[@"latitude"] floatValue];
    CGFloat longitude = [dic[@"longitude"] floatValue];
    
    NSMutableArray *mapArray = [[NSMutableArray alloc] init];
    if ([WebViewModel isInstalledAppByScheme:@"http://maps.apple.com"]) {
        NSString *urlString = [[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@",address] mj_url].absoluteString;
        [mapArray addObject:@{@"title":@"苹果地图",@"url":urlString}];
    }
    if ([WebViewModel isInstalledAppByScheme:@"baidumap://"]) {
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name:%@&mode=driving",latitude,longitude,address] mj_url].absoluteString;
        
        [mapArray addObject:@{@"title":@"百度地图",@"url":urlString}];
    }
    if ([WebViewModel isInstalledAppByScheme:@"iosamap://"]) {
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&sname=%@&did=BGVIS2&dname=%@&dev=0&t=0",@"我的位置",address] mj_url].absoluteString;
        
        [mapArray addObject:@{@"title":@"高德地图",@"url":urlString}];
    }
    
    if (mapArray.count) {
        ZOEActionSheet *sheet = [[ZOEActionSheet alloc] initWithTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        for (NSDictionary *dic in mapArray) {
            [sheet addButtonWithTitle:dic[@"title"]];
        }
        [sheet showWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex!=sheet.cancelButtonIndex) {
                NSDictionary *urlDic = [mapArray objectAtIndexCheck:buttonIndex-1];
                if (urlDic) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlDic[@"url"]]];
                }
            }
        }];
    }else {
        [self hud_showHintTip:@"无安装第三方地图App"];
        return;
    }
}


- (void)ccGetSignature:(NSDictionary *)dic {
    [self hud_showHintTip:[dic mj_JSONString]];
}


#pragma mark - ----------下方是私有方法，不给h5调用-------------

/**
 刷新原生页面
 
 @param dic
 {
 @"refreshNames":[@"DrugAdverseEvent"]//DrugAdverseEvent:用药不良事件
 }
 */
- (void)refreshNativePage:(NSDictionary *)dic {
    NSArray *refreshNames = [NSString mj_objectArrayWithKeyValuesArray:dic[@"refreshNames"]];
    for (NSString *name in refreshNames) {
        if (self.vc.glBaseCallBackBlock) {
            self.vc.glBaseCallBackBlock(name);
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
        }
    }
}

/**
 返回几页
 
 @param dic
 {
 @"page":1
 }
 */
- (void)popWithPage:(NSDictionary *)dic {
    NSArray *array = self.vc.navigationController.viewControllers;
    NSInteger page = [dic[@"page"] integerValue];
    if (page>(array.count-1)) {
        page = (array.count-1);
    }
    GLBaseWebViewController *baseWebVC = [array objectAtIndexCheck:(array.count-1-page)];
    [self.vc.navigationController popToViewController:baseWebVC animated:YES];
    if ([baseWebVC isKindOfClass:[GLBaseWebViewController class]]) {
        [baseWebVC.webView evaluateJavaScript:@"goBack()" completionHandler:^(id _Nullable q, NSError * _Nullable error) {
            
        }];
    }
}

/**
 返回哪个url地址页
 
 @param dic
 {
 "url":"/xxx/xxx"
 }
 */
- (void)popWithUrl:(NSDictionary *)dic {
    NSArray *array = self.vc.navigationController.viewControllers;
    NSString *url = dic[@"url"];
    if ([NSString isBlankString:url]) return;
    for (GLBaseWebViewController *baseWebVC in array) {
        if ([baseWebVC isKindOfClass:[GLBaseWebViewController class]]) {
            if (![NSString isBlankString:baseWebVC.url]&&[baseWebVC.url containsString:url]) {
                [self.vc.navigationController popToViewController:baseWebVC animated:YES];
                [baseWebVC.webView evaluateJavaScript:@"goBack()" completionHandler:^(id _Nullable q, NSError * _Nullable error) {
                    
                }];
                break;
            }
        }
    }
}

/// 传递参数给原生
/// @param dic dic description
- (void)parametersToNative:(NSDictionary *)dic {
    NSArray *array = [self.vc.navigationController viewControllers];
    [array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(GLBaseWebViewController *baseVC, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([baseVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarVC = (UITabBarController *)baseVC;
            baseVC = (GLBaseWebViewController *)tabBarVC.selectedViewController;
        }
        if ([baseVC isKindOfClass:[GLBaseWebViewController class]]) {
            if (baseVC.glBaseCallBackBlock) {
                baseVC.glBaseCallBackBlock(dic);
            }
        }else {
            *stop = YES;
        }
    }];
}


#pragma mark - 根据scheme判断是否已经安装了某应用
+ (BOOL)isInstalledAppByScheme:(NSString *)scheme {
    if ([NSString isBlankString:scheme]) {
        return NO;
    }
    if (![scheme containsString:@"://"]) {
        scheme = [NSString stringWithFormat:@"%@://",scheme];
    }
    //记得scheme必须加入白名单列表LSApplicationQueriesSchemes，不然canOpenURL无法正常使用
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]]) {
        return YES;
    }
    return NO;
}

+ (void)glCallPhone:(NSString *)phone {
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType  isEqualToString:@"iPod touch"]||
       [deviceType  isEqualToString:@"iPad"]||
       TARGET_IPHONE_SIMULATOR) {
        [self hud_showHintTip:@"您的设备不具备拨打电话的能力"];
    }else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]]];
    }
}

//刷新上一个h5页面（如果上一个页面是h5页面的话，注意要在页面pop之前调用）
+ (void)reloadPreviousWebViewWithTarget:(UIViewController *)target callback:(NSString *)callback data:(id)model  {
    if ([NSString isBlankString:callback]||!target) return;
    NSArray *vcs = target.navigationController.viewControllers;
    GLBaseWebViewController *lastObject;
    lastObject = [vcs objectAtIndexCheck:vcs.count-2];
    if (target.presentingViewController&&!lastObject) {
        UINavigationController *nav = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([nav isKindOfClass:[UITabBarController class]]) {
            nav = ((UITabBarController *)nav).selectedViewController;
        }
        lastObject = nav.viewControllers.lastObject;
    }

    if (lastObject && [lastObject isKindOfClass:NSClassFromString(@"RTContainerController")]) {
        lastObject = [lastObject valueForKeyPath:@"contentViewController"];
    }
    if (lastObject && [lastObject isKindOfClass:[GLBaseWebViewController class]]) {
        NSString *jsonStr = [model mj_JSONString];
        callback = [callback stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"'%@'",jsonStr]];
        [lastObject.webView evaluateJavaScript:callback completionHandler:^(id _Nullable a, NSError * _Nullable error) {
            DLog(@"%@",error);
        }];
    }
}


@end
