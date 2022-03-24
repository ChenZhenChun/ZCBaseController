//
//  ZJBaseOkBtnView.h
//  ZJJKMGDoctor
//
//  Created by czc on 2020/5/25.
//  Copyright © 2020 zjjk. All rights reserved.
//

#import "ZJJKXibBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZJJKBaseOkBtnView : ZJJKXibBaseView
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (nonatomic,assign) BOOL shadow;
@property (nonatomic,copy) void(^clickOKBtnBlock)(UIButton *sender);
@end

NS_ASSUME_NONNULL_END
