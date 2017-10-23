//
//  BidProgressView.h
//  lcAhwTest
//
//  Created by licheng on 15/6/1.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"
#import "KUtils.h"

@interface BidProgressView : UIView

// 标的借款进度
- (MDRadialProgressView *)createBidProgressView:(CGRect)frame
                                 processCounter:(NSUInteger)processCounter
                                   tenderStatus:(NSString *)tenderStatus;

@end
