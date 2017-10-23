//
//  HomeTabBarController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/8.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "HomeTabBarController.h"
#import "CustomTabBarView.h"
#import "MainPageController.h"
#import "InvestPageController.h"
#import "MyAccountPageController.h"
#import "StartPageViewController.h"
#import "LoginViewController.h"
#import "InvestDetailViewController.h"
#import "Reachability.h"

#import "ButtonScrollContainerVC.h"

@interface HomeTabBarController ()<CustomTabBarViewDelegate>
{
    CustomTabBarView *_cusTabBarView;
    BOOL             _bIsShowedStartPageVC;
    
    Reachability *_hostReach;
}
@end

@implementation HomeTabBarController


static HomeTabBarController *homeInstacnce = nil;

+ (id)getInstance
{
    @synchronized(self)  // 加独占锁（单例）
    {
        if(homeInstacnce == nil)
        {
            homeInstacnce = [[self alloc] init];
        }
    }
    return homeInstacnce;
}


- (instancetype)init
{
    if(self = [super init])
    {
        _bIsShowedStartPageVC = NO;
        
        MainPageController *mainVC = [[MainPageController alloc] init];
        UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:mainVC];
        
        InvestPageController *investVC = [[InvestPageController alloc] init];
        UINavigationController *investNav = [[UINavigationController alloc] initWithRootViewController:investVC];
//        ButtonScrollContainerVC *testVC = [[ButtonScrollContainerVC alloc] init];
//        UINavigationController *investNav = [[UINavigationController alloc] initWithRootViewController:testVC];
        
        MyAccountPageController *myAcctVC = [[MyAccountPageController alloc] init];
        UINavigationController *myAcctNav = [[UINavigationController alloc] initWithRootViewController:myAcctVC];
        
        //self.viewControllers = @[mainVC,investVC,myAcctVC];
        self.viewControllers = @[mainNav,investNav,myAcctNav];
        self.selectedIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 创建CustomTabBarView
    [self createView];
    
    // 创建数据库及相关表
    //[[DBOperator shareInstance] createTable];
    //[DBOperator sqlite3];
    
    // 网络监控
    [self initNetworkObserver];
    
    // 添加监听（UIApplicationDidEnterBackgroundNotification 手势密码）
}

// 创建CustomTabBarView
- (void)createView
{
    CGRect rect = {0.0, CGRectGetMinY(self.tabBar.frame), kSCREEN_WIDTH, CGRectGetHeight(self.tabBar.frame)};
    NSArray *tabTitles = @[@"首页", @"我要投资", @"我的账户"];
    _cusTabBarView = [[CustomTabBarView alloc] initWithFrame:rect titles:tabTitles delegate:self];
    [self.view addSubview:_cusTabBarView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // tabbar显示的时候 隐藏tabbar的导航条，显示的是mainNav,investNav,myAcctNav
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(!_bIsShowedStartPageVC)
    {
        StartPageViewController *startVC = [[StartPageViewController alloc] init];
        
        // present方式改为push方式
//        UINavigationController *startNav = [[UINavigationController alloc] initWithRootViewController:startVC];
//        [self.navigationController presentViewController:startNav animated:NO completion:nil];
        [self.navigationController pushViewController:startVC animated:NO];
        
        _bIsShowedStartPageVC = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // tabbar隐藏的时候 显示tabbar的导航条，否则push其他页面时导航条被隐藏拉
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

// CustomTabBarView Delegate （点击触发委托）
- (BOOL)clickAtCustomTabBar:(NSInteger)index
{
    // 非登陆状态下 点击 我的账户
    if (index == 2 && ![SettingManager shareInstance].bIsLogined)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"您还未登陆，是否登陆？"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"登陆",nil];
        [alertView show];
        return NO;
    }
    
    self.selectedIndex = index;
    return YES;
}

// UIAlertView 点击按钮
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // 取消
        [self selectTabBarAtIndex:self.selectedIndex withAnimated:NO];
    }
    else if (buttonIndex == 1)
    {
        // 登陆
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}


// 选择tabBar （代码调用触发）
- (void)selectTabBarAtIndex:(NSInteger)index withAnimated:(BOOL)animated
{
    if (animated)
    {
        // 动画效果
        [KUtils showView:self.view withAnimationType:kCATransitionReveal andSubtype:kCATransitionFromRight];
    }
    
    // 1.btn选中颜色
    // 2.[self setSelectedIndex:index];
    [_cusTabBarView setCurrentSelectedBtn:index];
}


// 处理消息推送窗口的新标提醒
- (void)handlePushOfNewBid:(NSString *)bidID
{
//    UIViewController *currentVC = nil;
//    //if ([[KUtils sysVersion] floatValue] >= 4.0)
//    {
//        UIViewController *rootVC = [[UIApplication sharedApplication] keyWindow].rootViewController;
//        if ([rootVC isKindOfClass:[UINavigationController class]])
//        {
//            currentVC = [(UINavigationController *)rootVC visibleViewController];
//        }
//    }
//    if (currentVC == nil)
//    {
//        currentVC = self.navigationController.topViewController;
//    }
    
//    // 当前是启动页 (从推送窗口启动程序)，则先跳转到首页，以便查看完标的详情后返回到首页而非返回到启动页
//    // 启动页 push方式，非present方式
//    //[self.navigationController dismissViewControllerAnimated:NO completion:nil];
//    UIViewController *currentVC = self.navigationController.topViewController;
//    if ([currentVC isKindOfClass:[StartPageViewController class]])
//    {
//        [self.navigationController popToRootViewControllerAnimated:NO];
//    }
    
    [SettingManager shareInstance].bidID = bidID;
    InvestDetailViewController *investDetailVC = [[InvestDetailViewController alloc] init];
    [self.navigationController pushViewController:investDetailVC animated:YES];
}


// 网络监控
- (void)initNetworkObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    // 网络状态监测
    _hostReach = [Reachability reachabilityForInternetConnection];
    [_hostReach startNotifier];
    [self updateInterfaceWithReachability];
}

// 网络连接改变
- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *currentReach = [notification object];
    if (currentReach == _hostReach)
    {
        [self updateInterfaceWithReachability];
    }
}

// 对网络连接改变做出响应的处理动作
- (void)updateInterfaceWithReachability
{
    NetworkStatus currentNetStatus = _hostReach.currentReachabilityStatus;
    if (currentNetStatus == NotReachable)
    {
        //[SVProgressHUD showErrorWithStatus:@"当前网络不可用"];  // 还没到弹出的时候
        [SettingManager shareInstance].bIsNetBreak = YES;
    }
    else
    {
        [SettingManager shareInstance].bIsNetBreak = NO;
    }
}

@end
