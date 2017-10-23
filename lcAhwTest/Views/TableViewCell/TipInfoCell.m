//
//  InvestTableViewCell.m
//  lcAhwTest
//
//  Created by licheng on 15/4/16.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "TipInfoCell.h"
#import "Constants.h"
#import "KUtils.h"

@implementation TipInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // 背景View
        CGFloat investcellH = 92.0;
        CGFloat horSpace = 10.0;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSCREEN_WIDTH, investcellH - horSpace)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        
        // 标题
        CGRect rect = CGRectMake(15.0, 20.0, kSCREEN_WIDTH, 20.0);
        self.titleLb = [KUtils createLabelWithFrame:rect
                                              text:nil
                                          fontSize:16.0
                                     textAlignment:NSTextAlignmentLeft
                                               tag:0];
        [self.titleLb setTextColor:[UIColor blackColor]];
        [bgView addSubview:self.titleLb];
        
        // 内容
        CGFloat verticalSpace = 10.0;
        rect.origin.y = CGRectGetMaxY(self.titleLb.frame) + verticalSpace;
        self.contentLb = [KUtils createLabelWithFrame:rect
                                                text:@""
                                            fontSize:14.0
                                       textAlignment:NSTextAlignmentLeft
                                                 tag:0];
        [self.contentLb setTextColor:[UIColor lightGrayColor]];
        [bgView addSubview:self.contentLb];
        
        // 箭头图片
        UIImage *img = [UIImage imageNamed:@"mainpage_arrow_image"];
        CGFloat imgX = kSCREEN_WIDTH - horSpace - img.size.width;
        CGFloat imgY = (CGRectGetHeight(bgView.frame) - img.size.height) / 2;
        rect = CGRectMake(imgX, imgY, img.size.width, img.size.height);
        self.arrowImgV = [[UIImageView alloc] initWithFrame:rect];
        [self.arrowImgV setImage:img];
        [bgView addSubview:self.arrowImgV];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
