//
//  InvestPageController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/9.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "InvestPageController.h"

@interface InvestPageController ()
@property (nonatomic, strong) NSMutableArray *bidDataList;
@property (nonatomic, assign) NSInteger      currentSegmentIndex;
@end

#define HeaderView_H  60.0

@implementation InvestPageController

- (instancetype)init
{
    if (self = [super init])
    {
        self.title = @"我要投资";
        self.bIsNeedDownRefresh = YES;
        self.bIsNeedBottomLoadView = YES;
        self.bIsLastPage = NO;
        self.bidDataList = [[NSMutableArray alloc] init];
        self.currentSegmentIndex = 0;
        
//        self.bIsNeedSectionHeaderFloat = NO;
//        self.sectionHeaderHeight = HeaderView_H;
        //self.tableviewStyle = UITableViewStyleGrouped;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.bidDataList || self.bidDataList.count <= 0)
    {
        [self sendBidDataListRequest];
    }
}

// 发送请求获取数据
- (void)sendBidDataListRequest
{
    BidDataList *investData = [[BidDataList alloc] initWithRequestType:BIDINVESTLIST_TYPE];
    [self requestWithData:investData
                  success:^(id responseData){
                      
                      NSArray *tempArr = ((BidDataList *)responseData).bidDataList;
                      if ([KUtils isNullOrEmptyArr:tempArr])
                      {
                          // 请求没有数据了，则已经是最后一页了
                          self.bIsLastPage = YES;
                          
                          // 此时再拉的效果
                          BOOL noData = self.bidDataList ? YES : NO;
                          [self refreshToLastPageDisplay:noData];
                          
                          return;
                      }
                      
                      // 请求有数据，则不是最后一页
                      self.bIsLastPage = NO;
                      if ([SettingManager shareInstance].invest_page == kDefaultPageNum)
                      {
                          self.bidDataList = [NSMutableArray arrayWithArray:tempArr];
                      }
                      else
                      {
                          [self.bidDataList addObjectsFromArray:tempArr];
                      }
                      
                      [self.tableView reloadData];
                      
                      // tableView定位到行
                      //[self.tableView scrollToRowAtIndexPath:0 atScrollPosition:UITableViewScrollPositionNone animated:NO];
                      
                  }
                   failed:^(id error){}];
}

// 创建视图
- (void)createView
{
    //self.tableView.tableHeaderView = [self createHeaderView];  //*_* 放这没法一起滚
    
    self.navLeftBarItemView.barImgView.image = [UIImage imageNamed:@"invest_introduce_image"];
    self.navRightBarItemView.barImgView.image = [UIImage imageNamed:@"invest_caculator_image"];
}

// 创建tableView的headerView
- (UIView *)createHeaderView
{
    CGRect rect = CGRectMake(0.0, 0.0, kSCREEN_WIDTH, HeaderView_H);
    UIView *headerView = [[UIView alloc] initWithFrame:rect];
    headerView.backgroundColor = kBACKGROUND_COLOR;
    
    NSArray *arr = @[@"按时间", @"按期限", @"按利率"];
    CGFloat segmentW = 190.0;
    CGFloat segmentH = 28.0;
    CGFloat segmentX = (headerView.frame.size.width - segmentW) / 2;
    CGFloat segmentY = (HeaderView_H - segmentH) / 2;
    rect = CGRectMake(segmentX, segmentY, segmentW, segmentH);
//    UISegmentedControl *segmentC = [[UISegmentedControl alloc] initWithItems:arr];
//    segmentC.frame = rect;
//    //[segmentC addTarget:self action:@selector(segmentControlClick:) forControlEvents:UIControlEventValueChanged];
//    segmentC.backgroundColor = [UIColor clearColor];
//    segmentC.tintColor = [UIColor lightGrayColor];
//    segmentC.selectedSegmentIndex = 0;
//    NSDictionary *dicAttr = [NSDictionary dictionaryWithObjectsAndKeys: [UIColor redColor], NSForegroundColorAttributeName, nil];
//    [segmentC setTitleTextAttributes:dicAttr forState:UIControlStateNormal];
//    NSDictionary *dicAttr1 = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:15] ,NSFontAttributeName, nil];
//    [segmentC setTitleTextAttributes:dicAttr1 forState:UIControlStateSelected];
//    [headerView addSubview:segmentC];
    RFSegmentView *segmentView = [[RFSegmentView alloc] initWithFrame:rect items:arr];
    segmentView.delegate = self;
    segmentView.center = CGPointMake(CGRectGetMidX(headerView.frame), CGRectGetMidY(headerView.frame));
    segmentView.selectedIndex = self.currentSegmentIndex; // *_* [self.tableView reloadData]
    [headerView addSubview:segmentView];
    return headerView;
}


#pragma mark - UITableView DataSource + Delegate
// UITableView 返回块数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// UITableView 返回section块高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HeaderView_H;
}

// UITableView 返回section块的view  *_*（table.style为UITableViewStylePlain）可以一起滚
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self createHeaderView];
}

// UITableView 返回块中的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.bidDataList && self.bidDataList.count > 0)
    {
        return self.bidDataList.count;
    }
    else
    {
        return 0;
    }
}

// UITableView 装载数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    BidInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[BidInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    BidData *data = [self.bidDataList objectAtIndex:indexPath.row];
    [cell showData:data];
    
    return cell;
}

// UITableView 返回行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return BIDCELL_H;
}

// UITableView 点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BidData *biddata = [self.bidDataList objectAtIndex:indexPath.row];
    [SettingManager shareInstance].bidID = biddata.Id;
    InvestDetailViewController *investDetailVC = [[InvestDetailViewController alloc] init];
    [self.tabBarController.navigationController pushViewController:investDetailVC animated:YES];
}


// 上拉刷新
- (void)refreshRequest
{
    if (!self.bIsLastPage)
    {
        ([SettingManager shareInstance].invest_page)++;
        [self sendBidDataListRequest];
    }
}

// 下拉刷新
- (void)downRefreshRequest
{
    [SettingManager shareInstance].invest_page = kDefaultPageNum;
    [self sendBidDataListRequest];
}


// RFSegmentViewDelegate 点击切换
- (void)segmentViewSelectIndex:(NSInteger)index
{
    if (self.currentSegmentIndex == index)
    {
        return;
    }
    self.currentSegmentIndex = index;
    // 切换排序方式，就重新从第一页开始请求
    [SettingManager shareInstance].invest_page = kDefaultPageNum;
    self.bidDataList = [[NSMutableArray alloc] init];
    switch (index)
    {
        case 0:
        {
            [SettingManager shareInstance].invest_sortItem = Invest_SortItem_AuditDateKey;
            break;
        }
        case 1:
        {
            [SettingManager shareInstance].invest_sortItem = Invest_SortItem_DateLimitKey;
            break;
        }
        case 2:
        {
            [SettingManager shareInstance].invest_sortItem = Invest_SortItem_RateKey;
            break;
        }
        default:
        {
            break;
        }
    }
    [self sendBidDataListRequest];
}

//// SegmentControl 点击切换
//- (void)segmentControlClick:(UISegmentedControl *)sender
//{
//    NSInteger index = sender.selectedSegmentIndex;
//    
//}


// NavBarItemViewDelegate
- (void)clickNavBarItemView:(NavBarItemView *)navBarItemView navBarType:(NavBarType)type
{
}



@end
