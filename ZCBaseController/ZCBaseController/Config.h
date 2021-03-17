//
//  Config.h
//  ZJJKMGDoctor
//
//  Created by gulu on 17/8/1.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

+ (Config *)sharedInstance;
@property (nonatomic,readonly) NSDictionary     *configDict;
@property (nonatomic,readonly) NSString         *appleId;
@property (nonatomic,readonly) NSString         *appStoreUrl;//app下载页
@property (nonatomic,readonly) NSString         *downloadUrl;
@property (nonatomic,readonly) NSString         *servicePhone;//客服电话
@property (nonatomic,readonly) NSString         *imAppkey;
@property (nonatomic,readonly) NSString         *imPushKitCerName;
@property (nonatomic,readonly) NSString         *imPushKitDevCerName;
@property (nonatomic,readonly) NSString         *imApnsCerName;
@property (nonatomic,readonly) NSString         *qCloudAppId;
@property (nonatomic,readonly) NSString         *qCloudRegionName;
@property (nonatomic,readonly) NSString         *appCode;
@property (nonatomic,readonly) NSString         *prodCode;
@property (nonatomic,copy) NSString             *orgCode;
@property (nonatomic,copy) NSString             *commonsSessionId;//平台要求的身份令牌
@property (nonatomic,readonly) NSDictionary     *linkfaceDict;//api_id,api_secret

/**
 拨打客服电话
 */
- (void)callPhoneAction;

@end
