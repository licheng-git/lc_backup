//
//  BidInfoCell.h
//  lcAhwTest
//
//  Created by licheng on 15/4/17.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "HomeData.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"
#import "KUtils.h"

#define BIDCELL_H    92.0

@interface BidInfoCell : UITableViewCell

@property (nonatomic, strong) UIImageView   *bidTypeImgView;  // 标的类型
@property (nonatomic, strong) UILabel       *bidCodeLb;       // 标的代码
@property (nonatomic, strong) UILabel       *bidAmountLb;     // 金额
@property (nonatomic, strong) UILabel       *bidRateLb;       // 年利率
@property (nonatomic, strong) UILabel       *bidDatelimitLb;  // 期限
//@property (nonatomic, strong) UIView        *bidProgressView; // 投标进度
@property (nonatomic, strong) MDRadialProgressView *bidProgressView;

// 显示数据
- (void)showData:(BidData *)data;

@end
