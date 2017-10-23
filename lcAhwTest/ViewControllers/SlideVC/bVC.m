//
//  bVC.m
//  lcAhwTest
//
//  Created by licheng on 15/6/30.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "bVC.h"

@interface bVC ()

@end

@implementation bVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"b";
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBarHidden = YES;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(kSCREEN_WIDTH/2, 200, 50, 30);
    [btn setTitle:@"b.test" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.cornerRadius = 5.0;
    btn.tag = kDEFAULT_TAG;
    [self.view addSubview:btn];
}

- (void)test:(UIButton *)btn
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"b.test"
                                                        message:@"b.msg"
                                                       delegate:self
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:@"others", nil];
    [alertView show];
}

@end
