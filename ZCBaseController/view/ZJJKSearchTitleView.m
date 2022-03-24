//
//  ZJJKSearchTitleView.m
//  BMom
//
//  Created by gulu on 2017/9/19.
//  Copyright © 2017年 gulu. All rights reserved.
//

#import "ZJJKSearchTitleView.h"

@interface ZJJKSearchTitleView()<UITextFieldDelegate>
{
    NSInteger               _oldLength;
}

@property (nonatomic,assign) CGSize intrinsicContentSize;
@end

@implementation ZJJKSearchTitleView


- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,50);
    self.intrinsicContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,50);
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,15+15+10,36)];
    leftView.backgroundColor = [UIColor clearColor];
    UIImageView *placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15,10.5,15,15)];
    placeholderImageView.image = [UIImage imageNamed:@"disp_search"];
    [leftView addSubview:placeholderImageView];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.leftView = leftView;
    _textField.delegate = self;
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _oldLength = _textField.text.length;
    
}

- (void)cancelDidClick:(UIButton *)sender {
    self.textField.text = nil;
    _oldLength = 0;
    if ([self.delegate respondsToSelector:@selector(zjjk_searchTitleView:didCancel:)]) {
        [self.delegate zjjk_searchTitleView:self didCancel:sender];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self cancelDidClick:nil];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(zjjk_searchTitleView:textFieldShouldReturn:)]) {
        [self.delegate zjjk_searchTitleView:self textFieldShouldReturn:_textField];
    }
    return YES;
}

//过滤emoji表情
- (void)textFieldDidChange:(UITextField *)textField {
    if ([ZJJKSearchTitleView stringContainsEmoji:textField.text]) {
        textField.text = [textField.text substringToIndex:_oldLength];
        return;
    }
    if (textField == self.textField && textField.text.length && !textField.markedTextRange) {
        _oldLength = textField.text.length;
    }else if(textField.text.length == 0) {
        _oldLength = 0;
    }
    if ([self.delegate respondsToSelector:@selector(zjjk_searchTitleView:textField:)]) {
        [self.delegate zjjk_searchTitleView:self textField:textField];
    }
}

//是否包含emoji表情
+ (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f9dc) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3 || ls == 0xfe0f) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

@end
