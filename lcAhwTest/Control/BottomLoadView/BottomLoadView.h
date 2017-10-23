//
//  BottomLoadView.h
//  lcAhwTest
//
//  Created by licheng on 15/4/28.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BottomLoadViewHeight        60.0
#define BottomLoadViewTextDrag      @"继续拖动，查看更多"
#define BottomLoadViewTextNoData    @"暂时没有相关记录"
#define BottomLoadViewTextLastPage  @"已经是最后一页"

@interface BottomLoadView : UIView

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *arrowImgView;

@end
