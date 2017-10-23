//
//  GesturePasswordController.m
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//

#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>
#import "GesturePasswordController.h"
#import "LoginViewController.h"

//#import "KeychainItemWrapper/KeychainItemWrapper.h"


#define GESTURE_PASSWORD        @"GesturePassword"

// 最大输入错误次数
#define MaxErrorCount           3

// 设置手势密码时，最少点数
#define MinEnterArginCount      4


@interface GesturePasswordController ()

@property (nonatomic,strong) GesturePasswordView * gesturePasswordView;
@property (nonatomic,strong) NSString * previousString;
@property (nonatomic,strong) NSString * password;

@end

@implementation GesturePasswordController {

}

@synthesize gesturePasswordView;


static GesturePasswordController *instance = nil;

+ (GesturePasswordController *)shareInstance
{
    @synchronized(self)
    {
        if (nil == instance)
        {
            instance = [[self alloc] init];
        }
        else
        {
//            [instance showGetPwdView]; // add by hhx 2015.03.11
        }
    }
    
    return instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _errorCount = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
//    password = [keychin safeObjectForKey:(__bridge id)kSecValueData];

    
//    [self showGetPwdView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarHidden = YES;
    self.navigationController.navigationBarHidden = YES;
    
    // add by hhx 2015.03.11
    [instance showGetPwdView];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 验证手势密码
- (void)verify{
//    NSLog(@"[UIScreen mainScreen].bounds:%@", NSStringFromCGRect([UIScreen mainScreen].bounds));
    
    if (gesturePasswordView == nil)
    {
        gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds isResetPwd:NO];
    }
    
    [gesturePasswordView.tentacleView setRerificationDelegate:self];
    [gesturePasswordView.tentacleView setStyle:1];
    [gesturePasswordView setGesturePasswordDelegate:self];
    
    // 显示用户名 add by hhx 2015.03.12
    [gesturePasswordView.forgetButton setHidden:NO];
    [gesturePasswordView.changeButton setHidden:NO];
    [gesturePasswordView.imgView setHidden:NO];
    [gesturePasswordView.showGesturePwdView setHidden:YES];
    [self showUserName];
    [gesturePasswordView.state setText:@""];
    
    [self.view addSubview:gesturePasswordView];
}

#pragma mark - 重置手势密码
- (void)reset{
//    NSLog(@"[UIScreen mainScreen].bounds:%@", NSStringFromCGRect([UIScreen mainScreen].bounds));

    if (gesturePasswordView == nil) {
        gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds isResetPwd:YES];
    }
    
    [gesturePasswordView.tentacleView setResetDelegate:self];
    [gesturePasswordView.tentacleView setStyle:2];
    if (gesturePasswordView.imgView) {
        [gesturePasswordView.imgView setHidden:YES];
    }
    
    [gesturePasswordView.forgetButton setHidden:YES];
    [gesturePasswordView.changeButton setHidden:YES];
    
    // 显示用户名 add by hhx 2015.03.12
    [gesturePasswordView.showGesturePwdView setHidden:NO];
    [self showUserName];
    [gesturePasswordView.state setText:@"请绘制您的手势密码"];
    
    [self.view addSubview:gesturePasswordView];
}

#pragma mark - 判断是否已存在手势密码
- (BOOL)exist{
//    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
//    password = [keychin safeObjectForKey:(__bridge id)kSecValueData];
    self.password = [self getGesturePassword];
    if (self.password == nil || [self.password isEqualToString:@""])
        return NO;
    
    return YES;
}

#pragma mark - 清空记录

// 清空手势密码和记录
- (void)clear {
//    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
//    [keychin resetKeychainItem];
    [self saveGesturePassword:nil];
    self.previousString = nil;
    self.errorCount = 0;
}

// 清空用户密码和手势密码
- (void)clearUserPwdAndGesturePwd
{
    [self clear];
    [KUtils saveUserPwd:nil];
}

#pragma mark - 改变手势密码 / 切换其他账号登录
- (void)change {
    
    // 选择登录，则要清空保存的登陆下发数据，账号密码 和 手势密码
    [[SettingManager shareInstance] clearLoginData];
    
    // 弹出登录界面
    [self createLoginVC:CHANGE_OTHER_ACCOUNT];
}

#pragma mark - 忘记手势密码
- (void)forget {
    [KUtils showAlertView:nil body:@"忘记手势密码，需要您重新登录" Yes:^(DoAlertView *alertView) {
        
        // 选择登录，则要清空保存的登陆下发数据，账号密码 和 手势密码
        [[SettingManager shareInstance] clearLoginData];
        
        // 弹出登录界面
        [self createLoginVC:FORGET_GESTUREPWD];
        
        
    } No:^(DoAlertView *alertView) {
        
    }];
}

- (BOOL)verification:(NSString *)result {
    
    if ([result isEqualToString:self.password]) {
        [gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
        [gesturePasswordView.state setText:@"输入正确"];
        
        // 只要验证正确，就初始为0，重新计数
        _errorCount = 0;
        
        // 释放手势密码前，显示提示框 add by hhx 2015.05.27
        if ([SettingManager shareInstance].currentDoAlertView)
        {
            [[SettingManager shareInstance].currentDoAlertView hideAlertViewForExternal:NO];
        }
        
        // 输入正确后  add by hhx 2015.03.11
        self.navigationController.navigationBarHidden = NO;

        // pop 改成 dismiss模态 modify by hhx 2015.05.27
        [self.navigationController popViewControllerAnimated:YES];
//        [self dismissViewControllerAnimated:YES completion:nil];
        
        
        if (_delegate && [_delegate respondsToSelector:@selector(verifyGesturePasswordSuccess)]) {
            [_delegate verifyGesturePasswordSuccess];
        }
        
        [self performSelector:@selector(refreshGesturePasswordView) withObject:self afterDelay:1.0];
        return YES;
    }
    
    // 输入错误计数
    _errorCount++;
    
    if (MaxErrorCount == _errorCount) {
        
        // 输入错误次数超过3次，则要清空保存的登陆下发数据，账号密码 和 手势密码
        [[SettingManager shareInstance] clearLoginData];
        
        // 输入错误超过3次，则弹出登陆界面
        NSString *msg = [NSString stringWithFormat:@"手势密码输入错误已超过%d次，请重新登录！", MaxErrorCount];
        [KUtils showAlertView:nil body:msg yesBtnTitle:@"重新登录" Yes:^(DoAlertView *alertView) {
            
            // 清空保存的登陆下发数据，账号密码 和 手势密码
            [[SettingManager shareInstance] clearLoginData];
            
            [self refreshGesturePasswordView];
            [self createLoginVC:FORGET_GESTUREPWD];
            
        }];

    }
    else
    {
        [gesturePasswordView.state setTextColor:[UIColor redColor]];
        [gesturePasswordView.state setText:[NSString stringWithFormat:@"手势密码错误，您还可以输入%ld次", (unsigned long)(MaxErrorCount - _errorCount)]];
        [self performSelector:@selector(refreshGesturePasswordView) withObject:self afterDelay:1.0]; // hhx
    }
    
    return NO;
}

- (BOOL)resetPassword:(NSString *)result {
    if ([self.previousString isEqualToString:@""] || self.previousString == nil) {
        // 设置手势密码时，最少输入4位
        if ([gesturePasswordView.tentacleView getEnterArginCount] >= MinEnterArginCount)
        {
            self.previousString = result;
            [gesturePasswordView.tentacleView enterArgin];
            [gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
            [gesturePasswordView.state setText:@"请验证输入密码"];
            return YES;
        }
        else
        {
            self.previousString = nil;
            [gesturePasswordView.state setTextColor:[UIColor redColor]];
            [gesturePasswordView.state setText:@"密码最少输入4位，请重新输入"];
            [self performSelector:@selector(refreshGesturePasswordView) withObject:self afterDelay:1.0]; // hhx
            return NO;
        }
    }
    else {
        if ([result isEqualToString:self.previousString]) {
//            KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
//            [keychin setObject:@"<帐号>" forKey:(__bridge id)kSecAttrAccount];
//            [keychin setObject:result forKey:(__bridge id)kSecValueData];
            
            [self saveGesturePassword:result];
            
            // 输入正确后  add by hhx 2015.03.11
            self.navigationController.navigationBarHidden = NO;
            
            // pop 改成 dismiss模态 modify by hhx 2015.05.27
            [self.navigationController popViewControllerAnimated:NO];
//            [self dismissViewControllerAnimated:NO completion:nil];
            
            if (_delegate && [_delegate respondsToSelector:@selector(resetGesturePasswordSuccess)]) {
                [_delegate resetGesturePasswordSuccess];
            }
            
            [gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
            [gesturePasswordView.state setText:@"已保存手势密码"];
            [self performSelector:@selector(refreshGesturePasswordView) withObject:self afterDelay:1.0]; // hhx
            return YES;
        }
        else {
            self.previousString = nil;
            [gesturePasswordView.state setTextColor:[UIColor redColor]];
            [gesturePasswordView.state setText:@"两次密码不一致，请重新输入"];
            [self performSelector:@selector(refreshGesturePasswordView) withObject:self afterDelay:1.0]; // hhx
            return NO;
        }
    }
}

// 刷新手势密码界面
- (void)refreshGesturePasswordView
{
    [gesturePasswordView.tentacleView enterArgin];
    
    // 重置密码时，两次不一致情况下，还原初始状态 add by hhx 2015.03.11
    if (gesturePasswordView.showGesturePwdView)
    {
        [gesturePasswordView.showGesturePwdView changeStateWithTouchesArray:nil];
    }
}

// 保存手势密码到配置中
- (void)saveGesturePassword:(NSString *)pwd
{
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:GESTURE_PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 获取配置中手势密码
- (NSString *)getGesturePassword
{
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:GESTURE_PASSWORD];
    return pwd;
}

/**
 *	@brief	显示手势密码视图（重置或验证 手势密码）
 */
- (void)showGetPwdView
{
    self.password = [self getGesturePassword];
    
    if (self.password == nil || [self.password isEqualToString:@""])
    {
        [self reset];
    }
    else
    {
        [self verify];
    }
}

// 显示用户名 add by hhx 2015.03.12
- (void)showUserName
{
    NSString *name = [KUtils getNickNameOfUser];
    if (name && name.length > 0) {
        [gesturePasswordView.name setText:name];
    }
}

/**
 *	@brief	弹出登录界面
 *
 *	@param 	type 	登录界面方式
 */
- (void)createLoginVC:(LOGIN_VIEW_TYPE)type
{
    UINavigationController *navi = self.navigationController;
    navi.navigationBarHidden = NO;
    
    // pop 改成 dismiss模态 modify by hhx 2015.05.27
    [navi popViewControllerAnimated:NO];
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    BOOL animated = YES;
    if (kIS_IOS8)
    {
        animated = NO;
        
        // 动画效果
        [KUtils showView:navi.view WithAnimationtype:kCATransitionPush andSubtype:kCATransitionFromRight];
    }
    
    LoginViewController *loginVC = kCreateVC(LoginViewController);
    loginVC.loginViewType = type;
    [navi pushViewController:loginVC animated:animated];
}

@end
