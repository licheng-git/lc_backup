//
//  BottomLoadView.m
//  lcAhwTest
//
//  Created by licheng on 15/4/28.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BottomLoadView.h"
#import "Constants.h"
#import "KUtils.h"

@implementation BottomLoadView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        // 箭头图片
        UIImage *arrowImg = [UIImage imageNamed:@"arrow_bottom_image"];
        CGFloat arrowImgView_X = (kSCREEN_WIDTH - arrowImg.size.width) / 2;
        CGFloat arrowImgView_Y = 10.0;
        CGRect rect = CGRectMake(arrowImgView_X, arrowImgView_Y, arrowImg.size.width, arrowImg.size.height);
        self.arrowImgView = [[UIImageView alloc] initWithFrame:rect];
        self.arrowImgView.image = arrowImg;
        [self addSubview:self.arrowImgView];
        
        // 显示文字
        CGFloat contentLabel_W = 160.0;
        CGFloat contentLabel_H = 20.0;
        CGFloat contentLabel_X = (kSCREEN_WIDTH - contentLabel_W) / 2;
        CGFloat contentLabel_Y = CGRectGetMaxY(self.arrowImgView.frame);
        rect = CGRectMake(contentLabel_X, contentLabel_Y, contentLabel_W, contentLabel_H);
        self.contentLabel = [KUtils createLabelWithFrame:rect
                                                   text:BottomLoadViewTextDrag
                                               fontSize:14
                                          textAlignment:NSTextAlignmentCenter
                                                    tag:kDEFAULT_TAG];
        self.contentLabel.center = CGPointMake(CGRectGetMidX(self.arrowImgView.frame), CGRectGetMidY(self.contentLabel.frame));
        self.contentLabel.backgroundColor = [UIColor whiteColor];
        self.contentLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:self.contentLabel];
        
        // 分割线
        rect = CGRectMake(0.0, CGRectGetMidY(self.contentLabel.frame), kSCREEN_WIDTH, 0.5);
        UIImageView *line = [[UIImageView alloc] initWithFrame:rect];
        line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:line];
        
        [self insertSubview:self.contentLabel aboveSubview:line];
        
    }
    return self;
}

@end
