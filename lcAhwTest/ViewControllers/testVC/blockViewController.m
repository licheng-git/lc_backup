//
//  blockViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/11/12.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "blockViewController.h"

@implementation blockViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"block";
    
    [self simpleTest];
    
    NSLog(@"testBlockMethod begin");
    NSString *kk = [self testBlockMethod:@"参数" withA:^{
        NSLog(@"A哈哈");
    } andB:^(int x) {
        NSLog(@"B哈哈获得参数%d", x);
    } andC:^NSString *(int x) {
        NSLog(@"C哈哈获得参数%d", x);
        return @"C返回值";
    }];
    NSLog(@"testBlockMethod end");
    NSLog(@"结果：%@", kk);
    
//    testBlockMethod begin
//    vc.method begin
//    A哈哈
//    vc.method blockA
//    B哈哈获得参数101
//    vc.method blockB
//    C哈哈获得参数102
//    vc.method blockC get param:C返回值
//    vc.method blockC
//    vc.method end
//    testBlockMethod end
//    结果：vc.method return
    
}


- (void)simpleTest
{
    void (^kkBlock)(void) = NULL;
    kkBlock = ^(void) {
        NSLog(@"in kkBlock");
    };
    NSLog(@"before kkBlock");
    kkBlock();
    NSLog(@"after kkBlock");  // 结果 before -> in -> after
    
    
    int m = 100;
    int (^kkBlock1)(int a, int b) = NULL;
    kkBlock1 = ^(int a, int b) {
        int c = a + b + m;
        return c;
    };
    NSLog(@"return %d", kkBlock1(20, 3));  // return 123
    NSLog(@"m = %d", m);  // m = 100
    
    
    __block int mm = 100;
    int (^kkBlock2)(int a, int b) = ^(int a, int b) {
        int c = a + b + mm;
        mm = -1;
        return c;
    };
    NSLog(@"return %d", kkBlock2(20, 3));  // return 123
    NSLog(@"mm = %d", mm);  // mm = -1
    
    
    __block UILabel *mmLb = [KUtils createLabelWithFrame:CGRectZero text:@"100" fontSize:0 textAlignment:0 tag:0];  // __block 修饰临时变量，为了更改块外的变量
    __weak UILabel *nnLb__weakSelf = [KUtils createLabelWithFrame:CGRectZero text:@"1000" fontSize:0 textAlignment:0 tag:0];  // __weak 修饰属性 weakSelf.nnLb，为了防止循环引用
    //__block typeof(UILabel) *mmLb1 = ...
    //__weak typeof(UILabel) *nnLb1__weakSelf = ...
    int (^kkBlock3)(int a, int b) = ^(int a, int b) {
        int mm3 = [mmLb.text intValue];
        int nn3 = [nnLb__weakSelf.text intValue];
        int c = a + b + mm3 + nn3;
        mmLb.text = @"-1";
        nnLb__weakSelf.text = @"-2";
        return c;
    };
    NSLog(@"return %d", kkBlock3(20, 3));  // return 1123
    NSLog(@"mmLb.text = %@  ;  nnLb__weakSelf.text = %@", mmLb.text, nnLb__weakSelf.text);  // mmLb.text = -1 ; nnLb__weakSelf.text = -2
    
    //__block ARC下会在block代码块中被retain，MRC下不会
    //__weak 不会在block代码块中被retain
//    __weak typeof(self) weakSelf = self;  // 避免block中循环引用
//    ^{
//        self.testStr = @"可能会循环引用（dealloc不执行 *_*可能）";
//        weakSelf.testStr = @"避免循环引用";
//    };
    
    //可能引起dealloc不执行的情况：block无弱引用weakSelf.property；timer定时器；delegate使用不当retain
}


- (NSString *)testBlockMethod:(NSString *)param withA:(void (^)(void))blockMethod andB:(void (^)(int))blockMethod1 andC:(NSString *(^)(int))blockMethod2
{
    NSLog(@"vc.method begin");
    if (blockMethod)
    {
        blockMethod();
    }
    NSLog(@"vc.method blockA");
    if (blockMethod1)
    {
        blockMethod1(101);
    }
    NSLog(@"vc.method blockB");
    if (blockMethod2)
    {
        NSString *k = blockMethod2(102);
        NSLog(@"vc.method blockC get param:%@", k);
    }
    NSLog(@"vc.method blockC");
    NSLog(@"vc.method end");
    return @"vc.method return";
}

- (NSString *)testBlockMethodXX:(NSString *)param withA:(kkBlock)blockMethod andB:(kkBlock1)blockMethod1 andC:(kkBlock2)blockMethod2
{
    return nil;
}


@end
