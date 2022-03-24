//
//  ZJJKXibBaseView.m
//  ZJIHHBZSYY
//
//  Created by gulu on 2018/9/13.
//  Copyright © 2018年 gulu. All rights reserved.
//

#import "ZJJKXibBaseView.h"

@interface ZJJKXibBaseView ()
@property (nonatomic,assign) CGSize intrinsicContentSize;
@end


@implementation ZJJKXibBaseView

- (instancetype)init {
    NSString *nibName = NSStringFromClass([self class]);
    self = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] lastObject];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingNone;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.intrinsicContentSize = CGSizeMake(frame.size.width,frame.size.height);
}

@end
