//
//  table1VC.m
//  lcAhwTest
//
//  Created by licheng on 15/8/13.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "table1VC.h"

@interface table1VC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation table1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"err 包含UITableView";
    self.view.backgroundColor = [UIColor yellowColor];
    UILabel *lb = [KUtils createLabelWithFrame:CGRectMake(10, 10, 200, 30) text:@"包含UITableView" fontSize:14 textAlignment:NSTextAlignmentLeft tag:0];
    [self.view addSubview:lb];
    
    CGRect rect = CGRectMake(0.0, kDEFAULT_ORIGIN_Y, kSCREEN_WIDTH, kSCREEN_HEIGHT - kNAVIGATION_HEIGHT - kSTATUSBAR_HEIGHT -kBOTTOM_HEIGHT);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor redColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
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
