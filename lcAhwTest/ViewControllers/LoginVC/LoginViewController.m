//
//  LoginViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/17.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "LoginViewController.h"

#define LoginCellHeight 44.0f

typedef NS_ENUM(NSInteger, LoginViewTag)
{
    // 按钮的tag
    loginBtn_tag = 100,    // 登录按钮
    registerBtn_tag,       // 立即注册按钮
    forgetPwdBtn_tag,      // 忘记密码按钮
    showPwdBtn_tag         // 显示明文密码按钮
};

@interface LoginViewController ()
{
    NSArray *_dataArr;
    LoginData *_loginData;
}

@end

@implementation LoginViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.bIsNeedTapGesture = YES;
        self.bIsNeedKeyboardNotifications = YES;
        self.navLeftBarItemView.hidden = NO;
        self.navRightBarItemView.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"登录";
    
    _dataArr = @[[NSNumber numberWithInt:UserNameType],       //用户名
                 [NSNumber numberWithInt:PassWordType],       //密码
                 [NSNumber numberWithInt:ValidateCodeType]    //验证码
                ];
    _loginData = [[LoginData alloc] initWithRequestType:LOGIN_TYPE];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [self createFootView];
}


// 创建tableView的footView
- (UIView *)createFootView
{
    CGFloat footview_H = kSCREEN_HEIGHT - (_dataArr.count*LoginCellHeight) - 150;
    CGRect rect = CGRectMake(0.0, 0.0, kSCREEN_WIDTH, footview_H);
    UIView *footview = [[UIView alloc] initWithFrame:rect];
    
    CGFloat loginBtn_X = 20.0f;
    CGFloat loginBtn_Y = 20.0f;
    CGFloat loginBtn_W = kSCREEN_WIDTH - loginBtn_X*2;
    CGFloat loginBtn_H = 40.0f;
    rect = CGRectMake(loginBtn_X, loginBtn_Y, loginBtn_W, loginBtn_H);
    UIButton *loginBtn = [KUtils createButtonWithFrame:rect
                                                 title:@"登录"
                                            titleColor:[UIColor whiteColor]
                                                target:self
                                                   tag:loginBtn_tag];
    loginBtn.backgroundColor = [UIColor redColor];
    loginBtn.layer.cornerRadius = 8.0;
    [footview addSubview:loginBtn];
    
    return footview;
}


// UITableView Delegate + DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TextCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TextCellType textcellType = [[_dataArr objectAtIndex:indexPath.row] integerValue];
    if (!cell)
    {
        cell = [[TextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier type:textcellType delegate:self];
    }
    
    cell.textFd.tag = textcellType;
    //cell.textFd.placeholder = @"提示信息";
    if (cell.textFd.tag == PassWordType)
    {
        cell.rightBtn.tag = showPwdBtn_tag;
    }
    if (cell.textFd.tag == UserNameType)
    {
        cell.textFd.text = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY];
        _loginData.userName = cell.textFd.text;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LoginCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


// UITextField addTarget action
- (void)textFieldValueChange:(UITextField *)sender
{
    switch (sender.tag) {
        case UserNameType:
        {
            _loginData.userName = sender.text;
            break;
        }
        case PassWordType:
        {
            _loginData.userPwd = sender.text;
            break;
        }
        case ValidateCodeType:
        {
            // 限制长度...
            _loginData.validateCode = sender.text;
            break;
        }
        default:
        {
            break;
        }
    }
}


// 按钮点击事件
- (void)buttonAction:(id)sender
{
    if (self.activeTextField && [self.activeTextField isFirstResponder])
    {
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
    }
    
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag)
    {
        case showPwdBtn_tag:  // 显示/隐藏密码
        {
            // 获取cell
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            TextCell *pwdCell = (TextCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            
            pwdCell.textFd.secureTextEntry = !pwdCell.textFd.secureTextEntry;
            pwdCell.rightBtn.selected = !pwdCell.rightBtn.selected;
            
            break;
        }
        case loginBtn_tag:  // 登录
        {
            if ([self checkData]) // 数据输入校验
            {
                _loginData.userPwd = [KUtils md5:_loginData.userPwd]; //md5加密传输
                // 发送登录请求
                [self requestWithData:_loginData
                              success:^(id responseData){ // 成功
                                  
                                  // 保存账号密码
                                  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                                  [userDefault setObject:_loginData.userName forKey:USERNAME_KEY];
                                  [userDefault setObject:_loginData.userPwd forKey:USERPWD_KEY];
                                  [userDefault synchronize];
                                  
                                  // 保存登陆状态
                                  [SettingManager shareInstance].bIsLogined = YES;
                                  
                                  // 页面跳转
                                  NSArray *viewControllers = self.navigationController.viewControllers;
                                  NSInteger maxIndex = viewControllers.count - 1;
                                  NSInteger preIndex = 0;
                                  if (maxIndex > 0) // 前一个vc不为空（maxIndex==0表示navC里只有当前一个vc）
                                  {
                                      preIndex = maxIndex - 1;
                                  }
                                  id preVC = [viewControllers objectAtIndex:preIndex];
                                  
                                  if ([preVC isKindOfClass:[StartPageViewController class]])  // 之前是启动页
                                  {
                                      //启动页 push方式，不用present方式
//                                      [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                      [self.navigationController popToRootViewControllerAnimated:YES];
                                  }
                                  else  // 之前是其他页面
                                  {
                                      [self.navigationController popViewControllerAnimated:NO];
                                      [[HomeTabBarController getInstance] selectTabBarAtIndex:2 withAnimated:YES];
                                  }
                                  
                              }
                               failed:^(id error){ // 失败
                                   // 刷新验证码
                               }];
            }
            break;
        }
        default:
        {
            break;
        }
            
    }
}

// 登录校验
- (BOOL)checkData
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    TextCell *cell = (TextCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    ValidateCodeView *validatecodeView = [cell.rightBtn.subviews objectAtIndex:0];
    if (validatecodeView)
    {
        //NSString *kk = validatecodeView.codeString;
    }
    
    return YES;
}

@end
