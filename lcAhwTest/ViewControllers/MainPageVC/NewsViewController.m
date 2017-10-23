//
//  NewsViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/27.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "NewsViewController.h"

@interface NewsViewController ()

@end

@implementation NewsViewController

static const NSInteger kSpace = 10+5;
static NSInteger kSpace1 = 15;
const NSInteger kSpace2 = 15;
int kSpace3 = 15;
int kk = 10;
// *_* 全局变量为什么不报错？

- (instancetype)init
{
    NSLog(@"1.init");
    self = [super init];
    return self;
}

- (void)loadView
{
    [super loadView]; // *_*
    NSLog(@"2.loadView");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"3.viewDidLoad");
    self.title = @"网贷新闻";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"4.viewWillAppear");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"5.viewDidAppear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"6.viewWillDisappear");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"7.viewDidDisappear");
}


//- (void)viewWillUnload
//{
//    [super viewWillUnload];
//    NSLog(@"8.viewWillUnload");
//}
//
//- (void)viewDidUnload
//{
//    [super viewDidUnload];
//    NSLog(@"9.viewDidUnload");
//}


- (void)dealloc
{
    NSLog(@"10.dealloc");
}


@end
