//
//  blockViewController.h
//  lcAhwTest
//
//  Created by licheng on 15/11/12.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "BaseViewController.h"

@interface blockViewController : BaseViewController
{
    void (^_pauseBlock)(void);
    void (^_closeBlock)();
}

- (void)simpleTest;


typedef void (^kkBlock)(void);
typedef void (^kkBlock1)(int x);
typedef NSString *(^kkBlock2)(int x);

- (NSString *)testBlockMethodXX:(NSString *)param
                          withA:(kkBlock)blockMethod
                           andB:(kkBlock1)blockMethod1
                           andC:(kkBlock2)blockMethod2;

- (NSString *)testBlockMethod:(NSString *)param
                        withA:(void (^)(void))blockMethod
                         andB:(void (^)(int x))blockMethod1
                         andC:(NSString *(^)(int x))blockMethod2;

@property (nonatomic, strong) kkBlock b;
@property (nonatomic, strong) NSString *(^b2)(int x);

//@property (nonatomic) void (^onButtonTouchUpInside)(CustomIOSAlertView *alertView, int buttonIndex);
//- (void)setOnButtonTouchUpInside:(void (^)(CustomIOSAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

@end
