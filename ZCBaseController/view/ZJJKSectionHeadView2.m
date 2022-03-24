//
//  ZJJKSectionHeadView2.m
//  ZJJKMGDoctor
//
//  Created by gulu on 2017/7/21.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import "ZJJKSectionHeadView2.h"

@interface ZJJKSectionHeadView2()

@property (weak, nonatomic) IBOutlet UILabel *unReadCountL;


@end

@implementation ZJJKSectionHeadView2
@synthesize backgroundView = _backgroundView;
- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,44);
    self.autoresizingMask = UIViewAutoresizingNone;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSelfAction)];
    [self addGestureRecognizer:tap];
    
    _unReadCountL.layer.cornerRadius = _unReadCountL.frame.size.height/2.0;
    _unReadCountL.layer.masksToBounds = YES;
    _unReadCountL.backgroundColor = [UIColor colorWithRed:1 green:120/255.0 blue:74/255.0 alpha:1];
    _unReadCountL.hidden = YES;
}

- (instancetype)init {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil] lastObject];
}
- (IBAction)clickRightBtn:(UIButton *)sender {
    if (_clickSectionRrrows) {
        _clickSectionRrrows();
    }
}

- (void)clickSelfAction {
    if (_clickSectionRrrows) {
        _clickSectionRrrows();
    }
}

- (void)setClickSectionRrrows:(void (^)(void))clickSectionRrrows {
    _clickSectionRrrows = clickSectionRrrows;
    _rightBtn.hidden = _clickSectionRrrows?NO:YES;
}

- (void)setUnReadCount:(NSString *)unReadCount {
    _unReadCount = unReadCount;
//    if ([NSString isBlankString:unReadCount] || [unReadCount isEqualToString:@"0"]) {
//        _unReadCountL.hidden = YES;
//    } else {
//        _unReadCountL.hidden = NO;
//        NSAttributedString *attStr = [self textFrameWithString:unReadCount];
//        _unReadCountL.attributedText = attStr;
//    }
}

- (NSAttributedString *)textFrameWithString:(NSString *)str {
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    // 对齐方式
    style.alignment = NSTextAlignmentJustified;
    // 首行缩进
    style.firstLineHeadIndent = 10.0f;
    // 头部缩进
    style.headIndent = 5.0f;
    // 尾部缩进
    style.tailIndent = 5.0f;
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:str attributes:@{ NSParagraphStyleAttributeName : style}];
    return attrText;
}
@end
