//
//  HomeTabBarController.h
//  lcAhwTest
//
//  Created by licheng on 15/4/8.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTabBarController : UITabBarController

+ (id)getInstance;

// 选择tabBar
- (void)selectTabBarAtIndex:(NSInteger)index withAnimated:(BOOL)animated;

// 处理消息推送窗口的新标提醒
- (void)handlePushOfNewBid:(NSString *)bidID;

@end
