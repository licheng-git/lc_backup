//
//  aVC.h
//  lcAhwTest
//
//  Created by licheng on 15/6/30.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BaseTableViewController.h"
#import "KUtils.h"

/*
@protocol SlideViewControllerDelegate <NSObject>

// 点击 打开/还原
@optional
- (void)changeSlideView;

// 回退
@optional
- (void)navPopView;

@end
*/

@interface aVC : UIViewController
/*
// _mainVC的nav要随着一起滑动，所以nav上的事件需委托slideVC
@property (nonatomic, assign) id<SlideViewControllerDelegate> delegate;
*/
@end
