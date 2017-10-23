//
//  BaseTableViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/16.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "BaseTableViewController.h"

@implementation BaseTableViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.bIsNeedBottomLoadView = NO;
        self.bIsLastPage = NO;
        self.bIsNeedDownRefresh = NO;
        
//        self.bIsNeedSectionHeaderFloat = YES;  // table.style为UITableViewStylePlain时 sectionHeaderView是可以漂浮的，若不想漂浮则手动设置为no并设置self.sectionHeaderHeight
        self.tableviewStyle = UITableViewStylePlain;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createTableView];
}


#pragma mark - UITableView Datasource

// section块数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

// section块中的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

// 装载cell数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //cell.property = ...
    return cell;
}

#pragma mark - UITableView Delegate

// cell行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

// section块的header高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001f; // 解决type为group顶部留白问题
}

// section块的footer高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

//// section块的header视图
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//}
//
//// section块的footer视图
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//}

// 点击cell行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//// （table.style为UITableViewStylePlain）滚动时 根据设置使sectionHeaderView不浮动
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (!self.bIsNeedSectionHeaderFloat && self.tableView.style == UITableViewStylePlain)
//    {
//        if (scrollView == self.tableView)
//        {
//            if (scrollView.contentOffset.y <= self.sectionHeaderHeight && scrollView.contentOffset.y >= 0)
//            {
//                scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//            }
//            else if (scrollView.contentOffset.y >= self.sectionHeaderHeight)
//            {
//                scrollView.contentInset = UIEdgeInsetsMake(-self.sectionHeaderHeight, 0, 0, 0);
//            }
//        }
//    }
//}


#pragma mark - Super Method

//// 键盘位置改变  遮住部分往上滚 （实现BaseViewController父类注册的方法）
//- (void)keyboardDidChangeFrame:(NSNotification *)aNotification
//{
//    NSDictionary *info = [aNotification userInfo];
//    CGRect keyboardEndFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat keyboardEndHeight = kSCREEN_HEIGHT - keyboardEndFrame.origin.y;
//    if (keyboardEndHeight <= 0.0)
//    {
//        return;
//    }
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardEndFrame.size.height, 0.0);  // 上、左、下、右
//    _tableView.contentInset = contentInsets;
//    _tableView.scrollIndicatorInsets = contentInsets;
//}

// 键盘出现  遮住部分往上滚 （实现BaseViewController父类注册的方法）
- (void)keyboardDidShow:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGRect keyboardEndFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardEndFrame.size.height, 0.0); // 上、左、下、右
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
}

// 键盘消失  被遮住部分再回去 （实现BaseViewController父类注册的方法）
- (void)keyboardWillHidden:(NSNotification *)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
}

// 结束刷新 上拉和下拉 （实现父类BaseViewController的方法）
- (void)endRefresh
{
    // 上拉
    if ([self.tableView isFooterRefreshing])
    {
        [self.tableView footerEndRefreshing];
    }
    // 下拉
    if ([self.tableView isHeaderRefreshing])
    {
        [self.tableView headerEndRefreshing];
    }
}


#pragma mark - Selector Response Method

// 上拉刷新时触发 （继承类去实现）
- (void)refreshRequest
{
}

// 下拉刷新时触发 （继承类去实现）
- (void)downRefreshRequest
{
}


#pragma mark - Custom Methods

// 创建视图
- (void)createTableView
{
    CGFloat tableviewY = kDEFAULT_ORIGIN_Y;
    CGFloat tableviewH = kSCREEN_HEIGHT - kNAVIGATION_HEIGHT - kSTATUSBAR_HEIGHT -kBOTTOM_HEIGHT;
    CGRect rect = CGRectMake(0.0, tableviewY, kSCREEN_WIDTH, tableviewH);
    //self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView = [[UITableView alloc] initWithFrame:rect style:self.tableviewStyle];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = kBACKGROUND_COLOR;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];  // ios5
    [self.view addSubview:self.tableView];
    
    // 添加上拉刷新
    if (self.bIsNeedBottomLoadView)
    {
        rect = CGRectMake(0.0, 0.0, kSCREEN_WIDTH, BottomLoadViewHeight);
        self.bottomLoadView = [[BottomLoadView alloc] initWithFrame:rect];
        self.tableView.tableFooterView = self.bottomLoadView;
        [self.tableView addFooterWithTarget:self action:@selector(refreshRequest)];
    }
    
    // 添加下拉刷新
    if (self.bIsNeedDownRefresh)
    {
        [self.tableView addHeaderWithTarget:self action:@selector(downRefreshRequest)];
    }
}

// 上拉结束后 不让再拉 的显示
- (void)refreshToLastPageDisplay:(BOOL)noData
{
    //第一页就没有请求到数据
    if (noData)
    {
        self.bottomLoadView.contentLabel.text = BottomLoadViewTextNoData;
    }
    //最后一页，没有请求到数据
    else
    {
        self.bottomLoadView.contentLabel.text = BottomLoadViewTextLastPage;
    }
    self.bottomLoadView.arrowImgView.hidden = YES;
    
    // 再拉时不出现菊花和提示语
    [self.tableView setFooterHidden:YES];
}

@end
