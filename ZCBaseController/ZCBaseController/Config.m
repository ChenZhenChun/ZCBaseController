//
//  Config.m
//  ZJJKMGDoctor
//
//  Created by gulu on 17/8/1.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import "Config.h"
#import "ZOEAlertView.h"
#import "MacroDefinition.h"
#import "NSObject+GLHUD.h"

@interface Config ()
@property (nonatomic,strong)NSDictionary    *configDict;
@property (nonatomic,copy) NSString         *appleId;
@property (nonatomic,copy) NSString         *appStoreUrl;//app下载页
@property (nonatomic,copy) NSString         *downloadUrl;
@property (nonatomic,copy) NSString         *servicePhone;//客服电话
@property (nonatomic,assign) int            imAppId;
@property (nonatomic,assign) int            imApnsBusinessId;
@property (nonatomic,copy) NSString         *imAppkey;
@property (nonatomic,copy) NSString         *imPushKitCerName;
@property (nonatomic,copy) NSString         *imPushKitDevCerName;
@property (nonatomic,copy) NSString         *imApnsCerName;
@property (nonatomic,copy) NSString         *qCloudAppId;
@property (nonatomic,copy) NSString         *qCloudRegionName;
@property (nonatomic,copy) NSString         *prodCode;
@property (nonatomic,strong) NSDictionary   *linkfaceDict;
@end

@implementation Config

- (NSDictionary*)configDict{
    if (!_configDict) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"];
        _configDict =[[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    return _configDict;
}

- (NSString *)appStoreUrl {
    NSDictionary *downloadLink = [[Config sharedInstance].configDict valueForKey:@"DownloadLink"];
    return [downloadLink valueForKey:@"AppStore"];
}

- (NSString *)downloadUrl {
    NSDictionary *downloadLink = [[Config sharedInstance].configDict valueForKey:@"DownloadLink"];
    return [downloadLink valueForKey:@"DownloadUrl"];
}

- (NSString *)appleId {
    if (_appleId) return _appleId;
    _appleId = [[Config sharedInstance].configDict valueForKey:@"AppleId"];
    return _appleId;
}

- (NSString *)servicePhone {
    if (_servicePhone) return _servicePhone;
    _servicePhone = [[Config sharedInstance].configDict valueForKey:@"ServicePhone"];
    return _servicePhone;
}

- (int)imAppId {
    if (_imAppId) return _imAppId;
    _imAppId = [[Config sharedInstance].configDict[@"IM"][@"IMAppId"] intValue];
    return _imAppId;
}

- (int)imApnsBusinessId {
    if (_imApnsBusinessId) return _imApnsBusinessId;
#ifdef DEBUG
    _imApnsBusinessId = [[Config sharedInstance].configDict[@"IM"][@"IMApnsDevBusinessId"]intValue];
#else
    _imApnsBusinessId = [[Config sharedInstance].configDict[@"IM"][@"IMApnsBusinessId"]intValue];
#endif
    return _imApnsBusinessId;
}

- (NSString *)imAppkey {
    if (_imAppkey) return _imAppkey;
    _imAppkey = [Config sharedInstance].configDict[@"IM"][@"IMAppkey"];
    return _imAppkey;
}

- (NSString *)imPushKitCerName {
    if (_imPushKitCerName) return _imPushKitCerName;
    _imPushKitCerName = [Config sharedInstance].configDict[@"IM"][@"IMPushKitCerName"];
    return _imPushKitCerName;
}

- (NSString *)imPushKitDevCerName {
    if (_imPushKitDevCerName) return _imPushKitDevCerName;
    _imPushKitDevCerName = [Config sharedInstance].configDict[@"IM"][@"IMPushKitDevCerName"];
    return _imPushKitDevCerName;
}

- (NSString *)imApnsCerName {
    if (_imApnsCerName) return _imApnsCerName;
#ifdef DEBUG
    _imApnsCerName = [Config sharedInstance].configDict[@"IM"][@"IMApnsDevCerName"];
#else
    _imApnsCerName = [Config sharedInstance].configDict[@"IM"][@"IMApnsCerName"];
#endif
    return _imApnsCerName;
}


- (NSString *)qCloudAppId {
    if (_qCloudAppId) return _qCloudAppId;
    _qCloudAppId = [Config sharedInstance].configDict[@"QCloudCOS"][@"QCloudAppId"];
    return _qCloudAppId;
}

- (NSString *)qCloudRegionName {
    if (_qCloudRegionName) return _qCloudRegionName;
    _qCloudRegionName = [Config sharedInstance].configDict[@"QCloudCOS"][@"QCloudRegionName"];
    return _qCloudRegionName;
}

- (NSString *)appCode {
    if (_appCode) return _appCode;
    _appCode = [Config sharedInstance].configDict[@"AppCode"];
    return _appCode;
}

- (NSString *)orgCode {
    if (_orgCode) return _orgCode;
    _orgCode = [Config sharedInstance].configDict[@"OrgCode"];
    return _orgCode?:@"";
}

- (NSString *)prodCode {
    if (_prodCode) return _prodCode;
    _prodCode = [Config sharedInstance].configDict[@"ProdCode"];
    return _prodCode;
}

- (NSDictionary *)linkfaceDict {
    if (_linkfaceDict) return _linkfaceDict;
    _linkfaceDict = [Config sharedInstance].configDict[@"Linkface"];
    return _linkfaceDict;
}

- (void)callPhoneAction {
    NSString *message = [NSString stringWithFormat:@"是否拨打 %@ 客服电话？",self.servicePhone];
    ZOEAlertView *alertView = [[ZOEAlertView alloc]initWithTitle:nil message:message  cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView setButtonTextColor:rgb(71, 133, 255) buttonIndex:1];
    [alertView showWithBlock:^(NSInteger buttonIndex) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            NSString *deviceType = [UIDevice currentDevice].model;
            if([deviceType  isEqualToString:@"iPod touch"]||[deviceType  isEqualToString:@"iPad"]||[deviceType  isEqualToString:@"iPhone Simulator"]){
                [self hud_showHintTip:@"该设备不支持拨打电话功能"];
                return;
            }
            UIApplication *app = [UIApplication sharedApplication];
            [app openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.servicePhone]]];
        }
    }];
}

+ (Config *)sharedInstance {
    static Config *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


@end
