//
//  TextCell.m
//  lcAhwTest
//
//  Created by licheng on 15/4/20.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "TextCell.h"

@implementation TextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                         type:(TextCellType)type
                     delegate:(id)delegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 背景图
        CGFloat contentView_H = self.contentView.frame.size.height;
        CGRect rect = CGRectMake(0.0, 0.0, kSCREEN_WIDTH, contentView_H);
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:rect];
        bgImageView.userInteractionEnabled = YES; // 拉伸图片
        bgImageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgImageView];
        
        // 文本框输入
        self.textFd = [KUtils createTextFieldWithFrame:CGRectZero
                                              fontSize:14.0
                                                enable:YES
                                              delegate:delegate
                                                   tag:kDEFAULT_TAG];
        self.textFd.backgroundColor = [UIColor whiteColor];
        [bgImageView addSubview:self.textFd];
        
        // 左边标题label
        CGFloat leftview_W = 60.0;
        rect = CGRectMake(0.0, 0.0, leftview_W, contentView_H);
        self.leftTitleLb = [KUtils createLabelWithFrame:rect
                                                  text:nil
                                              fontSize:14.0
                                         textAlignment:NSTextAlignmentLeft
                                                   tag:kDEFAULT_TAG];
        [bgImageView addSubview:self.leftTitleLb];
        
        // 右边按钮button
        CGFloat rightview_W = 120.0;
        rect = CGRectMake(kSCREEN_WIDTH - rightview_W - kLEFT_SPACE, kLINE_SPACE, rightview_W, contentView_H -10.0);
        self.rightBtn = [KUtils createButtonWithFrame:rect
                                                title:nil
                                           titleColor:nil
                                               target:delegate
                                                  tag:kDEFAULT_TAG];
        self.rightBtn.backgroundColor = [UIColor whiteColor];
        [bgImageView addSubview:self.rightBtn];
        
        // 根据type设置textcell
        if (type == UserNameType)
        {
            self.leftTitleLb.hidden = YES;
            self.rightBtn.hidden = YES;
            
            self.textFd.placeholder = @"手机号/邮箱/用户名";
            self.textFd.frame = CGRectMake(kLEFT_SPACE, 0.0, kSCREEN_WIDTH - kLEFT_SPACE, contentView_H);
        }
        else if (type == PassWordType)
        {
            self.leftTitleLb.hidden = YES;
            self.rightBtn.hidden = NO;
            [self.rightBtn setImage:[UIImage imageNamed:@"eye_image"] forState:UIControlStateSelected];
            [self.rightBtn setImage:[UIImage imageNamed:@"hid_eye_image"] forState:UIControlStateNormal];
            
            self.textFd.placeholder = @"密码";
            self.textFd.secureTextEntry = YES;
            self.textFd.frame = CGRectMake(kLEFT_SPACE, 0.0, kSCREEN_WIDTH - rightview_W - kLEFT_SPACE * 2, contentView_H);
        }
        else if (type == ValidateCodeType)
        {
            self.leftTitleLb.hidden = YES;
//            self.rightBtn.hidden = YES;
//            ValidateCodeView *validatecodeView = [[ValidateCodeView alloc] initWithFrame:self.rightBtn.frame];
//            [self addSubview:validatecodeView];
            self.rightBtn.hidden = NO;
            ValidateCodeView *validatecodeView = [[ValidateCodeView alloc] initWithFrame:CGRectMake(0, 0, self.rightBtn.frame.size.width, self.rightBtn.frame.size.height)];
            [self.rightBtn addSubview:validatecodeView];
            
            self.textFd.placeholder = @"验证码";
            self.textFd.keyboardType = UIKeyboardTypeNumberPad;
            self.textFd.frame = CGRectMake(kLEFT_SPACE, 0.0, kSCREEN_WIDTH - rightview_W - kLEFT_SPACE * 2 , contentView_H);
        }
        
    }
    return self;
}

@end
