//
//  InvestDetailViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/29.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "InvestDetailViewController.h"

#define BottomView_H    70.0

// 实现委托时区分是哪个CustomTableView的
typedef NS_ENUM(NSInteger, CustomTableViewTag)
{
    CustomTableViewTag_Records = 10,
    CustomTableViewTag_RepayPlan
};

@interface InvestDetailViewController ()
{
    ButtonSelectView       *_selectControl;
    NSMutableArray         *_viewsArr;
    LoanInfoView           *_loanInfoView;
    CustomTableView        *_recordsView;
    CustomTableView        *_repayPlanView;
    BidDetailBottomView    *_bottomView;
}
@property (nonatomic, strong) BidDetailData *bidDetailData;
@property (nonatomic, strong) UIImageView *bidTypeImageView;
@property (nonatomic, strong) UILabel *bidZAContractCodeLabel;
@property (nonatomic, strong) UILabel *bidAmountLabel;
@property (nonatomic, strong) UILabel *bidRateLabel;
@property (nonatomic, strong) UILabel *bidDateLimitLabel;
@property (nonatomic, strong) UILabel *bidRepayTypeLabel;
@property (nonatomic, strong) UILabel *bidNeedTotalLabel;
@property (nonatomic, strong) NSMutableArray *bidRecordDataList;       // 投标记录 数据
@property (nonatomic, strong) NSMutableArray *bidRepayPlanDataList;    // 还款计划 数据
@end

@implementation InvestDetailViewController

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        self.title = @"散标详情";
        [SettingManager shareInstance].investDetail_recordPage = kDefaultPageNum;
        [SettingManager shareInstance].investDetail_payPlanPage = kDefaultPageNum;
        self.bIsNeedTapGesture = YES;
        self.bIsNeedKeyboardNotifications = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 每次进入页面清空投标记录和还款计划
    self.bidRecordDataList = nil;
    self.bidRepayPlanDataList = nil;
    [SettingManager shareInstance].investDetail_recordPage = kDefaultPageNum;
    [SettingManager shareInstance].investDetail_recordPage = kDefaultPageNum;
    
    [self sendBidDetailRequest];
}

// 创建视图
- (void)createView
{
    CGFloat headerH = 160.0;
    CGRect rect = CGRectMake(0.0, kDEFAULT_ORIGIN_Y, kSCREEN_WIDTH, headerH);
    UIView *bgView = [[UIView alloc] initWithFrame:rect];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    // 产品类型（老板贷/业主贷/薪贷）
    CGFloat bidTypeImgX = 10.0;
    CGFloat bidTypeImgY = 10.0;
    CGFloat bidTypeImgW = 20.0;
    CGFloat bidTypeImgH = 20.0;
    rect = CGRectMake(bidTypeImgX, bidTypeImgY, bidTypeImgW, bidTypeImgH);
    self.bidTypeImageView = [[UIImageView alloc] initWithFrame:rect];
    [bgView addSubview:self.bidTypeImageView];
    
    // 借款代码
    CGFloat bidZAContractCodeX = CGRectGetMaxX(self.bidTypeImageView.frame) + 5.0;
    CGFloat bidZAContractCodeY = CGRectGetMinY(self.bidTypeImageView.frame);
    CGFloat bidZAContractCodeW = 150.0;
    CGFloat bidZAContractCodeH = 20.0;
    rect = CGRectMake(bidZAContractCodeX, bidZAContractCodeY, bidZAContractCodeW, bidZAContractCodeH);
    self.bidZAContractCodeLabel = [[UILabel alloc] initWithFrame:rect];
    [bgView addSubview:self.bidZAContractCodeLabel];
    
    CGFloat labelH = 20.0;
    CGFloat labelW = 90.0;
    CGFloat amountTitleW = 130.0;
    
    // 借款金额
    UILabel *amountTitle = [self createTitleLabel];
    CGFloat amountTitleX = CGRectGetMinX(self.bidTypeImageView.frame) + 10.0;
    CGFloat amountTitleY = CGRectGetMaxY(self.bidTypeImageView.frame) + 5.0;
    amountTitle.frame = CGRectMake(amountTitleX, amountTitleY, amountTitleW, labelH);
    amountTitle.text = @"金额";
    [bgView addSubview:amountTitle];
    
    self.bidAmountLabel = [self createContentLabel];
    CGFloat amountContentX = CGRectGetMinX(amountTitle.frame) - 5.0;
    CGFloat amountContentY = CGRectGetMaxY(amountTitle.frame) + 5.0;
    self.bidAmountLabel.frame = CGRectMake(amountContentX, amountContentY, amountTitleW, labelH);
    [bgView addSubview:self.bidAmountLabel];
    
    // 年利率
    UILabel *rateTitle = [self createTitleLabel];
    rateTitle.frame = CGRectMake(CGRectGetMaxX(amountTitle.frame), CGRectGetMinY(amountTitle.frame), labelW, labelH);
    rateTitle.text = @"年利率";
    [bgView addSubview:rateTitle];
    
    self.bidRateLabel = [self createContentLabel];
    self.bidRateLabel.frame = CGRectMake(CGRectGetMaxX(amountTitle.frame), CGRectGetMaxY(amountTitle.frame), labelW, labelH);
    [bgView addSubview:self.bidRateLabel];
    
    // 期限
    UILabel *datelimitTitle = [self createTitleLabel];
    datelimitTitle.frame = CGRectMake(CGRectGetMaxX(rateTitle.frame), CGRectGetMinY(rateTitle.frame), labelW, labelH);
    datelimitTitle.text = @"期限";
    [bgView addSubview:datelimitTitle];
    
    self.bidDateLimitLabel = [self createContentLabel];
    self.bidDateLimitLabel.frame = CGRectMake(CGRectGetMaxX(rateTitle.frame), CGRectGetMaxY(rateTitle.frame), labelW, labelH);
    [bgView addSubview:self.bidDateLimitLabel];
    
    // 分割线
    UIView *line = [[UIView alloc] init];
    CGFloat lineX = CGRectGetMinX(self.bidTypeImageView.frame);
    CGFloat lineY = CGRectGetMaxY(self.bidDateLimitLabel.frame) + 10.0;
    CGFloat lineW = bgView.frame.size.width - (CGRectGetMinX(self.bidTypeImageView.frame)*2);
    CGFloat lineH = 1.0f;
    line.frame = CGRectMake(lineX, lineY, lineW, lineH);
    line.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:line];
    
    // 还款方式
    UILabel *repayTypeTitle = [self createTitleLabel];
    CGFloat repayTypeTitleX = CGRectGetMinX(amountTitle.frame);
    CGFloat repayTypeTitleY = CGRectGetMaxY(line.frame) + 10.0;
    CGFloat repayTypeTitleW = labelW - 30.0;
    repayTypeTitle.frame = CGRectMake(repayTypeTitleX, repayTypeTitleY, repayTypeTitleW, labelH);
    repayTypeTitle.text = @"还款方式";
    [bgView addSubview:repayTypeTitle];
    
    self.bidRepayTypeLabel = [self createContentLabel];
    self.bidRepayTypeLabel.frame = CGRectMake(CGRectGetMaxX(repayTypeTitle.frame), CGRectGetMinY(repayTypeTitle.frame), labelW, labelH);
    [bgView addSubview:self.bidRepayTypeLabel];
    
    // 可投金额
    UILabel *needTotalTitle = [self createTitleLabel];
    needTotalTitle.frame = CGRectMake(CGRectGetMinX(repayTypeTitle.frame), CGRectGetMaxY(repayTypeTitle.frame) + 10.0, repayTypeTitleW, labelH);
    needTotalTitle.text = @"可投金额";
    [bgView addSubview:needTotalTitle];
    
    self.bidNeedTotalLabel = [self createContentLabel];
    self.bidNeedTotalLabel.frame = CGRectMake(CGRectGetMaxX(needTotalTitle.frame), CGRectGetMinY(needTotalTitle.frame), labelW, labelH);
    [bgView addSubview:self.bidNeedTotalLabel];
    
    // 进度
    
    // 选择器+滑动视图（借款信息，投标记录，还款计划）
    CGFloat selectControlX = 0.0;
    CGFloat selectControlY = CGRectGetMaxY(bgView.frame) + 10.0;
    CGFloat selectControlW = kSCREEN_WIDTH;
    CGFloat selectControlH = self.view.frame.size.height - selectControlY - BottomView_H;
    rect = CGRectMake(selectControlX, selectControlY, selectControlW, selectControlH);
    [self createSelectControlView:rect];
    
    // 底部投标等按钮
    rect = CGRectMake(0.0, CGRectGetMaxY(_selectControl.frame), kSCREEN_WIDTH, BottomView_H);
    _bottomView = [[BidDetailBottomView alloc] initWithFrame:rect];
    [self.view addSubview:_bottomView];
    
}

// 创建标题label
- (UILabel *)createTitleLabel
{
    UILabel *titleLb = [[UILabel alloc] init];
    titleLb.font = [UIFont systemFontOfSize:14.0];
    titleLb.textAlignment = NSTextAlignmentLeft;
    titleLb.backgroundColor = [UIColor clearColor];
    titleLb.textColor = [UIColor lightGrayColor];
    return titleLb;
}

// 创建内容label
- (UILabel *)createContentLabel
{
    UILabel *contentLb = [[UILabel alloc] init];
    contentLb.font = [UIFont systemFontOfSize:16.0];
    contentLb.textAlignment = NSTextAlignmentLeft;
    contentLb.backgroundColor = [UIColor clearColor];
    contentLb.textColor = [UIColor orangeColor];
    return contentLb;
}

// 选择器+滑动视图（借款信息，投标记录，还款计划）
- (void)createSelectControlView:(CGRect)frame
{
    if (_viewsArr == nil)
    {
        _viewsArr = [[NSMutableArray alloc] init];
    }
    
    // *_* 子视图在init时添加不是太好，可以先初始化好控件后 再获取控件里面的scrollView.frame 再设置子视图和子视图的frame
    CGRect viewFrame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height - SelectControlBtnsHeight);
    
    // 借款信息
    _loanInfoView = [[LoanInfoView alloc] initWithFrame:viewFrame];
    [_viewsArr addObject:_loanInfoView];

    // 投标记录
    NSArray *tbTitles = @[@"用户名", @"金额", @"时间"];
    _recordsView = [[CustomTableView alloc] initWithFrame:viewFrame titleArr:tbTitles tag:CustomTableViewTag_Records];
    _recordsView.delegate = self;
    [_viewsArr addObject:_recordsView];
    
    // 还款计划
    NSArray *tbTitles1 = @[@"还款日期", @"本金", @"利息"];
    _repayPlanView = [[CustomTableView alloc] initWithFrame:viewFrame titleArr:tbTitles1 tag:CustomTableViewTag_RepayPlan];
    _repayPlanView.delegate = self;
    [_viewsArr addObject:_repayPlanView];

    NSArray *titles = @[@"借款信息", @"投标记录", @"还款计划"];
    _selectControl = [[ButtonSelectView alloc] initWithFrame:frame btnsTitleArr:titles scrollViewSubviews:_viewsArr];
    _selectControl.delegate = self;
    [self.view addSubview:_selectControl];
}

// 加载数据 标的详情，借款信息，底部按钮
- (void)loadBidDetailData
{
    //self.bidTypeImageView.image =
    self.bidZAContractCodeLabel.text = self.bidDetailData.ZAContractCode;
    self.bidAmountLabel.text = self.bidDetailData.total;
    self.bidRateLabel.text = self.bidDetailData.rate;
    self.bidDateLimitLabel.text = self.bidDetailData.dateLimit;
    self.bidRepayTypeLabel.text = self.bidDetailData.payTypeName;
    self.bidNeedTotalLabel.text = self.bidDetailData.needTotalText;
    if (_loanInfoView)
    {
        [_loanInfoView setLoanInfoArr:self.bidDetailData.loanInfoArr];
    }
    if (_bottomView)
    {
        [_bottomView createViewWithData:self.bidDetailData delegate:self];
    }
}

// ButtonSelectViewDelegate 点击或滑动按钮（按钮变化）
- (void)selectChangeAt:(id)sender index:(NSInteger)index
{
    if (index == 0)
    {
        // 借款信息（散标详情）
        if (!self.bidDetailData)
        {
            self.showAnima = YES;
            [self sendBidDetailRequest];
        }
    }
    else if (index == 1)
    {
        // 投标记录
        // 第一次显示才从服务端拉取数据，以后都上拉刷新时才拉取
        if (!self.bidRecordDataList && _recordsView && !_recordsView.bIsLastPage)
        {
            self.showAnima = NO;
            [self sendBidRecordsRequest];
        }
    }
    else if (index == 2 )
    {
        // 还款计划
        if (!self.bidRepayPlanDataList && _repayPlanView && !_repayPlanView.bIsLastPage)
        {
            self.showAnima = NO;
            [self sendBidRepayPlanRequest];
        }
    }
}

// 发送请求获取数据（散标详情＋借款信息）
- (void)sendBidDetailRequest
{
    BidDetailData *data = [[BidDetailData alloc] initWithRequestType:BIDDETAIL_TYPE];
    [self requestWithData:data
                  success:^(id responseData){
                      
                      self.bidDetailData = (BidDetailData *)responseData;
                      if (self.bidDetailData)
                      {
//                          [self removeAllSubviews];
//                          [self createView];
                          [self loadBidDetailData];
                      }
                  }
                   failed:^(id error){
                   }];
}

// 发送请求 获取投标记录
- (void)sendBidRecordsRequest
{
    RecordDataList *data = [[RecordDataList alloc] initWithRequestType:BIDRECORDS_TYPE];
    [self requestWithData:data
                  success:^(id responseData){
                      
                      // 结束上拉刷新（因为CustomTableView没有继承基类，所以发送请求后没法自动结束刷新，需在这里调用）
                      [_recordsView endRefresh];
                      
                      self.bidRecordDataList = ((RecordDataList *)responseData).datalist;
                      // 模拟 范型
                      NSMutableArray *dataArr = [[NSMutableArray alloc] init];
                      for (RecordData *recorddata in self.bidRecordDataList)
                      {
                          NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:3];
//                          [data addObject:recorddata.nickName];
//                          [data addObject:recorddata.money];
//                          [data addObject:recorddata.time];
                          [data addObject:(recorddata.nickName ? recorddata.nickName : @"")];
                          [data addObject:(recorddata.money ? recorddata.money : @"")];
                          [data addObject:(recorddata.time ? recorddata.time : @"")];
                          
                          [dataArr addObject:data];
                      }
                      //[_recordsView setDatas:dataArr]; //*_*
                      [_recordsView reloadTableViewWithDatas:dataArr];
                      
                  }
                   failed:^(id error){
                       
                       // 结束上拉刷新
                       [_recordsView endRefresh];
                       
                   }];
}

// 发送请求 获取还款计划
- (void)sendBidRepayPlanRequest
{
    RepayPlanDataList *data = [[RepayPlanDataList alloc] initWithRequestType:BIDREPAYPLAN_TYPE];
    [self requestWithData:data
                  success:^(id responseData){
                      
                      // 结束上拉刷新
                      [_repayPlanView endRefresh];
                      
                      self.bidRepayPlanDataList = ((RepayPlanDataList *)responseData).datalist;
                      // 模拟 范型
                      NSMutableArray *dataArr = [[NSMutableArray alloc] init];
                      for (RepayPlanData *repayplandata in self.bidRepayPlanDataList)
                      {
                          NSMutableArray *data = [[NSMutableArray alloc] init];
                          [data addObject:(repayplandata.repayDate ? repayplandata.repayDate : @"")];
                          [data addObject:(repayplandata.principal ? repayplandata.principal : @"")];
                          [data addObject:(repayplandata.interest ? repayplandata.interest : @"")];
                          
                          [dataArr addObject:data];
                      }
                      [_repayPlanView reloadTableViewWithDatas:dataArr];
                      
                  }
                   failed:^(id error){
                       
                       // 结束上拉刷新
                       [_repayPlanView endRefresh];
                       
                   }];
}


// CustomTableViewDelegate
// 上拉刷新
- (void)refreshRequestWithTag:(NSInteger)tag
{
    if (tag == CustomTableViewTag_Records)
    {
        // 刷新投标记录
        [SettingManager shareInstance].investDetail_recordPage++;
        [self sendBidRecordsRequest];
    }
    else if (tag == CustomTableViewTag_RepayPlan)
    {
        // 刷新还款计划
        [SettingManager shareInstance].investDetail_payPlanPage++;
        [self sendBidRepayPlanRequest];
    }
}


// _bottomView.UITextField addTarget action
- (void)textFieldValueChange:(UITextField *)sender
{
}

// _bottomView.UITextField UITextFieldDelegate  控制只可以输入数字（小数点不可以）
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 控制输入的为纯数字
    NSUInteger lengthOfString = string.length;
    for (NSInteger loopIndex = 0; loopIndex < lengthOfString; loopIndex++)
    {
        //只允许数字输入
        unichar character = [string characterAtIndex:loopIndex];
        if (character < 48)
        {
            return NO; // 48 unichar for 0
        }
        if (character > 57)
        {
            return NO; // 57 unichar for 9
        }
    }
    
    // 控制长度
    NSUInteger proposedNewLength = textField.text.length - range.length + string.length;
    if (proposedNewLength > 8)
    {
        return NO;
    }
    return YES;
}


// 按钮点击
- (void)buttonAction:(UIButton *)sender
{
    if (sender.tag == BidDetailBtnTag_CheckAgreenment)
    {
        // 勾选 “我已阅读并同意。。。”
        sender.selected = !sender.selected;
    }
    else if (sender.tag == BidDetailBtnTag_SeeAgreenment)
    {
        // 查看《借款协议》
    }
    else if (sender.tag == BidDetailBtnTag_Login)
    {
        // 登陆
    }
    else if (sender.tag == BidDetailBtnTag_Rigister)
    {
        // 注册
    }
    else if (sender.tag == BidDetailBtnTag_PnrRigister)
    {
        // 实名认证并开户
    }
    else if (sender.tag == BidDetailBtnTag_Charge)
    {
        // 充值
    }
    else if (sender.tag == BidDetailBtnTag_Invest)
    {
        // 投标
    }
}


@end
