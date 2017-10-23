//
//  UITextView+lc.h
//  lcAhwTest
//
//  Created by licheng on 16/6/27.
//  Copyright © 2016年 lc. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UITextView (lc)

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, assign) CGFloat  temp_TextHeight;
- (CGFloat)textHeight;

@end


// *_*添加属性还是用继承比较好
// *_*类别如果重写了本身的方法会影响全局 （重写了delloc系统方法）

