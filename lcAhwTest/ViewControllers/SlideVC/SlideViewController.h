//
//  SlideViewController.h
//  lcAhwTest
//
//  Created by licheng on 15/6/29.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, SlideFromType)
{
    SlideFromLeft,    // 视图从左边滑出来
    SlideFromRight    // 视图从右边滑出来
};

@interface SlideViewController : BaseViewController

- (instancetype)initWithMainVC:(UIViewController *)mainVC
                        sideVC:(UIViewController *)sideVC
                     direction:(SlideFromType)slideFrom;

@property (nonatomic, strong) UINavigationItem *mainNavItem;
@property (nonatomic, strong) UINavigationController *mainNavC;
@property (nonatomic, assign) BOOL isNeedPopBack;  // _mainVC的左导航按钮是否回退

@end


/*
 _mainVC.navC要随着一起滑动
 
 方法一： 在slideVC里  给_mainVC做一个假的navC  （UI效果 耗时 难维护）
 方法二： 在_mainVC里  _mainVC.navC点击事件 委托过来  _mainVC.delegate=slideVC  （代码多，封装差）
 方法三： 在调用slideVC的地方 slideVC.mainNavItem = _mainVC.navItem
*/
