//
//  TextCell.h
//  lcAhwTest
//
//  Created by licheng on 15/4/20.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "KUtils.h"
#import "ValidateCodeView.h"


typedef NS_ENUM(NSInteger, TextCellType)
{
//    NeedNoneType = 20,
//    NeedLeftTitleType,           //左边需要title
//    NeedValidateCodeViewType,    //右边带有验证码
//    NeedMsgCodeViewType,         //右边带有手机短信验证码
//    NeedShowPwdViewType          //右边带有显示密码的view
    UserNameType = 20,
    PassWordType,
    ValidateCodeType,
    MsgCodeType
};


@interface TextCell : UITableViewCell

@property (nonatomic, strong) UILabel        *leftTitleLb;
@property (nonatomic, strong) UITextField    *textFd;
@property (nonatomic, strong) UIButton       *rightBtn;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                         type:(TextCellType)type
                     delegate:(id)delegate;


@end
