//
//  ZCDocumentPickerVC.m
//  ZJJKMGPUBLIC-HBDXFSYY
//
//  Created by czc on 2021/5/21.
//  Copyright © 2021 zjjk. All rights reserved.
//

#import "ZCDocumentPickerVC.h"
#import "GLBaseWebViewController.h"
#import "NSObject+GLHUD.h"
#import "NSString+Common.h"
#import "NSArray+Category.h"

@interface ZCDocumentPickerVC ()<UIDocumentPickerDelegate>
@property (nonatomic,weak) GLBaseWebViewController *baseVC;
@end

@implementation ZCDocumentPickerVC

+ (instancetype)sharedInstance {
    static ZCDocumentPickerVC *documentPickerVCInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        documentPickerVCInstance = [[self alloc] init];
    });
    return documentPickerVCInstance;
}

/// 下载文件
/// @param url 文件的下载地址（如果多个文件用逗号隔开）
/// @param fileName 自定义文件名称（非必填项，多个用逗号隔开）
/// @param type 缓存策略
- (void)downLoadWithRemoteUrl:(NSString *)url fileName:(NSString *)fileName type:(NSInteger)type currentVC:(UIViewController *)vc {
    self.baseVC = (GLBaseWebViewController *)vc;
    if (@available(iOS 11.0, *)) {
        // 保存网络文件到沙盒
        NSArray *urlArray = [url componentsSeparatedByString:@","];
        NSArray *fileNameArray = [fileName componentsSeparatedByString:@","];
        NSMutableArray *urls = [[NSMutableArray alloc] init];
        [self hud_showHudInView:vc.view hint:@"下载中..."];
        for (int i= 0; i<urlArray.count ; i++) {
            NSString *objUrl = [urlArray objectAtIndexCheck:i];
            NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:objUrl]];
            NSString *fileName = [fileNameArray objectAtIndexCheck:i];
            if ([NSString isBlankString:fileName]) {
                fileName = [objUrl componentsSeparatedByString:@"/"].lastObject;
            }
            NSString *filePath = [self getNativeFilePath:fileName type:type];
            BOOL result = [fileData writeToFile:filePath atomically:YES];
            if (result) {
                [urls addObject:[NSURL fileURLWithPath:filePath]];
            }
        }
        [self hud_hide];
        if (urls.count) {
            UIDocumentPickerViewController *documentPickerVC = [[UIDocumentPickerViewController alloc] initWithURLs:urls inMode:UIDocumentPickerModeExportToService];
            [UINavigationBar appearance].tintColor = [UIColor colorWithRed:71/255.0 green:133/255.0 blue:1 alpha:1];
            // 设置代理
            documentPickerVC.delegate = self;
            // 设置模态弹出方式
            documentPickerVC.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.baseVC.navigationController presentViewController:documentPickerVC animated:YES completion:nil];
        }else {
            if (![NSString isBlankString:self.baseVC.javaScript]) {
                self.baseVC.javaScript = [self.baseVC.javaScript stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"'%@'",@"-2"]];
                [self.baseVC.webView evaluateJavaScript:self.baseVC.javaScript completionHandler:nil];
                self.baseVC.javaScript = nil;
            }else {
                [self hud_showHintTip:@"地址有误，无法下载"];
            }
        }
    }else {
        if (![NSString isBlankString:self.baseVC.javaScript]) {
            self.baseVC.javaScript = [self.baseVC.javaScript stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"'%@'",@"-2"]];
            [self.baseVC.webView evaluateJavaScript:self.baseVC.javaScript completionHandler:nil];
            self.baseVC.javaScript = nil;
        }
        [self hud_showHintTip:@"下载文件要求手机系统版本在11.0以上"];
    }
}

// 获得文件沙盒地址
- (NSString *)getNativeFilePath:(NSString *)fileName type:(NSInteger)type {
    //type = 0：Documents  1：Caches   3:tmp(临时缓存文件，系统会自动清理)
    NSSearchPathDirectory directoryType = NSDocumentDirectory;
    switch (type) {
        case 0:
            directoryType = NSDocumentDirectory;
            break;
        case 1:
            directoryType = NSCachesDirectory;
            break;
        case 2:
            directoryType = NSCachesDirectory;
            break;
        default:
            break;
    }
    NSString *path = [NSSearchPathForDirectoriesInDomains(directoryType, NSUserDomainMask, YES) lastObject];
    if (type == 3) {
        path = NSTemporaryDirectory();
    }
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    // 判断是否存在,不存在则创建
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL isDir = NO;
    NSMutableArray *theArr = [[filePath componentsSeparatedByString:@"/"] mutableCopy];
    [theArr removeLastObject];
    NSString *thePath = [theArr componentsJoinedByString:@"/"];
    BOOL existed = [fileManager fileExistsAtPath:thePath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) { // 如果文件夹不存在
        [fileManager createDirectoryAtPath:thePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    // 获取授权
    for (NSURL *url in urls) {
        BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
        if (fileUrlAuthozied) {
            // 通过文件协调工具来得到新的文件地址，以此得到文件保护功能
            NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
            NSError *error;
            [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
                // 读取文件
//                NSString *fileName = [newURL lastPathComponent];
                NSError *error = nil;
                //NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
                if (error) {
                    // 读取出错
                } else {
                    // 上传
//                    DLog(@"fileName : %@", fileName);
                }
            }];
            [url stopAccessingSecurityScopedResource];
        } else {
            // 授权失败
        }
    }
    
    if (![NSString isBlankString:self.baseVC.javaScript]) {
        self.baseVC.javaScript = [self.baseVC.javaScript stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"'%@'",@"0"]];
        [self.baseVC.webView evaluateJavaScript:self.baseVC.javaScript completionHandler:nil];
        self.baseVC.javaScript = nil;
    }

}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    if (![NSString isBlankString:self.baseVC.javaScript]) {
        self.baseVC.javaScript = [self.baseVC.javaScript stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"'%@'",@"-1"]];
        [self.baseVC.webView evaluateJavaScript:self.baseVC.javaScript completionHandler:nil];
        self.baseVC.javaScript = nil;
    }
}


@end
