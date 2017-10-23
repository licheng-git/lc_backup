//
//  CustomTabBar.h
//  lcAhwTest
//
//  Created by licheng on 15/4/9.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BAR_BASETAG  10

typedef NS_ENUM(NSInteger, CustomTabBarViewBtnTag)
{
    HomePageBtn_tag = BAR_BASETAG,
    InvestBtn_tag,
    MyAccountBtn_tag
};


@protocol CustomTabBarViewDelegate <NSObject>

@optional
- (BOOL)clickAtCustomTabBar:(NSInteger)index;

@end


@interface CustomTabBarView : UIView

@property (nonatomic, weak) id<CustomTabBarViewDelegate> cDelegate;

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles delegate:(id)delegate;
-(void)setCurrentSelectedBtn:(NSInteger)index;

@end
