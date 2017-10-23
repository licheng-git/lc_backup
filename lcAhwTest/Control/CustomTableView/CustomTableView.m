//
//  CustomTableView.m
//  lcAhwTest
//
//  Created by licheng on 15/5/7.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "CustomTableView.h"

//#define CustomCellSectionHeight 24.0
#define TableViewHeaderHeight 24.0

@implementation CustomTableView

- (id)initWithFrame:(CGRect)frame titleArr:(NSArray *)titles tag:(NSInteger)tag
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.bIsLastPage = NO;
        self.bIsNeedBottomLoadView = YES;
        self.titleArr = titles;
        self.tag = tag;
        self.datas = [[NSMutableArray alloc] init];
        
        // 创建视图 tableview
        CGRect rect = self.bounds;
        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        
        // 创建_tableView列标题
        [self createTableHeaderView];
        
        // 添加 "继续拖动..." 上拉刷新
        if (self.bIsNeedBottomLoadView)
        {
            rect = CGRectMake(0.0, 0.0, kSCREEN_WIDTH, BottomLoadViewHeight);
            _bottomLoadView = [[BottomLoadView alloc] initWithFrame:rect];
            _tableView.tableFooterView = _bottomLoadView;
            [_tableView addFooterWithTarget:self action:@selector(refreshRequest)];
        }
    }
    return self;
}

#pragma mark - UITableView Datasource + Delegate

// section块数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// section块中的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.datas && self.datas.count > 0)
    {
        _tableView.tableHeaderView.hidden = NO;
        return self.datas.count;
    }
    else
    {
        _tableView.tableHeaderView.hidden = YES;
        return 0;
    }
}

//// 每个section块的headerView高度
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (self.datas && self.datas.count>0)
//    {
//        return CustomCellSectionHeaderHeight;
//    }
//    else
//    {
//        return (1.0e-6f); //浮点数0
//    }
//}

// 装载cell数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSArray *data = [self.datas objectAtIndex:indexPath.row];
    if (!cell)
    {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier data:data];
    }
    
    return cell;
}

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CustomCellHeight;
}

// 点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - custom method

// 创建列标题
- (void)createTableHeaderView
{
    if (!(self.titleArr && self.titleArr.count>0))
    {
        return;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, _tableView.frame.size.width, TableViewHeaderHeight);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor whiteColor];
    
    // 宽度平均分
    CGFloat titleLbW = view.frame.size.width / self.titleArr.count;
    CGFloat titleLbH = TableViewHeaderHeight;
    for (int i=0; i<self.titleArr.count; i++)
    {
        rect = CGRectMake(titleLbW * i, 0.0, titleLbW, titleLbH);
        UILabel *titleLb = [KUtils createLabelWithFrame:rect
                                                  text:[self.titleArr objectAtIndex:i]
                                              fontSize:14.0f
                                         textAlignment:NSTextAlignmentCenter
                                                   tag:kDEFAULT_TAG];
        titleLb.textColor = [UIColor lightGrayColor];
        [view addSubview:titleLb];
    }
    
    _tableView.tableHeaderView = view;
}

// 加载数据
//- (void)setDatas:(NSMutableArray *)datas
//{
//    self.datas = datas;
//    [_tableView reloadData];
//}
- (void)reloadTableViewWithDatas:(NSMutableArray *)pageDatas
{
    if ([KUtils isNullOrEmptyArr:pageDatas])
    {
        // 请求没有数据了，则已经是最后一页了
        self.bIsLastPage = YES;
        
        // 此时再拉的效果
        BOOL noData = [KUtils isNullOrEmptyArr:self.datas] ? YES : NO;
        [self refreshToLastPageDisplay:noData];
        
        return;
    }
    
    // 请求有数据，则不是最后一页
    self.bIsLastPage = NO;
//    if (? == kDefaultPageNum)  // 上拉刷新追加数据，下拉刷新只显示最新数据
//    {
//        self.datas = [[NSMutableArray alloc] initWithArray:pageDatas];
//    }
//    else
    {
        [self.datas addObjectsFromArray:pageDatas];
    }
    
    // 加载数据
    [_tableView reloadData];
}


// 上拉刷新时触发
- (void)refreshRequest
{
    if (!self.bIsLastPage)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshRequestWithTag:)])
        {
            [self.delegate refreshRequestWithTag:self.tag];
        }
    }
}

// 结束上拉刷新
- (void)endRefresh
{
    if ([self.tableView isFooterRefreshing])
    {
        [self.tableView footerEndRefreshing];
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
