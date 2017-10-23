//
//  AppDelegate.h
//  lcAhwTest
//
//  Created by licheng on 15/4/8.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *homeNav;
@property (strong, nonatomic) HomeTabBarController *homeVC;

@end

