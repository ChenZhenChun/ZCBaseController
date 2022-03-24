//
//  ZJJKSectionHeadView.h
//  ZJJKMGDoctor
//
//  Created by gulu on 2018/1/23.
//  Copyright © 2018年 gulu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJJKSectionHeadView : UITableViewHeaderFooterView 
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (nonatomic,assign) BOOL read;
@property (weak, nonatomic) IBOutlet UIImageView *hotIcon;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic,assign) CGFloat topH;

@property (nonatomic,copy) void(^clickSectionRrrows)(void);
@property (nonatomic,copy) void(^clickSectionRightBtnBlock)(void);
@end
