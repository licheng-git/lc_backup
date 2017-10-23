//
//  SlideViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/6/29.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "SlideViewController.h"

#define kSideScale      0.6                      // 滑出视图缩放比例
#define kMainScale      0.8                      // 当前视图缩放比例
#define kMainRemain     kSCREEN_WIDTH * 0.2      // 打开右侧视图时当前视图露出的宽度
#define kSlideDuration  0.5                      // 滑动持续时长（控制滑动速度）
#define kCoverAlpha     0.4                      // 遮罩层透明度系数

@interface SlideViewController ()
{
    UIViewController  *_mainVC;           // 当前视图
    UIViewController  *_sideVC;           // 从右侧滑出来的视图
//    SlideFromType     _slideFrom;         // 视图滑出方向
    UIView            *_mainCoverView;    // 遮罩层
    BOOL              _isSlided;          // 当前状态 是否已经打开侧视图
}
@end

@implementation SlideViewController

- (instancetype)initWithMainVC:(UIViewController *)mainVC sideVC:(UIViewController *)sideVC direction:(SlideFromType)slideFrom
{
    self = [super init];
    if (self)
    {
        // 背景图
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageview.image = [UIImage imageNamed:@"bg_img2.png"];
        [self.view addSubview:imageview];
        
        _mainVC = mainVC;
        _sideVC = sideVC;
        [self.view addSubview:_mainVC.view];
        [self.view addSubview:_sideVC.view];
        _isSlided = NO;
        
        // 设置右侧视图初始位置
        _sideVC.view.frame = CGRectMake(kSCREEN_WIDTH, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
        // 设置右侧视图缩放系数
        _sideVC.view.transform = CGAffineTransformMakeScale(kSideScale, kSideScale);
        
        // 滑动手势
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        panGesture.delegate = self;
        [_mainVC.view addGestureRecognizer:panGesture];
        
        // 遮罩层
        _mainCoverView = [[UIView alloc] init];
        _mainCoverView.frame = _mainVC.view.frame;
        _mainCoverView.backgroundColor = [UIColor blackColor];
        _mainCoverView.alpha = 0;  // 透明度 （0 透明 此时遮罩层无效，即_mainVC.view上的控件可用，_mainCoverView的手势不可用；0<alpha<=1 不透明 此时遮罩层起作用）
        [_mainVC.view addSubview:_mainCoverView];
        
        // 遮罩层添加单击手势，使_mainVC缩小时单击还原
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSideView)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.delegate = self;
        [_mainCoverView addGestureRecognizer:tapGesture];
        
        // 给_mainVC做一个假的navC
//        [self createFakeNav];
        
        // 默认_mainVC左导航按钮可以回退
        self.isNeedPopBack = YES;
    }
    
    return self;
}

// 显示_mainVC.navC，而非self.navC （self.navC 无法和_mainVC一起缩放）
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    //_mainVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"#_#" style:UIBarButtonItemStylePlain target:self action:@selector(changeSlideView)];
    self.mainNavItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"#_#" style:UIBarButtonItemStylePlain target:self action:@selector(changeSlideView)];  // viewDidAppear
    
    // 回退  _mainVC.navC 里面只有_mainVC一个，所以需要在slideVC里 self.navC.popView()
    if (self.isNeedPopBack)
    {
        self.mainNavItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_btn_back"] style:UIBarButtonItemStylePlain target:self action:@selector(navPopView)];
    }
}


//// 给_mainVC做一个假的navC
//- (void)createFakeNav
//{
//    UIView *fakeNav = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSTATUSBAR_HEIGHT + kNAVIGATION_HEIGHT)];
//    fakeNav.backgroundColor = kNAV_BG_COLOR;
//    [_mainVC.view addSubview:fakeNav];
//    // 回退按钮
//    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnLeft.frame = CGRectMake(0, kSTATUSBAR_HEIGHT + 5, 30, 30);
//    [btnLeft addTarget:self action:@selector(navPopView) forControlEvents:UIControlEventTouchUpInside];
//    [btnLeft setImage:[UIImage imageNamed:@"nav_btn_back"] forState:UIControlStateNormal];
//    btnLeft.backgroundColor = [UIColor clearColor];
//    [fakeNav addSubview:btnLeft];
//    // 弹出/还原 按钮
//    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnRight.frame = CGRectMake(kSCREEN_WIDTH - 50, kSTATUSBAR_HEIGHT + 5, 30, 30);
//    [btnRight addTarget:self action:@selector(changeSlideView) forControlEvents:UIControlEventTouchUpInside];
//    [btnRight setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
//    btnRight.backgroundColor = [UIColor clearColor];
//    [fakeNav addSubview:btnRight];
//    // 标题
//    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake( (kSCREEN_WIDTH - 100) / 2, kSTATUSBAR_HEIGHT, 100, kNAVIGATION_HEIGHT)];
//    lb.text = @"FakeNavC";
//    lb.textColor = [UIColor purpleColor];
//    lb.textAlignment = NSTextAlignmentCenter;
//    [fakeNav addSubview:lb];
//}


// 回退
- (void)navPopView
{
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;  // 必需，否则在调用slideVC的vc里viewWillAppear里写，封装性不好
}


// 点击 打开/关闭
- (void)changeSlideView
{
    if (!_isSlided)
    {
        [self openSideView];  // 打开
    }
    else
    {
        [self closeSideView];  // 关闭
    }
}

// 打开 动画效果
- (void)openSideView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kSlideDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    _mainVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, kMainScale, kMainScale);  // 缩放比例
    _mainVC.view.center = CGPointMake( -(kSCREEN_WIDTH * kMainScale / 2) + kMainRemain , kSCREEN_HEIGHT / 2);  // 中心点位置
    _mainCoverView.alpha = kCoverAlpha;  // 0.5阴影，遮罩层起作用
    
    _sideVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    _sideVC.view.center = CGPointMake(kSCREEN_WIDTH / 2 + kMainRemain, kSCREEN_HEIGHT / 2);
    _isSlided = YES;
    
    [UIView commitAnimations];
}

// 关闭 动画效果
- (void)closeSideView
{
    [UIView animateWithDuration:kSlideDuration
                     animations:^{
                         _mainVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                         _mainVC.view.center = CGPointMake( kSCREEN_WIDTH / 2 , kSCREEN_HEIGHT / 2);
                         _mainCoverView.alpha = 0;  // 透明，遮罩层不起作用
                         _sideVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, kSideScale, kSideScale);
                         _sideVC.view.center = CGPointMake(kSCREEN_WIDTH * 1.5, kSCREEN_HEIGHT * 0.5);
                     }
                     completion:^(BOOL finish){
                         _isSlided = NO;
                     }];
}


// 滑动 打开/关闭 动画效果
- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    CGPoint panLocation = [pan locationInView:self.view];        // 手势的位置（绝对坐标）
    CGPoint panTranslation = [pan translationInView:self.view];  // 手势的移动距离（相对坐标）
//    if (panTranslation.x < 0)
//    {
//        // 向左滑
//    }
//    else
//    {
//        // 向右滑
//    }
    
    // 边界控制
    BOOL isNeedKeepMoving = YES;  // 是否需要继续滑动
    //CGFloat coordinateX = panLocation.x;
    // 坐标轴x为_mainVC.view右边框位置（pan在整个屏幕上触发，panLocation.x不能代表随滑动变化的坐标轴x位置）
    CGFloat coordinateX = _mainVC.view.frame.origin.x + _mainVC.view.frame.size.width;
    if ((coordinateX <= kMainRemain && panTranslation.x <= 0) || (coordinateX >= kSCREEN_WIDTH && panTranslation.x >= 0))
    {
        isNeedKeepMoving = NO;
    }
    
    if (isNeedKeepMoving)  // 正常滑动
    {
        // _mainVC滑动  （_mainVC.view == pan.view）
        CGFloat mainVC_CenterX = _mainVC.view.center.x + panTranslation.x;
        _mainVC.view.center = CGPointMake(mainVC_CenterX, _mainVC.view.center.y);
        
        // _mainVC滑动过程中的缩放比例 1~kMainScale 渐变
        CGFloat slideMainScale = (1 - kMainScale) * (coordinateX - kMainRemain) / (kSCREEN_WIDTH - kMainRemain) + kMainScale;  // 作图计算得出表达式先
        _mainVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, slideMainScale, slideMainScale);
        
        // 遮罩层透明度 0~kCoverAlpha 渐变
        CGFloat slideAlpha = (1 - kCoverAlpha) * (coordinateX - kMainRemain) / (kSCREEN_WIDTH - kMainRemain) + kCoverAlpha;
        _mainCoverView.alpha =  1 - slideAlpha;
        
        // _sideVC滑动
        CGFloat sideVC_CenterX = _sideVC.view.center.x + panTranslation.x;
        _sideVC.view.center = CGPointMake(sideVC_CenterX, _sideVC.view.center.y);
        
        // _sideVC活动过程中的缩放比例 kSideScale~1 渐变
        CGFloat slideSideScale = (1 - kSideScale) * (kSCREEN_WIDTH - coordinateX) / (kSCREEN_WIDTH - kMainRemain) + kSideScale;
        _sideVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, slideSideScale, slideSideScale);
        
        [pan setTranslation:CGPointZero inView:self.view];  // *_* 清空手势的移动距离
    }
//    else  // 超出范围 滑太快会有点偏差需修正一下位置
//    {
//        if (coordinateX < kMainRemain)
//        {
//            [self openSideView];
//        }
//        else if (coordinateX > kSCREEN_WIDTH)
//        {
//            [self closeSideView];
//        }
//    }
    
    // 手势结束后修正位置 （处理滑一半停下的情况，超过一半时向多出的一半偏移，用坐标判断）
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        CGFloat couldChangeStateX = kSCREEN_WIDTH / 2 + kMainRemain;
        if (coordinateX <= couldChangeStateX)
        {
            [self openSideView];
        }
        else
        {
            [self closeSideView];
        }
    }
    
}

@end
