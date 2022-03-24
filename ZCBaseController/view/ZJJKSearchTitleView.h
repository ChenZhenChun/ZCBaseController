//
//  ZJJKSearchTitleView.h
//  BMom
//  搜索框视图
//  Created by gulu on 2017/9/19.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJJKXibBaseView.h"
@class ZJJKSearchTitleView;

@protocol zjjkSearchTitleViewDelegate <NSObject>
@required
- (void)zjjk_searchTitleView:(ZJJKSearchTitleView *)searchTitleView textField:(UITextField *)textField;
- (void)zjjk_searchTitleView:(ZJJKSearchTitleView *)searchTitleView didCancel:(UIButton *)cancelBtn;
@optional
- (void)zjjk_searchTitleView:(ZJJKSearchTitleView *)searchTitleView textFieldShouldReturn:(UITextField *)textField;
@end

@interface ZJJKSearchTitleView : ZJJKXibBaseView
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,assign) id <zjjkSearchTitleViewDelegate> delegate;
@end
