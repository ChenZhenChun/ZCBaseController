//
//  ZJJKBaseOkBtnView.m
//  ZJJKMGDoctor
//
//  Created by czc on 2020/5/25.
//  Copyright © 2020 zjjk. All rights reserved.
//

#import "ZJJKBaseOkBtnView.h"

@implementation ZJJKBaseOkBtnView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,60);
}

- (IBAction)okBtnAction:(UIButton *)sender {
    if (self.clickOKBtnBlock) {
        self.clickOKBtnBlock(sender);
    }
}

- (void)setShadow:(BOOL)shadow {
    _shadow = shadow;
    if (_shadow) {
        self.layer.shadowColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:0.06].CGColor;
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 5;
        self.layer.shadowOffset = CGSizeMake(0,-3);
    }
}

@end
