//
//  ButtonScrollContainerVC.m
//  lcAhwTest
//
//  Created by licheng on 15/8/13.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "ButtonScrollContainerVC.h"
#import "ButtonSelectView.h"
#import "normalVC.h"
#import "tableVC.h"
#import "table1VC.h"

@interface ButtonScrollContainerVC ()<ButtonSelectViewDelegate>
{
    ButtonSelectView  *_selectControl;
    table1VC          *_vc1;
}
@end

@implementation ButtonScrollContainerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"ViewControllers";
    
    NSArray *titleArr = @[@"无", @"继承", @"包含"];
    
    normalVC *vc = [[normalVC alloc] init];
    tableVC *vc0 = [[tableVC alloc] init];
//    table1VC *vc1 = [[table1VC alloc] init];
//    NSArray *viewArr = @[vc.view, vc0.view, vc1.view];
    _vc1 = [[table1VC alloc] init];
    NSArray *viewArr = @[vc.view, vc0.view, _vc1.view];  
    
    CGRect rect = CGRectMake(0, kDEFAULT_ORIGIN_Y, kSCREEN_WIDTH, kSCREEN_HEIGHT - kDEFAULT_ORIGIN_Y - kBOTTOM_HEIGHT - 10);
    _selectControl = [[ButtonSelectView alloc] initWithFrame:rect btnsTitleArr:titleArr scrollViewSubviews:viewArr];
    _selectControl.delegate = self;
    [self.view addSubview:_selectControl];
    [_selectControl selectAtIndex:1];  // 定位，显示调用
    
    // 重新调整vc.view的origin（kDEFAULT_ORIGIN_Y的影响），使每个vc单独也能使用
    CGRect tempFrame = vc.view.frame;
    vc.view.frame = CGRectMake(tempFrame.origin.x, tempFrame.origin.y - kDEFAULT_ORIGIN_Y, tempFrame.size.width, tempFrame.size.height + kDEFAULT_ORIGIN_Y);
    
    vc.containerTabBarC = self.tabBarController;
    vc.navigationController.navigationBarHidden = YES;
    
}

// ButtonSelectViewDelegate
- (void)selectChangeAt:(id)sender index:(NSInteger)index
{
//    if (index == 0)
//    {}
//    else if (index == 1)
//    {}
//    ...
    
//    UIView *view = [_selectControl.svSubviews objectAtIndex:index];
//    if ([view isKindOfClass:[_vc1 class]])
//    {}
//    else ...
}

@end
