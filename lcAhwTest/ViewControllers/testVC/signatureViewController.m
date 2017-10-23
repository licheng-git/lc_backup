//
//  signatureViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/11/6.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "signatureViewController.h"
#import "PJRSignatureView.h"
#import "SettingViewController.h"
#import "DialogView.h"
#import "DialogView1.h"

@interface signatureViewController()
{
    PJRSignatureView  *_signatureView;
}
@end

@implementation signatureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"手写电子签名";  // 画画，然后生成图片
    [self createView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (void)createView
{
    // 横屏
    self.view.transform = CGAffineTransformMakeRotation(M_PI*0.5);  // 绕着中点(center)旋转
    
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationLandscapeLeft animated:YES];
//    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
//    [UIView animateWithDuration:duration animations:^{
//        NSLog(@"navigationBar原始状态 (%f, %f, %f, %f)", self.navigationController.navigationBar.frame.origin.x, self.navigationController.navigationBar.frame.origin.y, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
//        CGFloat navBar_Rotation_W = kSCREEN_HEIGHT;
//        CGFloat navBar_Rotation_H = kNAVIGATION_HEIGHT;
//        CGFloat navBar_Rotation_X = 0;
//        CGFloat navBar_Rotation_Y = (kSCREEN_HEIGHT - navBar_Rotation_H) / 2;
//        self.navigationController.navigationBar.frame = CGRectMake(navBar_Rotation_X, navBar_Rotation_Y, navBar_Rotation_W, navBar_Rotation_H);  // *_* title?
//        self.navigationController.navigationBar.transform = CGAffineTransformMakeRotation(M_PI*0.5);  // 绕着中点(center)旋转
//        NSLog(@"navigationBar旋转后 (%f, %f, %f, %f)", self.navigationController.navigationBar.frame.origin.x, self.navigationController.navigationBar.frame.origin.y, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
////        CGFloat navBar_W = kNAVIGATIONG_HEIGHT;
////        CGFloat navBar_H = self.navigationController.navigationBar.frame.size.height;  // *_*
////        CGFloat navBar_X = kSCREEN_WIDTH - navBar_W;
////        CGFloat navBar_Y = 0;
////        self.navigationController.navigationBar.frame = CGRectMake(navBar_X , navBar_Y, navBar_W, navBar_H);
//
//        self.view.transform = CGAffineTransformMakeRotation(M_PI*0.5);
//    }];
    
    
    // 横屏之后布局 长和宽对调其他不变
    self.view.backgroundColor = [UIColor greenColor];
    _signatureView = [[PJRSignatureView alloc] initWithFrame:CGRectMake(20, 5, kSCREEN_HEIGHT - 40, 230)];
    [self.view addSubview:_signatureView];
    
    UIButton *btn = [KUtils createButtonWithFrame:CGRectMake(20, CGRectGetMaxY(_signatureView.frame) + 10, 100, 30) title:@"生成图片" titleColor:[UIColor blueColor] target:self tag:100];
    UIButton *btn1 = [KUtils createButtonWithFrame:CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), 100, 30) title:@"清屏" titleColor:[UIColor blueColor] target:self tag:101];
    UIButton *btn2 = [KUtils createButtonWithFrame:CGRectMake(CGRectGetMaxX(btn1.frame), CGRectGetMinY(btn1.frame), 100, 30) title:@"系统弹框" titleColor:[UIColor blueColor] target:self tag:102];
    UIButton *btn3 = [KUtils createButtonWithFrame:CGRectMake(CGRectGetMaxX(btn2.frame), CGRectGetMinY(btn2.frame), 100, 30) title:@"自定义弹框" titleColor:[UIColor blueColor] target:self tag:103];
    [self.view addSubview:btn];
    [self.view addSubview:btn1];
    [self.view addSubview:btn2];
    [self.view addSubview:btn3];
}


- (void)buttonAction:(UIButton *)btn
{
    if (btn.tag == 100)
    {
        UIImage *img = [_signatureView getSignatureImage];
        
        NSUInteger preIndex = self.navigationController.viewControllers.count - 2;
        SettingViewController *settingVC = (SettingViewController *)[self.navigationController.viewControllers objectAtIndex:preIndex];
        settingVC.imgTest = img;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (btn.tag == 101)
    {
        [_signatureView clearSignature];
    }
    else if (btn.tag == 102)
    {
        // 基于window 还是竖屏
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"UIAlertView" message:@"window" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alertView show];
    }
    else if (btn.tag == 103)
    {
        // 基于view 横屏
        DialogView1 *dialogView1 = [[DialogView1 alloc] initWithBgFrame:CGRectMake(0, 0, kSCREEN_HEIGHT, kSCREEN_WIDTH) andContainerSize:CGSizeMake(300, 200)];
        dialogView1.onBtnsTouchUpInside = ^(DialogView1 *currentDialogView, int buttonIndex) {
            if (buttonIndex == 1)
            {
                [currentDialogView removeFromSuperview];
                NSLog(@"block yes");
            }
        };
        //[[UIApplication sharedApplication].keyWindow addSubview:dialogView1];
        [self.view addSubview:dialogView1];
    }
}

@end
