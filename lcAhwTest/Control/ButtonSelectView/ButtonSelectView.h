//
//  ButtonSelectView.h
//  lcAhwTest
//
//  Created by licheng on 15/5/5.
//  Copyright (c) 2015年 lc. All rights reserved.
//



/* 
顶部选择器 + 滑动视图
*/

#import <UIKit/UIKit.h>

#define SelectControlBtnsHeight (89.0/2)

@protocol ButtonSelectViewDelegate <NSObject>

@optional
- (void)selectChangeAt:(id)sender index:(NSInteger)index;

@end


@interface ButtonSelectView : UIView<UIScrollViewDelegate>

@property (nonatomic, assign) id<ButtonSelectViewDelegate> delegate;
@property (nonatomic, strong) NSArray *svSubviews;
@property (nonatomic, strong) NSArray *btnsTitles;

// 初始化视图
- (id)initWithFrame:(CGRect)frame
       btnsTitleArr:(NSArray *)btnsTitles
 scrollViewSubviews:(NSArray *)svSubviews;

// 定位
- (void)selectAtIndex:(NSInteger)index;

@end
