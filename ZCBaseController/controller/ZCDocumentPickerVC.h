//
//  ZCDocumentPickerVC.h
//  ZJJKMGPUBLIC-HBDXFSYY
//
//  Created by czc on 2021/5/21.
//  Copyright © 2021 zjjk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCDocumentPickerVC : NSObject

+ (instancetype)sharedInstance;

/// 下载文件
/// @param url 文件的下载地址（如果多个文件用逗号隔开）
/// @param fileName 自定义文件名称（非必填项，多个用逗号隔开）
/// @param type 缓存策略
/// @param vc 当前控制器
- (void)downLoadWithRemoteUrl:(NSString *)url
                     fileName:(NSString *)fileName
                         type:(NSInteger)type
                    currentVC:(UIViewController *)vc;
@end

NS_ASSUME_NONNULL_END
