//
//  PlayerTestVC.h
//  lcAhwTest
//
//  Created by licheng on 16/5/6.
//  Copyright © 2016年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerTestVC : UIViewController

+ (instancetype)defaultPlayer;

- (void)play:(UIViewController *)targetVC;
- (void)playInWebView:(UIViewController *)targetVC;

@end
