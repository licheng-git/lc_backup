//
//  DialogView.h
//  lcAhwTest
//
//  Created by licheng on 15/6/11.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogView : UIView

@property (nonatomic, strong) UIView *containerView;

- (id)initWithContainerFrame:(CGRect)frame;
- (void)show;
- (void)close;

@end
