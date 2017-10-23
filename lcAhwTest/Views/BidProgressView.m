//
//  BidProgressView.m
//  lcAhwTest
//
//  Created by licheng on 15/6/1.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BidProgressView.h"

@implementation BidProgressView

- (MDRadialProgressView *)createBidProgressView:(CGRect)frame
                                 processCounter:(NSUInteger)processCounter
                                   tenderStatus:(NSString *)tenderStatus;
{
    MDRadialProgressView *bidProgressView = [[MDRadialProgressView alloc] initWithFrame:frame];
    bidProgressView.theme = [MDRadialProgressTheme standardTheme];
    bidProgressView.theme.drawIncompleteArcIfNoProgress = YES;
    bidProgressView.theme.sliceDividerHidden = YES;
    bidProgressView.theme.thickness = 10.0;
    
    if ([KUtils isNullOrEmptyStr:tenderStatus])
    {
        bidProgressView.progressTotal = 100;                 // 百分之 分母
        bidProgressView.progressCounter = processCounter;    // 百分之 分子
        bidProgressView.theme.labelColor = [UIColor orangeColor];
        bidProgressView.theme.completedColor = [UIColor orangeColor];
        bidProgressView.theme.font = [UIFont systemFontOfSize:14];
    }
    else
    {
        bidProgressView.label.text = tenderStatus;
        bidProgressView.theme.labelColor = [UIColor grayColor];
        bidProgressView.theme.completedColor = [UIColor lightGrayColor];
        bidProgressView.theme.font = [UIFont systemFontOfSize:14];
    }
    
    return bidProgressView;
}

@end
