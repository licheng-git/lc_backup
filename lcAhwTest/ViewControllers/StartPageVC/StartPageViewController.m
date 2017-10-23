//
//  StartPageViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/10.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "StartPageViewController.h"
#import "KUtils.h"
#import "Constants.h"
#import "LoginViewController.h"

typedef NS_ENUM(NSInteger, StartPageVCBtnTag)
{
    StartBtn_tag = 10,
    LoginBtn_tag,
    RegisterBtn_tag
};

@interface StartPageViewController ()<UIScrollViewDelegate>
{
    UIButton *_startBtn; //立即体验
    UIButton *_loginBtn; //登录
    UIButton *_registerBtn; //注册
}
@property (strong, nonatomic) UIScrollView *scrollV;
@property (strong, nonatomic) UIPageControl *pageC;
@end

@implementation StartPageViewController
//@synthesize scrollV = _scrollV;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"启动页";
    self.view.backgroundColor = [UIColor greenColor];
    [self initScrollViewAndPageControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.navigationController.navigationBarHidden = YES;
    
    // 网络状态提醒
    if ([SettingManager shareInstance].bIsNetBreak)
    {
        [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
}

- (void)initScrollViewAndPageControl
{
    // scrollView
    CGRect scrollViewRect = CGRectMake(0.0, 0.0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
    self.scrollV = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    self.scrollV.pagingEnabled = YES;
    self.scrollV.showsHorizontalScrollIndicator = NO;
    self.scrollV.showsVerticalScrollIndicator = NO;
    self.scrollV.delegate = self;
    self.scrollV.clipsToBounds = YES;
    [self.view addSubview:self.scrollV];
    
    // 添加滑动图片
    [self addImagesOnScrollView];
    
    // button 浏览、登录、注册
    CGFloat btnW = 137.5;
    CGFloat btnH = 40.0;
    CGFloat startBtnX = CGRectGetMidX([UIScreen mainScreen].bounds) - btnW/2;
    CGFloat startBtnY = kSCREEN_HEIGHT - 130.0;
    if (!_startBtn)
    {
        CGRect rect = CGRectMake(startBtnX, startBtnY, btnW, btnH);
        
        _startBtn = [KUtils createButtonWithFrame:rect
                                            title:@"立即体验"
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                              tag:StartBtn_tag];
        _startBtn.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_startBtn];
    }
    if (!_loginBtn)
    {
        CGFloat loginBtnX = CGRectGetMinX(_startBtn.frame) - btnW/2 - 20.0;
        CGFloat loginBtnY = CGRectGetMaxY(_startBtn.frame) + 30.0;
        CGRect rect = CGRectMake(loginBtnX, loginBtnY, btnW, btnH);
        _loginBtn = [KUtils createButtonWithFrame:rect
                                            title:@"登录"
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                              tag:LoginBtn_tag];
        _loginBtn.backgroundColor = [UIColor clearColor];
        _loginBtn.layer.borderWidth = 2.0;
        _loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _loginBtn.layer.cornerRadius = 3.0;
        [self.view addSubview:_loginBtn];
    }
    if (!_registerBtn)
    {
        CGFloat registerBtnX = CGRectGetMaxX(_startBtn.frame) - btnW/2 + 20.0;
        CGFloat registerBtnY = CGRectGetMaxY(_startBtn.frame) + 30.0;
        CGRect rect = CGRectMake(registerBtnX, registerBtnY, btnW, btnH);
        _registerBtn = [KUtils createButtonWithFrame:rect
                                               title:@"注册"
                                          titleColor:[UIColor whiteColor]
                                              target:self
                                                 tag:RegisterBtn_tag];
        _registerBtn.backgroundColor = [UIColor clearColor];
        _registerBtn.layer.borderWidth = 2.0;
        _registerBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _registerBtn.layer.cornerRadius = 3.0;
        [self.view addSubview:_registerBtn];
    }
    
    // pageControl 滑动圆点
    self.pageC = [[UIPageControl alloc] init];
    self.pageC.frame = CGRectMake(0.0, CGRectGetMaxY(_startBtn.frame), kSCREEN_WIDTH, 10.0);
    self.pageC.numberOfPages = 3;
    self.pageC.currentPage = 0;
    self.pageC.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.pageC];
}

// scrollView 添加图片
- (void)addImagesOnScrollView
{
    for (UIView *view in self.scrollV.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSArray *imgArr = nil;
    if ([KUtils isIPhone4])
    {
        imgArr = @[@"4s_guide_1", @"4s_guide_2", @"4s_guide_3"];
    }
    else if ([KUtils isIPhone5])
    {
        imgArr = @[@"5s_guide_1", @"5s_guide_2", @"5s_guide_3"];
    }
    
    CGFloat imgW = CGRectGetWidth(self.scrollV.frame);
    CGFloat imgH = CGRectGetHeight(self.scrollV.frame);
    self.scrollV.contentSize = CGSizeMake(imgW*imgArr.count, 0.0);
    
    for (NSInteger i=0; i<imgArr.count; i++)
    {
        CGRect rect = CGRectMake(imgW*i, 0.0, imgW, imgH);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:rect];
        imgView.image = [UIImage imageNamed:[imgArr objectAtIndex:i]];
        [self.scrollV addSubview:imgView];
    }
}


// UIScrollViewDelegate
// 滑动时
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // 每页宽度
    CGFloat pageWith = sender.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    NSInteger page = floor((sender.contentOffset.x - pageWith/2) / pageWith) + 1;
    self.pageC.currentPage = page;
}
// 滑动停止
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
//{
//}


// 浏览、登录、注册 点击
-(void)buttonAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag)
    {
        case StartBtn_tag:
        {
            //启动页 push方式，不用present方式
//            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case LoginBtn_tag:
        {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            [self.navigationController pushViewController:loginVC animated:YES];
            break;
        }
        case RegisterBtn_tag:
        {
            break;
        }
        default:
            break;
    }
}

@end
