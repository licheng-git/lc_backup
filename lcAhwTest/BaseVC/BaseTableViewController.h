//
//  BaseTableViewController.h
//  lcAhwTest
//
//  Created by licheng on 15/4/16.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "BottomLoadView.h"
#import "MJRefresh.h"

@interface BaseTableViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) BottomLoadView *bottomLoadView;
@property (nonatomic, assign) BOOL bIsNeedBottomLoadView;  // 上拉刷新
@property (nonatomic, assign) BOOL bIsLastPage;            // 上拉刷新 最后一页

@property (nonatomic, assign) BOOL bIsNeedDownRefresh;  // 下拉刷新

// table.style为UITableViewStylePlain时 sectionHeaderView是可以漂浮的，若不想漂浮则手动设置为no并设置self.sectionHeaderHeight（也可以table初始化时style设置为UITableViewStyleGrouped） 
@property (nonatomic, assign) BOOL bIsNeedSectionHeaderFloat;  // sectionHeaderView是否浮动
@property (nonatomic, assign) CGFloat sectionHeaderHeight;  // sectionHeaderView的高度
@property (nonatomic, assign) UITableViewStyle tableviewStyle;

// 上拉结束后 不让再拉 的显示
- (void)refreshToLastPageDisplay:(BOOL)noData;

@end
