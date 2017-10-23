//
//  normalVC.m
//  lcAhwTest
//
//  Created by licheng on 15/8/13.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "normalVC.h"

@interface normalVC ()

@end

@implementation normalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"ok 无UITableView";
    self.view.backgroundColor = [UIColor greenColor];
    UILabel *lb = [KUtils createLabelWithFrame:CGRectMake(10, kDEFAULT_ORIGIN_Y + 10, 200, 30) text:@"无UITableView" fontSize:14 textAlignment:NSTextAlignmentLeft tag:0];
    [self.view addSubview:lb];
    
    //[self.containerTabBarC.navigationController pushViewController:(UIViewController *) animated:(BOOL)];
}

@end
