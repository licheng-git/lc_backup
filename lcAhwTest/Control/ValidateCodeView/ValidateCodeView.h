//
//  ValidateCodeView.h
//  lcAhwTest
//
//  Created by licheng on 15/6/10.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ValidateCodeView : UIView

@property (nonatomic, strong) NSMutableString *codeString;

- (void)change;

@end
