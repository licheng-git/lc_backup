//
//  PicAndTextActionSheet.h
//  ActionSheetExtension
//
//  Created by yixiang on 15/7/6.
//  Copyright (c) 2015年 yixiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetItemCell.h"

@protocol ActionSheetExtDelegate <NSObject>

-(void)ActionSheetExtDidSelectIndex : (NSInteger) index;

@end

@interface ActionSheetExt : UIView

@property (nonatomic , strong) id<ActionSheetExtDelegate> delegate;

-(id)initWithList : (NSArray *)list title : (NSString *) title;

-(void) showInView : (UIViewController *)controller;

@end
