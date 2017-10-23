//
//  NavBarItemView.h
//  lcAhwTest
//
//  Created by licheng on 15/4/24.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NAVBAR_W    80.0
#define NAVBAR_H    30.0

typedef NS_ENUM(NSInteger, NavBarType)
{
    LeftBarType,
    RightBarType
};

@protocol NavBarItemViewDelegate;


@interface NavBarItemView : UIView

@property (nonatomic, strong) UIButton *barBtn_bubble;
@property (nonatomic, strong) UIImageView *barImgView;
@property (nonatomic, strong) UILabel *barLabel;

@property (nonatomic, weak) id<NavBarItemViewDelegate> delegate; // *_* strong导致BaseViewController的dealloc不执行

// 创建
- (instancetype)initWithFrame:(CGRect)frame
                   navBarType:(NavBarType)type
                     delegate:(id)delegate;

// 设置气泡值
- (void)setBubbleTitle:(NSString *)title;

@end


@protocol NavBarItemViewDelegate <NSObject>

@optional
- (void)clickNavBarItemView:(NavBarItemView *)navBarItemView navBarType:(NavBarType)type;

@end
