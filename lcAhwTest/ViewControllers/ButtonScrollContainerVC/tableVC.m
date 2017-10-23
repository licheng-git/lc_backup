//
//  tableVC.m
//  lcAhwTest
//
//  Created by licheng on 15/8/13.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "tableVC.h"
#import "KUtils.h"

@interface tableVC ()

@end

@implementation tableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ok 继承UITableView";
    self.view.backgroundColor = [UIColor orangeColor];
    UILabel *lb = [KUtils createLabelWithFrame:CGRectMake(10, 10, 200, 30) text:@"继承UITableView" fontSize:14 textAlignment:NSTextAlignmentLeft tag:0];
    [self.view addSubview:lb];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end
