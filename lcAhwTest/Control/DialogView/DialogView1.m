//
//  DialogView1.m
//  lcAhwTest
//
//  Created by licheng on 15/11/11.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "DialogView1.h"
#import "KUtils.h"

@implementation DialogView1

- (id)initWithBgFrame:(CGRect)bgFrame andContainerSize:(CGSize)containerSize
{
    self = [super initWithFrame:bgFrame];
    if (self)
    {
        // 背景遮罩层
        //UIView *bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];  // 竖屏
        //UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_HEIGHT, kSCREEN_WIDTH)];  // 横屏
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = [UIColor lightGrayColor];
        bgView.alpha = 0.8;
        [self addSubview:bgView];
        
        // 弹出框
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerSize.width, containerSize.height)];
        containerView.center = self.center;
        containerView.backgroundColor = kCOLORRGB(46.0, 46.0, 46.0);
        containerView.layer.cornerRadius = 5;
        [self addSubview:containerView];  // 遮罩层半透明，弹出框不透明
        
        // 按钮 取消
        CGFloat marginSpace = 10;
        CGFloat btnMargin = 20;
        CGFloat btnW = 80;
        CGFloat btnH = 30;
        CGFloat btnCancel_X = (containerView.bounds.size.width - btnW*2 - btnMargin) / 2;
        CGFloat btnCancel_Y = containerView.bounds.size.height - btnH - marginSpace;
        CGRect rect = CGRectMake(btnCancel_X, btnCancel_Y, btnW, btnH);
        UIButton *btnCancel = [KUtils createButtonWithFrame:rect title:@"取消" titleColor:[UIColor whiteColor] target:self tag:0];
        btnCancel.backgroundColor = [UIColor orangeColor];
        [containerView addSubview:btnCancel];
        
        // 按钮 确定
        rect = CGRectMake(CGRectGetMaxX(btnCancel.frame) + btnMargin, CGRectGetMinY(btnCancel.frame), btnW, btnH);
        UIButton *btnYes = [KUtils createButtonWithFrame:rect title:@"确定" titleColor:[UIColor whiteColor] target:self tag:1];
        btnYes.backgroundColor = [UIColor orangeColor];
        [containerView addSubview:btnYes];
        
        // 横线
        rect = CGRectMake(0, CGRectGetMinY(btnCancel.frame) - marginSpace, containerView.bounds.size.width, 1);
        UIView *lineView = [[UIView alloc] initWithFrame:rect];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [containerView addSubview:lineView];
        
        // 文字
        rect = CGRectMake(marginSpace, marginSpace, containerView.bounds.size.width - marginSpace * 2, CGRectGetMinY(lineView.frame) - marginSpace * 2);
        UILabel *lbMsg = [KUtils createLabelWithFrame:rect text:@"msg 呜哇哈哈吼吼嘎嘎呜哇哈哈吼吼嘎嘎呜哇哈哈吼吼嘎嘎 msg" fontSize:14 textAlignment:NSTextAlignmentLeft tag:kDEFAULT_TAG];
        lbMsg.textColor = [UIColor whiteColor];
        lbMsg.numberOfLines = 0;
        [containerView addSubview:lbMsg];
        
        // 动画 系统弹窗效果
        [UIView animateWithDuration:0.1 animations:^(void){
            containerView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                containerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        }];
        
        // drawRect 遮罩层 渐变透明色
        self.backgroundColor = [UIColor clearColor];
        bgView.backgroundColor = [UIColor clearColor];
        
        // window  直接显示 不需要addSubview 但无法横屏
        //[[UIApplication sharedApplication].keyWindow addSubview:self];
        //[[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    }
    return self;
}


- (void)buttonAction:(UIButton *)btn
{
    if (btn.tag == 0)
    {
//        [_bgView removeFromSuperview];
//        [_containerView removeFromSuperview];
        [self removeFromSuperview];
    }
    
    // block
    if (self.onBtnsTouchUpInside)
    {
        self.onBtnsTouchUpInside(self, (int)btn.tag);
    }
}


// 遮罩层渐变透明色  self.backgroundColor = clearColor
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    size_t gradLocationsCount = 2;
    CGFloat gradLocations[2] = {0.0f, 1.0f};
    CGFloat gradColors[8] = {0, 0, 0, 0, 0, 0, 0, 0.8};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsCount);
    CGColorSpaceRelease(colorSpace), colorSpace = NULL;
    CGPoint gradCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float gradRadius = MAX(self.bounds.size.width , self.bounds.size.height);
    //float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height);
    CGContextDrawRadialGradient (context, gradient, gradCenter, 0, gradCenter, gradRadius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
}


@end
