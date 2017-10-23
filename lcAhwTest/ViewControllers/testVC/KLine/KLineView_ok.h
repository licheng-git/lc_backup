//
//  KLineView_ok.h
//  KLine_lcTest
//
//  Created by apple on 17/2/15.
//  Copyright © 2017年 李诚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLineView_ok : UIView

@property (nonatomic, strong) NSArray *arrEntity;
@property (nonatomic, assign) CGFloat uperChartHeightScale;

- (void)firstDraw;

@end
