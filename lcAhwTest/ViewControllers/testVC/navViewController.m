//
//  navViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/10/29.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "navViewController.h"

@interface navViewController()
{
    UIToolbar *_toolbar;
    UIView *_navCenterView;
}
@end

@implementation navViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_toolbar)
    //if (!_navCenterView)
    {
        [self createNav];
    }
    else
    {
        _toolbar.hidden = NO;
        //_navCenterView.hidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _toolbar.hidden = YES;
    //_navCenterView.hidden = YES;
}


- (void)createNav
{
    //self.title = @"nav测试";
    self.navigationItem.title = @"nav测试";
    
    
//    [UINavigationBar appearance].barTintColor = [UIColor orangeColor];
//    [UINavigationBar appearance].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor greenColor] };
    
    
    UIImage *imgNavRight = [UIImage imageNamed:@"note_left_menu_setting"];
//    //self.navRightBarItemView.barImgView.image = imgNavRight;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgNavRight style:UIBarButtonItemStyleDone target:self action:nil];  // 系统蓝色
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];  // 改变颜色
    // 图片本身颜色
    //UIButton *btnNavRight = [UIButton buttonWithType:UIButtonTypeCustom];
    //btnNavRight.frame = CGRectMake(0, 0, imgNavRight.size.width, imgNavRight.size.height);
    //[btnNavRight setImage:imgNavRight forState:UIControlStateNormal];
    //[btnNavRight addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    //UIBarButtonItem *barBtnItem_NavRight = [[UIBarButtonItem alloc] initWithCustomView:btnNavRight];
    //self.navigationItem.rightBarButtonItem = barBtnItem_NavRight;
    imgNavRight = [imgNavRight imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];  // 原始图，不使用渲染图
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgNavRight style:UIBarButtonItemStyleDone target:self action:nil];
    //self.navigationItem.rightBarButtonItem.image = [self.navigationItem.rightBarButtonItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    // UIToolbar
    CGFloat toolbar_W = 120;
    CGFloat toolbar_H = 30;
    CGFloat toolbar_X = (kSCREEN_WIDTH - toolbar_W) / 2;
    //CGFloat toolbar_Y = (kNAVIGATION_HEIGHT - toolbar_H) / 2 + kSTATUSBAR_HEIGHT;
    CGFloat toolbar_Y = kDEFAULT_ORIGIN_Y - 5;
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(toolbar_X, toolbar_Y, toolbar_W, toolbar_H)];

    UIBarButtonItem *barBtnItem0 = [[UIBarButtonItem alloc] initWithTitle:@"测试0" style:UIBarButtonItemStylePlain target:self action:@selector(navBtnClick:)];
    barBtnItem0.tag = 100;
    UIBarButtonItem *barBtnItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(navBtnClick:)];
    barBtnItem1.tag = 101;
    UIBarButtonItem *barBtnItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"loading.gif"] style:UIBarButtonItemStyleDone target:self action:@selector(navBtnClick:)];
    barBtnItem2.tag = 102;

    _toolbar.items = @[barBtnItem0, barBtnItem1, barBtnItem2];
    _toolbar.backgroundColor = [UIColor redColor];
    //[self.view addSubview:_toolbar];
    [self.navigationController.view addSubview:_toolbar];


//    // UISegmentedControl 默认蓝＋白，非默认的很难看且没法调好，使用RFSegmentView
    
    
//    // 自定义
//    int btnsNum = 2;
//    CGFloat btnW = 60;
//    CGFloat btnH = 30;
//    CGFloat navCenterView_X = (kSCREEN_WIDTH - btnW * btnsNum) / 2;
//    //CGFloat navCenterView_Y = (kNAVIGATION_HEIGHT - btnH) / 2 + kSTATUSBAR_HEIGHT;
//    CGFloat navCenterView_Y = kDEFAULT_ORIGIN_Y - 5;
//    _navCenterView = [[UIView alloc] initWithFrame:CGRectMake(navCenterView_X, navCenterView_Y, btnW*btnsNum, btnH)];
//    UIButton *btn0 = [KUtils createButtonWithFrame:CGRectMake(0, 0, btnW, btnH) title:@"测试0" titleColor:[UIColor blueColor] target:self tag:100];
//    UIButton *btn1 = [KUtils createButtonWithFrame:CGRectMake(btnW, 0, btnW, btnH) title:@"测试1" titleColor:[UIColor blueColor] target:self tag:101];
//    _navCenterView.backgroundColor = [UIColor redColor];
//    _navCenterView.layer.borderColor = [UIColor blueColor].CGColor;
//    _navCenterView.layer.borderWidth = 1;
//    _navCenterView.layer.cornerRadius = 5;
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(btn1.frame), 0, 1, btnH)];
//    line.backgroundColor = [UIColor colorWithCGColor:_navCenterView.layer.borderColor];
//    [_navCenterView addSubview:btn0];
//    [_navCenterView addSubview:btn1];
//    [_navCenterView addSubview:line];
////    [self.view addSubview:_navCenterView];
//    [self.navigationController.view addSubview:_navCenterView];
}


- (void)navBtnClick:(id)sender
{
    UIBarButtonItem *barBtnItem = (UIBarButtonItem *)sender;
    if (barBtnItem.tag == 100)
    {
        NSLog(@"toolbar.item 测试0");
    }
    else if (barBtnItem.tag == 101)
    {
        NSLog(@"toolbar.item 测试1");
    }
    else if (barBtnItem.tag == 102)
    {
        NSLog(@"toolbar.item 测试2");
    }
    else if (barBtnItem.tag == 200)
    {
        NSLog(@"navItem.left");
    }
    else if (barBtnItem.tag == 201)
    {
        NSLog(@"navItem.right");
    }
}


- (void)buttonAction:(UIButton *)btn
{
}


@end
