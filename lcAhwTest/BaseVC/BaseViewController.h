//
//  BaseViewController.h
//  lcAhwTest
//
//  Created by licheng on 15/4/10.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseData.h"
#import "RequestHandler.h"
#import "KUtils.h"
#import "SVProgressHUD.h"
#import "NavBarItemView.h"
#import "WebViewController.h"

@interface BaseViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,NavBarItemViewDelegate,WebVC_Delegate>
{
    @public
    NSString *_pPublic;    // 访问方式 subVC->_pPublic
    NSString *_pPublic1;
    @protected
    NSString *_pProtected;
    @private
    NSString *_pPrivate;
}

@property (nonatomic, strong) BaseData *basedata;
@property (nonatomic, assign) BOOL showAnima;
@property (nonatomic, assign) BOOL bIsShowingActivity; // 是否正在请求（菊花旋转中）

@property (nonatomic, strong) UITextField *activeTextField;  // 当前使用的文本框

@property (nonatomic, assign) BOOL bIsNeedTapGesture;    // 是否需要添加手势事件
@property (nonatomic, assign) BOOL bIsNeedKeyboardNotifications; // 是否需要注册键盘监听事件

@property (nonatomic, strong) NavBarItemView *navLeftBarItemView;   // 左导航按钮
@property (nonatomic, strong) NavBarItemView *navRightBarItemView;  // 右导航按钮

// 协议请求
- (void)requestWithData:(BaseData *) basedata
                success:(SuccessBlock)success
                 failed:(FailedBlock)failed;


@end
