//
//  GesturePasswordView.h
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//

@protocol GesturePasswordDelegate <NSObject>

- (void)forget;
- (void)change;

@end

#import <UIKit/UIKit.h>
#import "TentacleView.h"
#import "showGesturePasswordView.h"

@interface GesturePasswordView : UIView<TouchBeginDelegate>

@property (nonatomic,strong) TentacleView * tentacleView;

@property (nonatomic,strong) UILabel * name;   // 账号名
@property (nonatomic,strong) UILabel * state;  // 提示状态

@property (nonatomic,assign) id<GesturePasswordDelegate> gesturePasswordDelegate;

@property (nonatomic,strong) UIImageView * imgView;
@property (nonatomic,strong) UIButton * forgetButton;
@property (nonatomic,strong) UIButton * changeButton;
@property (nonatomic,assign) BOOL       isResetPwd;
@property (nonatomic,strong) showGesturePasswordView *showGesturePwdView;

// 初始化
- (id)initWithFrame:(CGRect)frame isResetPwd:(BOOL)isResetPwd;

@end
