//
//  BaseViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/10.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()
{
    UIScrollView  *_selfScrollView;  // 注册键盘监听事件后 键盘出现消失 改动contentInset
}
@end


@implementation BaseViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.showAnima = YES;
        self.bIsNeedTapGesture = NO;
        self.bIsNeedKeyboardNotifications = NO;
    }
    return self;
}

//- (void)loadView
//{
//    [super loadView];
//    if (self.bIsNeedKeyboardNotifications)
//    {
//        [self createSelfScrollView];  // *_* 放这里才能触发UIGestureRecognizerDelegate
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 注册 键盘监听事件
    if (self.bIsNeedKeyboardNotifications)
    {
        [self createSelfScrollView];  // *_* 需要放在createView最前面
        [self registerNotificationsForKeyboard];
    }
    
    if ([KUtils isIOS7])
    {
        self.automaticallyAdjustsScrollViewInsets = NO;  // 不要自个在顶部留一个的高度
    }
    self.view.backgroundColor = kBACKGROUND_COLOR;
    
    // 创建导航左右按钮
    [self createNavBarItem];
    
    // 添加手势 （单击 隐藏键盘）
    if (self.bIsNeedTapGesture)
    {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        singleTap.delegate = self;
        singleTap.numberOfTapsRequired = 1;  // 单击
        [self.view addGestureRecognizer:singleTap];
    }
    
    // UITapGestureRecognizer        // 点击
    // UIPinchGestureRecognizer      // 捏合
    // UIRotationGestureRecognizer   // 旋转
    // UISwipeGestureRecognizer      // 快速滑动、横扫竖扫
    // UIPanGestureRecognizer        // 慢速拖动
    // UILongPressGestureRecognizer  // 长按
    
    
//    // 注册 键盘监听事件
//    if (self.bIsNeedKeyboardNotifications)
//    {
//        [self registerNotificationsForKeyboard];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 当前页面被覆盖时，关闭当前页面旋转菊花
    [self stopAnima:nil];
}

- (void)dealloc
{
    // 注销 键盘监听事件
    if (self.bIsNeedKeyboardNotifications)
    {
        [self unregisterNotificationsForKeyboard];
    }
    
    // 当前页面被覆盖时，取消该页面所有请求
    [self cancelRequest];
}


#pragma mark - NavBarItemView Create + Delegate

// 创建导航左右按钮
- (void)createNavBarItem
{
    if (self.navLeftBarItemView)
    {
        return;
    }
    CGRect rect = CGRectMake(0.0, 0.0, NAVBAR_W, NAVBAR_H);
    self.navLeftBarItemView = [[NavBarItemView alloc] initWithFrame:rect navBarType:LeftBarType delegate:self];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navLeftBarItemView];
    self.navLeftBarItemView.barImgView.image = [UIImage imageNamed:@"nav_btn_back"];
    
    // 添加一个默认的手势回退 （ios7以上自带的手势回退，需在边上滑触发）
    if ([KUtils isIOS7])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;  // *_*
    }
    
    if (self.navRightBarItemView)
    {
        return;
    }
    self.navRightBarItemView = [[NavBarItemView alloc] initWithFrame:rect navBarType:RightBarType delegate:self];
    self.navRightBarItemView.barImgView.image = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navRightBarItemView];
}

// NavBarItemViewDelegate 导航左按钮默认为返回
- (void)clickNavBarItemView:(NavBarItemView *)navBarItemView navBarType:(NavBarType)type
{
    if (type == LeftBarType)
    {
        // 返回时取消该页面所有请求
        [self cancelRequest];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.activeTextField = nil;
    return YES;
}

// 控制输入类型及长度
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}


#pragma mark - UIGestureRecognizer Delegate + SelectorResponseMethod

// 是否触发
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIControl class]])
    {
        return NO;
    }
    else if ([touch.view isKindOfClass:[UIImageView class]])
    {
        return NO;
    }
    return YES;
    
    //isKindOfClass   当前类或其子类
    //isMemberOfClass 仅当前类
}

// 单点触摸手势响应函数 （点击屏幕隐藏键盘）
- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    if (self.activeTextField && [self.activeTextField isFirstResponder])
    {
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
    }
}


#pragma mark - Keyboard Notification

// 创建滚动视图 用于注册键盘监听事件后 键盘出现消失 改动frame
- (void)createSelfScrollView
{
    _selfScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _selfScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
//    if ([KUtils isIPhone4or4s])
//    {
//        _selfScrollView.contentSize = CGSizeMake(...)
//    }
    self.view = _selfScrollView;
}

// 注册 监听键盘事件
- (void)registerNotificationsForKeyboard
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

// 注销 监听键盘事件
- (void)unregisterNotificationsForKeyboard
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//// 键盘位置改变  遮住部分往上滚  *_* UITextField ok；对UITextView不适用（继承UIScrollView）
//- (void)keyboardDidChangeFrame:(NSNotification *)aNotification
//{
//    NSDictionary *info = [aNotification userInfo];
//    CGRect keyboardEndFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat keyboardEndHeight = kSCREEN_HEIGHT - keyboardEndFrame.origin.y;
//    if (keyboardEndHeight <= 0.0)  // 0表示收起
//    {
//        _selfScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);  // UI效果没有UIKeyboardWillHideNotification好
//        return;
//    }
//    else  // >0表示弹出
//    {
//        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardEndFrame.size.height, 0.0); // 上、左、下、右
//        _selfScrollView.contentInset = contentInsets;
//        //_selfScrollView.scrollIndicatorInsets = contentInsets;
//        
////        // 第一次弹出对textView也起作用，但切换输入法时有问题  *_*
////        [UIView animateWithDuration:0.3 animations:^{
////            _selfScrollView.contentOffset= CGPointMake(_selfScrollView.contentOffset.x, _selfScrollView.contentOffset.y + keyboardEndFrame.size.height);
////        }];
//    }
//}

// 键盘出现  遮住部分往上滚  *_* 对textView不适用
- (void)keyboardDidShow:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGRect keyboardEndFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardEndFrame.size.height, 0.0); // 上、左、下、右
    _selfScrollView.contentInset = contentInsets;
    //_selfScrollView.scrollIndicatorInsets = contentInsets;
}

// 键盘消失  被遮住部分再滚回去
- (void)keyboardWillHidden:(NSNotification *)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    _selfScrollView.contentInset = contentInsets;
    //_selfScrollView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - Selector Response Method

- (void)buttonAction:(UIButton *)btn
{
}


#pragma mark - Custom Methods

// 协议请求
- (void)requestWithData:(BaseData *)basedata
                success:(SuccessBlock)success
                 failed:(FailedBlock)failed
{
    
    // 检查网络是否可用
//    if (![KUtils isConnectionAvailable])
//    {
//        failure ? failure(@"网络异常，请检查网络连接") : nil;
//        return;
//    }
    if ([SettingManager shareInstance].bIsNetBreak)
    {
        [SVProgressHUD showErrorWithStatus:@"网络异常，请检查网络连接"];
        [self endRefresh];
        return;
    }
    
    // 菊花旋转动画
    if (self.showAnima)
    {
        [self startAnima:nil];
    }
    else
    {
        [self stopAnima:nil];
    }
    
    if (basedata)
    {
        //self.basedata = basedata;
        [RequestHandler startRequestWithData:basedata
                                    delegate:self
                                     success:^(id responseData){
                                         
                                         // 菊花停止旋转
                                         [self stopAnima:nil];
                                         
                                         // 结束刷新 上拉和下拉
                                         [self endRefresh];
                                         
                                         // 成功回调函数
                                         success ? success(responseData) : nil;
                                         
                                     }
                                      failed:^(id error){
                                          [self stopAnima:(NSString *)error];
                                          [self endRefresh];
                                          failed ? failed(error) : nil;
                                      }];
    }
}

// 取消当前页面全部请求
- (void)cancelRequest
{
    [self stopAnima:nil];
    [RequestHandler cancelRequest:self];
}

// 请求 菊花 加载中...
- (void)startAnima:(NSString *)msg
{
    self.bIsShowingActivity = YES; // 正在旋转
    //[SVProgressHUD showWithStatus:msg maskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD showWithStatus:msg maskType:SVProgressHUDMaskTypeNavigation];
}

// 请求 菊花 消失
- (void)stopAnima:(NSString *)msg
{
    // 正在旋转时才停止。避免当前页面被释放时 调用cancelRequest 取消了其他页面的旋转菊花
    if (self.bIsShowingActivity)
    {
        self.bIsShowingActivity = NO; // 停止旋转
        if (msg)
        {
            [SVProgressHUD dismissWithError:msg];
        }
        else
        {
            [SVProgressHUD dismiss];
        }
    }
}

// 结束刷新 上拉和下拉 （继承类BaseTableViewController去实现，self没有tableView）
- (void)endRefresh
{
}

@end
