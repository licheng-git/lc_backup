//
//  MyAccountPageController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/9.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "MyAccountPageController.h"

@interface MyAccountPageController ()
{
    UIImageView *_userImgView;          // 用户头像
    UILabel     *_userNameLb;           // 用户昵称
    UILabel     *_availableLb;          // 可用金额
    UILabel     *_profitTotalLb;        // 累计收益
    UILabel     *_profitRecoveredLb;    // 已收收益
    UILabel     *_amountUnRecoveredLb;  // 待收金额
    
    UIButton    *_rechargeBtn;    // 充值
    UIButton    *_cashBtn;        // 提现
    UIButton    *_pnrRegisterBtn; // 实名认证
    
    // 列表类型数组
    NSArray     *_typeArr0;
    NSArray     *_typeArr1;
}
@property (nonatomic, strong) MyAccountData *myAcctData;
@end

// cell类型设置
typedef NS_ENUM(NSInteger, MyAccountListViewItemType)
{
    AcctListItemType_FinancialRecord = 100,  // 资金纪录
    AcctListItemType_RepayPlan,              // 还款计划
    AcctListItemType_BankCardManagement,     // 银行卡管理
    AcctListItemType_MyInvestment,           // 我的投资
    AcctListItemType_Interest,               // 月息宝
    AcctListItemType_CreditAssign,           // 债权转让
};

typedef NS_ENUM(NSInteger, MyAccountBtnTag)
{
    AcctBtnTag_AccountInfo = 9000,  // 账户信息
    AcctBtnTag_Recharge,            // 充值
    AcctBtnTag_Cash,                // 提现
    AcctBtnTag_PnrRegister,         // 实名认证并开户
    AcctTag_BtnsMidLine,            // 充值提现中间的那根竖线
};

@implementation MyAccountPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的账户";
    [self setTypeArr];
    [self createView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 每次都请求最新数据
    [self sendMyAccountRequest];
}

// 列表类型设置
- (void)setTypeArr
{
    NSMutableArray *tempArr0 = [[NSMutableArray alloc] init];
    [tempArr0 addObject:[NSNumber numberWithInt:AcctListItemType_FinancialRecord]];
    [tempArr0 addObject:[NSNumber numberWithInt:AcctListItemType_RepayPlan]];
    [tempArr0 addObject:[NSNumber numberWithInt:AcctListItemType_BankCardManagement]];
    _typeArr0 = tempArr0;
    
    NSMutableArray *tempArr1 = [[NSMutableArray alloc] init];
    [tempArr1 addObject:[NSNumber numberWithInt:AcctListItemType_MyInvestment]];
    _typeArr1 = tempArr1;
}

// 创建视图
- (void)createView
{
    self.navLeftBarItemView.barImgView.image = [UIImage imageNamed:@"mail_image"];
    self.navRightBarItemView.barImgView.image = [UIImage imageNamed:@"set_image"];
    
    self.tableView.tableHeaderView = [self createTableHeaderView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] init]; //遮住tableView底部多余的横线
}

// 创建tableView的headerView
- (UIView *)createTableHeaderView
{
    CGFloat headerViewHeight = 170.0;
    CGRect rect = {0.0, 0.0, kSCREEN_WIDTH, headerViewHeight};
    UIView *headerView = [[UIView alloc] initWithFrame:rect];
    
    
    // 账户信息
    
    CGFloat acctBtnH = 70.0;
    rect = CGRectMake(0.0, 0.0, kSCREEN_WIDTH, acctBtnH);
    UIButton *acctBtn = [KUtils createButtonWithFrame:rect
                                                title:nil
                                           titleColor:nil
                                               target:self
                                                  tag:AcctBtnTag_AccountInfo];
    [headerView addSubview:acctBtn];
    
    // 用户头像
    UIImage *userImg = [UIImage imageNamed:@"user_head_image"];
    CGFloat userImgView_Y = (acctBtn.frame.size.height - userImg.size.height) / 2;
    CGFloat userImgView_X = userImgView_Y;
    rect = CGRectMake(userImgView_X, userImgView_Y, userImg.size.width, userImg.size.height);
    _userImgView = [[UIImageView alloc] initWithFrame:rect];
    _userImgView.image = userImg;
    [acctBtn addSubview:_userImgView];
    
    // 账户昵称
    CGFloat lbH = 20.0;
    CGFloat userNameLb_X = CGRectGetMaxX(_userImgView.frame) + 16.0f;
    CGFloat userNameLb_Y = CGRectGetMinY(_userImgView.frame) - 5.0f;
    CGFloat userNameLb_W = 300.0;
    rect = CGRectMake(userNameLb_X, userNameLb_Y, userNameLb_W, lbH);
    _userNameLb = [KUtils createLabelWithFrame:rect
                                         text:nil
                                     fontSize:16.0
                                textAlignment:NSTextAlignmentLeft
                                          tag:kDEFAULT_TAG];
    _userNameLb.text = [[NSUserDefaults standardUserDefaults] objectForKey:NICKNAME_KEY];
    [acctBtn addSubview:_userNameLb];
    
    // 可用金额
    CGFloat lbTitle_W = 70.0;
    CGFloat availableLb_Title_X = CGRectGetMinX(_userNameLb.frame);
    CGFloat availableLb_Title_Y = CGRectGetMaxY(_userNameLb.frame);
    rect = CGRectMake(availableLb_Title_X, availableLb_Title_Y, lbTitle_W, lbH);
    UILabel *availableLb_Title = [KUtils createLabelWithFrame:rect
                                                        text:@"可用金额"
                                                    fontSize:14.0
                                               textAlignment:NSTextAlignmentLeft
                                                         tag:kDEFAULT_TAG];
    availableLb_Title.textColor = [UIColor lightGrayColor];
    [acctBtn addSubview:availableLb_Title];
    
    CGFloat availableLb_Content_X = CGRectGetMaxX(availableLb_Title.frame);
    CGFloat availableLb_Content_Y = CGRectGetMinY(availableLb_Title.frame);
    CGFloat availableLb_Content_W = 200.0;
    rect = CGRectMake(availableLb_Content_X, availableLb_Content_Y, availableLb_Content_W, lbH);
    _availableLb = [KUtils createLabelWithFrame:rect
                                          text:@"--"
                                      fontSize:14.0
                                 textAlignment:NSTextAlignmentLeft
                                           tag:kDEFAULT_TAG];
    _availableLb.textColor = [UIColor orangeColor];
    [acctBtn addSubview:_availableLb];
    
    // 右边的箭头
    UIImage *arrowImg = [UIImage imageNamed:@"account_arrow_image"];
    CGFloat offsetFromEdge = 30.0;
    CGFloat arrowImgView_X = kSCREEN_WIDTH - offsetFromEdge - arrowImg.size.width;
    CGFloat arrowImgView_Y = (acctBtn.frame.size.height - arrowImg.size.height) / 2;
    rect = CGRectMake(arrowImgView_X, arrowImgView_Y, arrowImg.size.width, arrowImg.size.height);
    UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:rect];
    arrowImgView.image = arrowImg;
    [acctBtn addSubview:arrowImgView];
    
    
    // 白色背景（累计收益、已收收益、待收金额）
    rect = CGRectMake(0.0, CGRectGetMaxY(acctBtn.frame), kSCREEN_WIDTH, 50.0);
    UIView *acctView = [[UIView alloc] initWithFrame:rect];
    acctView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:acctView];
    
    // 累计收益
    CGFloat profitTotalLb_Title_X = 50.0;
    CGFloat profitTotalLb_Title_Y = (acctView.frame.size.height - lbH*2) / 2;
    rect = CGRectMake(profitTotalLb_Title_X, profitTotalLb_Title_Y, lbTitle_W, lbH);
    UILabel *profitTotalLb_Title = [KUtils createLabelWithFrame:rect
                                                          text:@"累计收益"
                                                      fontSize:14.0
                                                 textAlignment:NSTextAlignmentCenter
                                                           tag:kDEFAULT_TAG];
    profitTotalLb_Title.textColor = [UIColor lightGrayColor];
    [acctView addSubview:profitTotalLb_Title];
    
    CGFloat profitTotalLb_Content_X = CGRectGetMinX(profitTotalLb_Title.frame);
    CGFloat profitTotalLb_Content_Y = CGRectGetMaxY(profitTotalLb_Title.frame);
    CGFloat profitTotalLb_Content_W = profitTotalLb_Title.frame.size.width;
    rect = CGRectMake(profitTotalLb_Content_X, profitTotalLb_Content_Y, profitTotalLb_Content_W, lbH);
    _profitTotalLb = [KUtils createLabelWithFrame:rect
                                            text:@"--"
                                        fontSize:16.0
                                   textAlignment:NSTextAlignmentCenter
                                             tag:kDEFAULT_TAG];
    _profitTotalLb.textColor = [UIColor orangeColor];
    [acctView addSubview:_profitTotalLb];
    
    // 已收收益
    CGFloat profitRecoveredLb_Title_X = CGRectGetMaxX(profitTotalLb_Title.frame) + 80.f;
    CGFloat profitRecoveredLb_Title_Y = CGRectGetMinY(profitTotalLb_Title.frame);
    rect = CGRectMake(profitRecoveredLb_Title_X, profitRecoveredLb_Title_Y, lbTitle_W, lbH);
    UILabel *profitRecoveredLb_Title = [KUtils createLabelWithFrame:rect
                                                              text:@"已收收益"
                                                          fontSize:14.0
                                                     textAlignment:NSTextAlignmentLeft
                                                               tag:kDEFAULT_TAG];
    profitRecoveredLb_Title.textColor = [UIColor lightGrayColor];
    [acctView addSubview:profitRecoveredLb_Title];
    
    CGFloat profitRecoveredLb_Content_X = CGRectGetMaxX(profitRecoveredLb_Title.frame);
    CGFloat profitRecoveredLb_Content_Y = CGRectGetMinY(profitRecoveredLb_Title.frame);
    CGFloat profitRecoveredLb_Content_W = kSCREEN_WIDTH - CGRectGetMaxX(profitRecoveredLb_Title.frame);
    rect = CGRectMake(profitRecoveredLb_Content_X, profitRecoveredLb_Content_Y, profitRecoveredLb_Content_W, lbH);
    _profitRecoveredLb = [KUtils createLabelWithFrame:rect
                                                text:@"--"
                                            fontSize:14.0
                                       textAlignment:NSTextAlignmentLeft
                                                 tag:kDEFAULT_TAG];
    _profitRecoveredLb.textColor = [UIColor orangeColor];
    [acctView addSubview:_profitRecoveredLb];
    
    // 待收金额
    CGFloat amountUnRecoveredLb_Title_X = CGRectGetMinX(profitRecoveredLb_Title.frame);
    CGFloat amountUnRecoveredLb_Title_Y = CGRectGetMaxY(profitRecoveredLb_Title.frame);
    rect = CGRectMake(amountUnRecoveredLb_Title_X, amountUnRecoveredLb_Title_Y, lbTitle_W, lbH);
    UILabel *amountUnRecoveredLb_Title = [KUtils createLabelWithFrame:rect
                                                                text:@"待收金额"
                                                            fontSize:14.0
                                                       textAlignment:NSTextAlignmentLeft
                                                                 tag:kDEFAULT_TAG];
    amountUnRecoveredLb_Title.textColor = [UIColor lightGrayColor];
    [acctView addSubview:amountUnRecoveredLb_Title];
    
    CGFloat amountUnRecoveredLb_Content_X = CGRectGetMinX(_profitRecoveredLb.frame);
    CGFloat amountUnRecoveredLb_Content_Y = CGRectGetMaxY(_profitRecoveredLb.frame);
    CGFloat amountUnRecoveredLb_Content_W = CGRectGetWidth(_profitRecoveredLb.frame);
    rect = CGRectMake(amountUnRecoveredLb_Content_X, amountUnRecoveredLb_Content_Y, amountUnRecoveredLb_Content_W, lbH);
    _amountUnRecoveredLb = [KUtils createLabelWithFrame:rect
                                                  text:@"--"
                                              fontSize:14.0
                                         textAlignment:NSTextAlignmentLeft
                                                   tag:kDEFAULT_TAG];
    _amountUnRecoveredLb.textColor = [UIColor orangeColor];
    [acctView addSubview:_amountUnRecoveredLb];
    
    // 白色背景中间的竖线
    CGFloat lineX = CGRectGetMaxX(_profitTotalLb.frame) + 30.0;
    CGFloat lineY = 0.0;
    CGFloat lineW = 1.0;
    CGFloat lineH = acctView.frame.size.height;
    rect = CGRectMake(lineX, lineY, lineW, lineH);
    UIView *line0 = [[UIView alloc] initWithFrame:rect];
    line0.backgroundColor = [UIColor lightGrayColor];
    [acctView addSubview:line0];
    
    // 白色背景上面的横线
    rect = CGRectMake(0.0, 0.0, acctView.frame.size.width, 1.0);
    UIView *line1 = [[UIView alloc] initWithFrame:rect];
    line1.backgroundColor = [UIColor lightGrayColor];
    [acctView addSubview:line1];
    
    // 白色背景下面的横线
    rect = CGRectMake(0.0, acctView.frame.size.height, acctView.frame.size.width, 1.0);
    UIView *line2 = [[UIView alloc] initWithFrame:rect];
    line2.backgroundColor = [UIColor lightGrayColor];
    [acctView addSubview:line2];
    
    
    // 充值提现或实名认证 按钮布局
    CGFloat btnsViewH = 40.0;
    CGFloat btnsViewY = headerViewHeight - btnsViewH;
    rect = CGRectMake(0.0, btnsViewY, kSCREEN_WIDTH, btnsViewH);
    UIView *btnsView = [[UIView alloc] initWithFrame:rect];
    btnsView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:btnsView];
    
    // 实名认证并开户
    rect = CGRectMake(0.0, 0.0, btnsView.frame.size.width, btnsView.frame.size.height);
    _pnrRegisterBtn = [KUtils createButtonWithFrame:rect
                                              title:@"实名认证并开户 >"
                                         titleColor:[UIColor orangeColor]
                                             target:self
                                                tag:AcctBtnTag_PnrRegister];
    [btnsView addSubview:_pnrRegisterBtn];
    _pnrRegisterBtn.hidden = YES;
    
    // 充值
    rect = CGRectMake(0.0, 0.0, btnsView.frame.size.width/2, btnsView.frame.size.height);
    _rechargeBtn = [KUtils createButtonWithFrame:rect
                                           title:@"充值"
                                      titleColor:[UIColor orangeColor]
                                          target:self
                                             tag:AcctBtnTag_Recharge];
    [btnsView addSubview:_rechargeBtn];
    
    // 提现
    rect = CGRectMake(CGRectGetMaxX(_rechargeBtn.frame), 0.0, btnsView.frame.size.width/2, btnsView.frame.size.height);
    _cashBtn = [KUtils createButtonWithFrame:rect
                                       title:@"提现"
                                  titleColor:[UIColor orangeColor]
                                      target:self
                                         tag:AcctBtnTag_Cash];
    [btnsView addSubview:_cashBtn];
    
    // 充值提现按钮中间的竖线
    rect = CGRectMake(btnsView.frame.size.width/2, 0.0, 1.0, btnsView.frame.size.height);
    UIView *line3 = [[UIView alloc] initWithFrame:rect];
    line3.backgroundColor = [UIColor lightGrayColor];
    [btnsView addSubview:line3];
    line3.tag = AcctTag_BtnsMidLine;
    
    // 上面的横线
    rect = CGRectMake(0.0, 0.0, btnsView.frame.size.width, 1.0);
    UIView *line4 = [[UIView alloc] initWithFrame:rect];
    line4.backgroundColor = [UIColor lightGrayColor];
    [btnsView addSubview:line4];
    
    // 下面的横线
    rect = CGRectMake(0.0, btnsView.frame.size.height, btnsView.frame.size.width, 1.0);
    UIView *line5 = [[UIView alloc] initWithFrame:rect];
    line5.backgroundColor = [UIColor lightGrayColor];
    [btnsView addSubview:line5];
    
    return headerView;
}

// 发送请求
- (void)sendMyAccountRequest
{
    MyAccountData *myAcctData = [[MyAccountData alloc] initWithRequestType:MYACCOUNT_TYPE];
    [self requestWithData:myAcctData
                  success:^(id responseData){
                      
                      if (!responseData)
                      {
                          return;
                      }
                      self.myAcctData = (MyAccountData *)responseData;
                      
                      // 可用金额
                      _availableLb.text = self.myAcctData.avlBal;
                      // 累计收益
                      _profitTotalLb.text = self.myAcctData.profitPlan;
                      // 已收收益
                      _profitRecoveredLb.text = self.myAcctData.profitFact;
                      // 待收金额
                      _amountUnRecoveredLb.text = self.myAcctData.unRecovered;
                      
                      // 未读信息数 气泡
                      if (self.myAcctData.unReadMsgCount>0)
                      {
                          [self.navLeftBarItemView setBubbleTitle:[NSString stringWithFormat:@"%i",self.myAcctData.unReadMsgCount]];
                      }
                      
                      // 是否实名认证
                      if (!self.myAcctData.isValid)
                      {
                          _rechargeBtn.hidden = YES;
                          _cashBtn.hidden = YES;
                          UIView *lineMindBtns = [self.view viewWithTag:AcctTag_BtnsMidLine];
                          if (lineMindBtns)
                          {
                              lineMindBtns.hidden = YES;
                          }
                          _pnrRegisterBtn.hidden = NO;
                      }
                      else
                      {
                          _rechargeBtn.hidden = NO;
                          _cashBtn.hidden = NO;
                          UIView *lineMindBtns = [self.view viewWithTag:AcctTag_BtnsMidLine];
                          if (lineMindBtns)
                          {
                              lineMindBtns.hidden = NO;
                          }
                          _pnrRegisterBtn.hidden = YES;
                      }
                      
                      
                      //[self.tableView reloadData];
                      
                      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                      MyAccountCell *cell = (MyAccountCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                      cell.rightContentLb.text = [NSString stringWithFormat:@"%i张", self.myAcctData.cardCount];
                      
                      indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                      cell = (MyAccountCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                      cell.rightContentLb.text = [NSString stringWithFormat:@"%i个项目", self.myAcctData.investCount];
                      
                  }
                   failed:^(id error){
                   }];
}


#pragma mark - UITableView DataSource+Delegate
// section块数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// section块中的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return _typeArr0.count;
    }
    else if (section == 1)
    {
        return _typeArr1.count;
    }
    else
    {
        return 0;
    }
}

// section块的header高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0.0001f;
    }
    else if (section == 1)
    {
        return 15.0;
    }
    else
    {
        return 0;
    }
}

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

// 装载cell数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MyAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (!cell)
    {
        cell = [[MyAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.leftTitleLb.text = @"资金记录";
        cell.tag = AcctListItemType_FinancialRecord;
        cell.rightContentLb.hidden = YES;
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell.leftTitleLb.text = @"还款计划";
        cell.tag = AcctListItemType_RepayPlan;
        cell.rightContentLb.hidden = YES;
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        cell.leftTitleLb.text = @"银行卡管理";
        cell.tag = AcctListItemType_BankCardManagement;
        cell.rightContentLb.text = [NSString stringWithFormat:@"%i张", self.myAcctData.cardCount];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.leftTitleLb.text = @"我的投资";
        cell.tag = AcctListItemType_MyInvestment;
        cell.rightContentLb.text = [NSString stringWithFormat:@"%i个项目", self.myAcctData.investCount];
    }
    
    return cell;
}

// 点击行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyAccountCell *cell = (MyAccountCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == AcctListItemType_FinancialRecord)
    {
        // 资金记录
        
    }
    else if (cell.tag == AcctListItemType_RepayPlan)
    {
        // 还款计划
    }
    else if (cell.tag == AcctListItemType_BankCardManagement)
    {
        // 银行卡管理
    }
    else if (cell.tag == AcctListItemType_MyInvestment)
    {
        // 我的投资
    }
}

// 按钮点击事件
- (void)buttonAction:(UIButton *)sender
{
    if (sender.tag == AcctBtnTag_AccountInfo)
    {
        // 查看我的账户信息详情
    }
    else if (sender.tag == AcctBtnTag_PnrRegister)
    {
        // 实名认证并开户
    }
    else if (sender.tag == AcctBtnTag_Recharge)
    {
        // 充值
    }
    else if (sender.tag == AcctBtnTag_Cash)
    {
        // 提现
    }
}


// NavBarItemViewDelegate 点击导航栏按钮
- (void)clickNavBarItemView:(NavBarItemView *)navBarItemView navBarType:(NavBarType)type
{
}

@end
