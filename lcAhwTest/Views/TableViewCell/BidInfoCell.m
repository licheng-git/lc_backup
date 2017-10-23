//
//  BidInfoCell.m
//  lcAhwTest
//
//  Created by licheng on 15/4/17.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BidInfoCell.h"

@implementation BidInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = kBACKGROUND_COLOR;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        // 背景view
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSCREEN_WIDTH, BIDCELL_H - 10)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        
        // 标的类型
        self.bidTypeImgView = [[UIImageView alloc] init];
        self.bidTypeImgView.frame = CGRectMake(10.0, 5.0, 20.0, 20.0);
        [bgView addSubview:self.bidTypeImgView];
        
        CGFloat space = 5.0;
        // 标的代码
        CGFloat bidCodeLbX = CGRectGetMaxX(self.bidTypeImgView.frame) + space;
        CGFloat bidCodeLbY = CGRectGetMinY(self.bidTypeImgView.frame);
        CGFloat bidCodeLbW = 150.0;
        CGFloat bidCodeLbH = CGRectGetHeight(self.bidTypeImgView.frame);
        self.bidCodeLb = [[UILabel alloc] initWithFrame:CGRectMake(bidCodeLbX, bidCodeLbY, bidCodeLbW, bidCodeLbH)];
        self.bidCodeLb.backgroundColor = [UIColor whiteColor];
        [bgView addSubview:_bidCodeLb];
        
        
        CGFloat titleW = 60.0;
        CGFloat titleH = 20.0;
        CGFloat titleW_amt = 110.0;
        // 金额title
        UILabel *amtTitle = [self createTitleLable];
        amtTitle.text = @"金额";
        CGFloat amtTitleX = CGRectGetMinX(self.bidTypeImgView.frame) + space;
        CGFloat amtTitleY = CGRectGetMaxY(self.bidTypeImgView.frame) + space;
        amtTitle.frame = CGRectMake(amtTitleX, amtTitleY, titleW_amt, titleH);
        [bgView addSubview:amtTitle];
        // 金额
        self.bidAmountLb = [self createContentLable];
        self.bidAmountLb.frame = CGRectMake(amtTitleX,
                                            amtTitleY + titleH + space,
                                            titleW_amt,
                                            titleH);
        [bgView addSubview:self.bidAmountLb];
        
        // 年利率title
        UILabel *rateTitle = [self createTitleLable];
        rateTitle.text = @"年利率";
        rateTitle.frame = CGRectMake(CGRectGetMaxX(amtTitle.frame),
                                     amtTitleY,
                                     titleW,
                                     titleH);
        [bgView addSubview:rateTitle];
        // 年利率
        self.bidRateLb = [self createContentLable];
        self.bidRateLb.frame = CGRectMake(CGRectGetMinX(rateTitle.frame),
                                          CGRectGetMaxY(rateTitle.frame) + space,
                                          titleW,
                                          titleH);
        [bgView addSubview:self.bidRateLb];
        
        // 期限title
        UILabel *datelimitTitle = [self createTitleLable];
        datelimitTitle.text = @"期限";
        datelimitTitle.frame = CGRectMake(CGRectGetMaxX(rateTitle.frame),
                                          amtTitleY,
                                          titleW,
                                          titleH);
        [bgView addSubview:datelimitTitle];
        // 期限
        self.bidDatelimitLb = [self createContentLable];
        self.bidDatelimitLb.frame = CGRectMake(CGRectGetMinX(datelimitTitle.frame),
                                               CGRectGetMaxY(datelimitTitle.frame) + space,
                                               titleW,
                                               titleH);
        [bgView addSubview:self.bidDatelimitLb];
        
        // 投标进度
        CGFloat bidProgressView_W = 50.0;
        CGFloat bidProgressView_H = bidProgressView_W;
        CGFloat bidProgressView_X = kSCREEN_WIDTH - bidProgressView_W -10;
        CGFloat bidProgressView_Y = (bgView.frame.size.height - bidProgressView_H) / 2;
        self.bidProgressView = [[MDRadialProgressView alloc] initWithFrame:CGRectMake(bidProgressView_X, bidProgressView_Y, bidProgressView_W, bidProgressView_H)];
        self.bidProgressView.theme = [MDRadialProgressTheme standardTheme];
        self.bidProgressView.progressTotal = 100;    // 百分之 分母
        self.bidProgressView.progressCounter = 0;    // 百分之 分子
        self.bidProgressView.theme.drawIncompleteArcIfNoProgress = YES;
        self.bidProgressView.theme.sliceDividerHidden = YES;
        self.bidProgressView.theme.thickness = 10.0;
        self.bidProgressView.theme.labelColor = [UIColor orangeColor];
        self.bidProgressView.theme.completedColor = [UIColor orangeColor];
        self.bidProgressView.theme.font = [UIFont systemFontOfSize:14];
        [bgView addSubview:self.bidProgressView];
    }
    return self;
}

// 创建标题
- (UILabel *)createTitleLable
{
    UILabel *titleLb = [[UILabel alloc] init];
    titleLb.font = [UIFont systemFontOfSize:14.0];
    titleLb.backgroundColor = [UIColor whiteColor];
    titleLb.textColor = [UIColor lightGrayColor];
    titleLb.textAlignment = NSTextAlignmentLeft;
    return titleLb;
}

// 创建内容
- (UILabel *)createContentLable
{
    UILabel *contentLb = [[UILabel alloc] init];
    contentLb.font = [UIFont systemFontOfSize:16];
    contentLb.backgroundColor = [UIColor whiteColor];
    contentLb.textColor = [UIColor orangeColor];
    contentLb.textAlignment = NSTextAlignmentLeft;
    return contentLb;
}

// 显示数据
- (void)showData:(BidData *)data
{
    UIImage *bidTypeImg = nil;
    if ([data.productName isEqualToString:@"01"])
    {
        bidTypeImg = [UIImage imageNamed:@"type_boss_image"]; // 老板贷
    }
    else if ([data.productName isEqualToString:@"02"])
    {
        bidTypeImg = [UIImage imageNamed:@"type_salary_image"]; // 业主贷
    }
    else
    {
        bidTypeImg = [UIImage imageNamed:@"type_salary_image"]; // 薪贷
    }
    self.bidTypeImgView.image = bidTypeImg;
    self.bidCodeLb.text = data.ZAContractCode;
    self.bidAmountLb.text = data.total;
    self.bidRateLb.text = data.rate;
    self.bidDatelimitLb.text = data.dateLimit;
    self.bidProgressView.progressCounter = data.schedule * 100;
    self.bidProgressView.label.text = [NSString stringWithFormat:@"%i%%", (int)(data.schedule * 100)];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
