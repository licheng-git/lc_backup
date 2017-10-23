//
//  CustomTableView.h
//  lcAhwTest
//
//  Created by licheng on 15/5/7.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomLoadView.h"
#import "MJRefresh.h"
#import "KUtils.h"
#import "CustomCell.h"
#import "SettingManager.h"

@protocol CustomTableViewDelegate <NSObject>

// 上拉刷新
@optional
- (void)refreshRequestWithTag:(NSInteger)tag;

// 自定义cell
//@optional
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

// 点击cell
//@optional
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CustomTableView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BottomLoadView *bottomLoadView;
@property (nonatomic, assign) BOOL bIsLastPage;
@property (nonatomic, assign) BOOL bIsNeedBottomLoadView;
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, assign) id<CustomTableViewDelegate> delegate;

// 初始化
- (id)initWithFrame:(CGRect)frame titleArr:(NSArray *)titles tag:(NSInteger)tag;

// tableView加载数据
- (void)reloadTableViewWithDatas:(NSMutableArray *)datas;

// 结束上拉刷新
- (void)endRefresh;

@end
