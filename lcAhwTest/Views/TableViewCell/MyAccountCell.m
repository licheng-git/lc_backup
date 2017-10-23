//
//  MyAccountCell.m
//  lcAhwTest
//
//  Created by licheng on 15/5/21.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "MyAccountCell.h"
#import "KUtils.h"

@implementation MyAccountCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // 左边标题label
        CGFloat lbH = 20.0;
        CGFloat lbY = (self.contentView.frame.size.height - lbH) / 2;
        CGRect rect = CGRectMake(15.0, lbY, 200, lbH);
        _leftTitleLb = [KUtils createLabelWithFrame:rect
                                              text:nil
                                          fontSize:15.0
                                     textAlignment:NSTextAlignmentLeft
                                               tag:kDEFAULT_TAG];
        [self.contentView addSubview:self.leftTitleLb];
        
        // 右边内容label
        rect = CGRectMake(kSCREEN_WIDTH - 140, lbY, 100, lbH);
        _rightContentLb = [KUtils createLabelWithFrame:rect
                                                 text:nil
                                             fontSize:14.0
                                        textAlignment:NSTextAlignmentRight
                                                  tag:kDEFAULT_TAG];
        _rightContentLb.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_rightContentLb];
        
        // 右边箭头
        UIImage *arrowImg = [UIImage imageNamed:@"account_list_arrow_image"];
        rect = CGRectMake(kSCREEN_WIDTH - 30.0,
                          (self.contentView.frame.size.height - arrowImg.size.height) / 2,
                          arrowImg.size.width,
                          arrowImg.size.height);
        UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:rect];
        arrowImgView.image = arrowImg;
        [self.contentView addSubview:arrowImgView];
        
    }
    return self;
}

@end
