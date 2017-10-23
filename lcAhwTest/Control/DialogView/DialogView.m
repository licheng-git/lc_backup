//
//  DialogView.m
//  lcAhwTest
//
//  Created by licheng on 15/6/11.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "DialogView.h"
#import "Constants.h"

@interface DialogView()
{
    UIButton *_closeBtn;
}
@end

@implementation DialogView

- (id)initWithContainerFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
    if (self)
    {
        //self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]; // 遮罩层颜色和透明度（self其实是个遮罩层）
        //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_img1.png"]];
        
        // 这样搞遮罩层更好
        UIView *bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.8;  // 透明度：0透明，1不透明
        //bgView.layer.opacity = 0.8;  // 效果同alpha
        [self addSubview:bgView];
        
        
        self.containerView = [[UIView alloc] initWithFrame:frame];  // containerView才是实际的弹出框
        [self addSubview:self.containerView];
        self.containerView.backgroundColor = [UIColor clearColor];
        self.containerView.layer.opacity = 0.8;
        self.containerView.layer.cornerRadius = 7; // 圆角
        
        // 关闭按钮
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.origin.x-10, frame.origin.y-10, 30, 30)];
        [self addSubview:_closeBtn];
        [_closeBtn setImage:[UIImage imageNamed:@"cross_img@2x"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)show
{
//    [self.containerView addSubview:_closeBtn];
//    [self.containerView bringSubviewToFront:_closeBtn];  // 按钮不能被挡住
//    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
//    //[[UIApplication sharedApplication].keyWindow addSubview:self];
    
    
//    [[UIApplication sharedApplication].keyWindow addSubview:self];
//    // 动画效果
//    CATransition *animation = [CATransition animation];
//    animation.duration = 0.5;
//    animation.timingFunction = UIViewAnimationCurveEaseInOut;
//    animation.fillMode = kCAFillModeForwards;
//    animation.type = kCATransitionMoveIn;
//    animation.subtype = kCATransitionFromTop;
//    [self.containerView.layer addAnimation:animation forKey:@"animation"];
//    
//    // CABasicAnimation
//    // CAKeyframeAnimation
//    // CATransition
    
    
    _closeBtn.hidden = YES;
    CGRect oldFrame = self.containerView.frame;
    self.containerView.frame = CGRectMake(oldFrame.origin.x, kSCREEN_HEIGHT, oldFrame.size.width, oldFrame.size.height);
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
//    //[((UIViewController *)_delegate).view addSubview:self];
//    UIViewController *deleVC = (UIViewController *)_delegate ;
//    if (deleVC.tabBarController)
//    {
//        [deleVC.tabBarController.view addSubview:self];
//    }
//    else if (deleVC.navigationController)
//    {
//        [deleVC.navigationController.view addSubview:self];
//    }
//    else
//    {
//        [deleVC.view addSubview:self];
//    }

    // 动画效果
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.containerView.frame = oldFrame;
                     }
                     completion:^(BOOL finished){
                         _closeBtn.hidden = NO;
                     }];
    
//    // 系统弹窗效果（吐司效果）
//    [UIView animateWithDuration:0.2 animations:^(void){
//        self.containerView.transform = CGAffineTransformMakeScale(1.05, 1.05);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.2 animations:^{
//            self.containerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
//        }];
//        _closeBtn.hidden = NO;
//    }];
    
//    // 动画效果
//    [UIView beginAnimations:@"animationID" context:nil];
//    [UIView setAnimationDuration:0.5];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationTransition:UIViewAnimationTransitionNone
//                           forView:self
//                             cache:NO];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(animationFinished:context:)];
//    self.containerView.frame = oldFrame;
//    [UIView commitAnimations];
}

//- (void)animationFinished:(NSString *)animationID context:(void *)context
//{
//    if ([animationID isEqualToString:@"animationID"])
//    {
//        _closeBtn.hidden = NO;
//    }
//}

- (void)close
{
    [self removeFromSuperview];
}

@end
