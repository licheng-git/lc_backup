//
//  HMBannerView.h
//  lcAhwTest
//
//  Created by licheng on 15/4/16.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "Constants.h"

typedef NS_ENUM(NSInteger, BannerViewScrollDirection)
{
    ScrollDirectionLandscape,    // 水平滚动
    ScrollDirectionPortait       // 垂直滚动
};

@protocol HMBannerViewDelegate;

@interface HMBannerView : UIView<UIScrollViewDelegate>

@property (nonatomic, assign) id<HMBannerViewDelegate> bDelegate;
@property (nonatomic, assign) NSTimeInterval rollingDelayTime;

- (id)initWithFrame:(CGRect)frame scrollDirection:(BannerViewScrollDirection)direction images:(NSArray *)images;

@end


@protocol HMBannerViewDelegate <NSObject>

@optional
- (void)bannerView:(HMBannerView *)bannerView didSelectImageView:(NSInteger)index;

@end
