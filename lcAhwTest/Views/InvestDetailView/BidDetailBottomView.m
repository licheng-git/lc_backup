//
//  BidDetailBottomView.m
//  lcAhwTest
//
//  Created by licheng on 15/5/5.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BidDetailBottomView.h"
#import "KUtils.h"

@interface BidDetailBottomView()
{
//    id _delegate; //*_* 无法执行BaseViewController的dealloc
    BidDetailData *_data;
}
@property (nonatomic, assign) id delegate;
@end

@implementation BidDetailBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (void)createViewWithData:(BidDetailData *)data delegate:(id)delegate
{
    _data = data;
    _delegate = delegate;
    CGRect frame = self.frame;
    CGFloat agreementLbW = 100.0;
    CGFloat agreementLbH = 20.0;
    CGFloat agreementBtnW = 100.0;
    CGFloat agreementBtnH = 20.0;
    CGFloat bottomBtnW = kSCREEN_WIDTH / 2;
    CGFloat bottomBtnH = 40.0;
    CGFloat horSpace = 5.0;
    CGFloat verSpace = 10.0;
    CGRect rect = {0.0, 0.0, 0.0, 0.0};
    self.backgroundColor = kBACKGROUND_COLOR;
    
    // check 我已阅读并同意 《借款协议》
    // check按钮
    UIImage *checkImg = [UIImage imageNamed:@"checkbox_bg"];
    UIImage *checkImgSel = [UIImage imageNamed:@"checkbox_sel_bg"];
    CGFloat checkBtnX = (kSCREEN_WIDTH - checkImg.size.width - agreementLbW - agreementBtnW - horSpace) / 2;
    CGFloat checkBtnY = frame.size.height - bottomBtnH - verSpace - checkImg.size.height;
    rect = CGRectMake(checkBtnX, checkBtnY, checkImg.size.width, checkImg.size.height);
    _checkBtn = [KUtils createButtonWithFrame:rect
                                        title:nil
                                   titleColor:nil
                                       target:_delegate
                                          tag:BidDetailBtnTag_CheckAgreenment];
    [_checkBtn setBackgroundImage:checkImg forState:UIControlStateNormal];
    [_checkBtn setBackgroundImage:checkImgSel forState:UIControlStateSelected];
    _checkBtn.selected = YES;
    [self addSubview:_checkBtn];
    
    // label 我已阅读并同意
    rect = CGRectMake(CGRectGetMaxX(_checkBtn.frame) + horSpace,
                      CGRectGetMinY(_checkBtn.frame) - (agreementLbH - _checkBtn.frame.size.height)/2,
                      agreementLbW,
                      agreementLbH);
    _agreementLb = [KUtils createLabelWithFrame:rect
                                          text:@"我已阅读并同意"
                                      fontSize:14.0f
                                 textAlignment:NSTextAlignmentLeft
                                           tag:kDEFAULT_TAG];
    _agreementLb.backgroundColor = [UIColor clearColor];
    [self addSubview:_agreementLb];
    
    //《借款协议》 查看 按钮
    rect = CGRectMake(CGRectGetMaxX(_agreementLb.frame) , CGRectGetMinY(_agreementLb.frame), agreementBtnW, agreementBtnH);
    _agreementBtn = [KUtils createButtonWithFrame:rect
                                            title:@"《借款协议》"
                                       titleColor:[UIColor orangeColor]
                                           target:_delegate
                                              tag:BidDetailBtnTag_SeeAgreenment];
    _agreementBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _agreementBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:_agreementBtn];
    
    // 分割线
    rect = CGRectMake(0.0, CGRectGetMaxY(_checkBtn.frame) + verSpace, kSCREEN_WIDTH, 1.0);
    UIView *lineView = [[UIView alloc] initWithFrame:rect];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView];
    
    // 未登陆
    if (![SettingManager shareInstance].bIsLogined)
    {
        // 登陆按钮
        rect = CGRectMake(0.0, frame.size.height - bottomBtnH, bottomBtnW, bottomBtnH);
        _loginBtn = [KUtils createButtonWithFrame:rect
                                            title:@"登陆"
                                       titleColor:[UIColor lightGrayColor]
                                           target:_delegate
                                              tag:BidDetailBtnTag_Login];
        _loginBtn.backgroundColor = kNAV_BG_COLOR;
        [self addSubview:_loginBtn];
        
        // 注册按钮
        rect = CGRectMake(CGRectGetMaxX(_loginBtn.frame), CGRectGetMinY(_loginBtn.frame), bottomBtnW, bottomBtnH);
        _rigisterBtn = [KUtils createButtonWithFrame:rect
                                               title:@"注册"
                                          titleColor:[UIColor lightGrayColor]
                                              target:_delegate
                                                 tag:BidDetailBtnTag_Rigister];
        [self addSubview:_rigisterBtn];
    }
    else
    {
        // 根据 data.BtnStatus 创建对应按钮
        CGFloat bottomBtnW = kSCREEN_WIDTH;
        rect = CGRectMake(0.0, frame.size.height - bottomBtnH, bottomBtnW, bottomBtnH);
        _actionBtn = [KUtils createButtonWithFrame:rect
                                             title:_data.btnDesc
                                        titleColor:[UIColor lightGrayColor]
                                            target:_delegate
                                               tag:kDEFAULT_TAG];
        _actionBtn.enabled = NO;
        [self addSubview:_actionBtn];
        
        if ([_data.btnStatus isEqualToString:kBtnStatus_1])
        {
            // 实名认证
            _actionBtn.tag = BidDetailBtnTag_PnrRigister;
//            _actionBtn.titleLabel.text = @"实名认证 >";
            [self makeActionBtnEnabled];
            [self makeAgreementHidden];
        }
        else if ([_data.btnStatus isEqualToString:kBtnStatus_2])
        {
            // 余额不足，充值
            _actionBtn.tag = BidDetailBtnTag_Charge;
//            _actionBtn.titleLabel.text = @"立即充值";
            [self makeActionBtnEnabled];
            [self makeAgreementHidden];
            [self createTextFeild];
        }
        else if ([_data.btnStatus isEqualToString:kBtnStatus03])
        {
            // 立即投标
            _actionBtn.tag = BidDetailBtnTag_Invest;
//            _actionBtn.titleLabel.text = @"立即投标";
            [self makeActionBtnEnabled];
            [self createTextFeild];
        }
    }

}

// _actionBtn设置为可用
- (void)makeActionBtnEnabled
{
    _actionBtn.enabled = YES;
    _actionBtn.backgroundColor = kNAV_BG_COLOR;
    [_actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

// 隐藏 checkbox我已阅读并同意《借款协议》 （ *_* 并改变视图高度和frame ）
- (void)makeAgreementHidden
{
    _checkBtn.hidden = YES;
    _agreementLb.hidden = YES;
    _agreementBtn.hidden = YES;
    
//    CGRect vFrame = CGRectMake(0.0, kSCREEN_HEIGHT - _actionBtn.frame.size.height, self.frame.size.width, _actionBtn.frame.size.height);
//    self.frame = vFrame;
    
    // *_* bottomView的高度减小，同时 减小的高度要补给selectControl.scrollView，所以需要到vc里的控件初始化时搞好frame
    
    _actionBtn.frame = self.bounds;
}

// 创建UITextFeild
- (void)createTextFeild
{
    // 重新设置_actionBtn宽度，靠右
    CGFloat bottomBtnW = kSCREEN_WIDTH / 2;
    CGRect rect = CGRectMake(bottomBtnW, CGRectGetMinY(_actionBtn.frame), bottomBtnW, _actionBtn.frame.size.height);
    _actionBtn.frame = rect;
    
    rect = CGRectMake(0.0, CGRectGetMinY(_actionBtn.frame), bottomBtnW, _actionBtn.frame.size.height);
    _inputTF = [KUtils createTextFieldWithFrame:rect
                                       fontSize:14.0
                                         enable:YES
                                       delegate:_delegate
                                            tag:kDEFAULT_TAG];
    _inputTF.placeholder = _data.textTip;
    _inputTF.textAlignment = NSTextAlignmentCenter;
    _inputTF.keyboardType = UIKeyboardTypeNumberPad;
    [self addSubview:_inputTF];
}

@end
