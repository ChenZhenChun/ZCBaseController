//
//  ZJJKSectionHeadView.m
//  ZJJKMGDoctor
//
//  Created by gulu on 2018/1/23.
//  Copyright © 2018年 gulu. All rights reserved.
//

#import "ZJJKSectionHeadView.h"

@interface ZJJKSectionHeadView()
@property (nonatomic,strong) UILabel *redDoc;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBtnTop;
@end

@implementation ZJJKSectionHeadView
@synthesize backgroundView = _backgroundView;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,44);
    self.autoresizingMask = UIViewAutoresizingNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSelfAction)];
    [self addGestureRecognizer:tap];
}

- (instancetype)init {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil] lastObject];
}
- (IBAction)clickRightBtn:(UIButton *)sender {
    if (_clickSectionRightBtnBlock) {
        _clickSectionRightBtnBlock();
        return;
    }
    if (_clickSectionRrrows) {
        _clickSectionRrrows();
    }
}

- (void)clickSelfAction {
    if (_clickSectionRrrows) {
        _clickSectionRrrows();
    }
}


#pragma mark - Properties
- (UILabel *)redDoc {
    if (_redDoc) return _redDoc;
    _redDoc = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-15-15-8,self.frame.size.height/2.0-8/2.0,8,8)];
    _redDoc.backgroundColor = [UIColor colorWithRed:247/255.0 green:76/255.0 blue:49/255.0 alpha:1];
    _redDoc.clipsToBounds = YES;
    _redDoc.layer.cornerRadius = 4;
    [self addSubview:_redDoc];
    return _redDoc;
}

- (void)setRead:(BOOL)read {
    _read = read;
    self.redDoc.hidden = _read;
}

- (void)setClickSectionRrrows:(void (^)(void))clickSectionRrrows {
    _clickSectionRrrows = clickSectionRrrows;
    _rightBtn.hidden = _clickSectionRrrows?NO:YES;
}

- (void)setClickSectionRightBtnBlock:(void (^)(void))clickSectionRightBtnBlock {
    _clickSectionRightBtnBlock = clickSectionRightBtnBlock;
    _rightBtn.hidden = _clickSectionRightBtnBlock?NO:YES;
}

- (void)setTopH:(CGFloat)topH {
    _topH = topH;
    _titleTop.constant = _topH;
    _rightBtnTop.constant = _topH;
}

@end
