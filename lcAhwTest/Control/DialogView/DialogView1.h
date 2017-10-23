//
//  DialogView1.h
//  lcAhwTest
//
//  Created by licheng on 15/11/11.
//  Copyright © 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogView1 : UIView

//@property (nonatomic, strong) UIView *bgView;
//@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) void (^onBtnsTouchUpInside)(DialogView1 *currentDialogView, int buttonIndex);  // block 按钮事件

// 初始化
- (id)initWithBgFrame:(CGRect)bgFrame andContainerSize:(CGSize)containerSize;
//- (id)initWithBgFrame:(CGRect)bgFrame andContainerSize:(CGSize)containerSize msg:(NSString *)msg btnCancelTitle:(nullable NSString *)btnCancelTitle btnOthersArr:(NSString *)btn1Title, ...;

@end
