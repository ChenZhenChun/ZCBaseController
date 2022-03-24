//
//  ZJJKSectionHeadView2.h
//  ZJJKMGDoctor
//
//  Created by gulu on 2017/7/21.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJJKSectionHeadView2 : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (nonatomic,copy) void(^clickSectionRrrows)(void);
@property (nonatomic, strong) NSString *unReadCount;
@end
