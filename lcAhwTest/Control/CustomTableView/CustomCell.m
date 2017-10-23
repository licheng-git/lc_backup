//
//  CustomCell.m
//  lcAhwTest
//
//  Created by licheng on 15/5/7.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "CustomCell.h"
#import "KUtils.h"

@implementation CustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(NSArray *)data
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self && ![KUtils isNullOrEmptyArr:data])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat lbW = kSCREEN_WIDTH / data.count;
        for (int i=0; i<data.count; i++)
        {
            CGRect rect = CGRectMake(lbW * i, 0.0, lbW, CustomCellHeight);
            NSString *text = [data objectAtIndex:i];
            UILabel *lb = [KUtils createLabelWithFrame:rect
                                                 text:text
                                             fontSize:14.0
                                        textAlignment:NSTextAlignmentCenter
                                                  tag:kDEFAULT_TAG + i];
            lb.textColor = [UIColor lightGrayColor];
            [self addSubview:lb];
        }
    }
    return self;
}

@end
