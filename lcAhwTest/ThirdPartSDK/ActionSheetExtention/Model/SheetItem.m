//
//  Item.m
//  ActionSheetExtension
//
//  Created by yixiang on 15/7/6.
//  Copyright (c) 2015年 yixiang. All rights reserved.
//

#import "SheetItem.h"

@implementation SheetItem

- (id)initWithTitle:(NSString *)title icon:(NSString *)icon
{
    self = [super init];
    if (self)
    {
        self.title = title;
        self.icon = icon;
    }
    return self;
}

@end
