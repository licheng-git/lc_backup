//
//  MainPageController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/9.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "MainPageController.h"

// 设置类型
typedef NS_ENUM(NSInteger, InvestListViewItemType)
{
    Invest_NewestProType = 150,    // 最新项目类型
    Invest_BidType,                // 散标投资类型
};

@interface MainPageController ()
{
    NSMutableArray    *_dataTypeArray;
    
//    HomeDataList  *_homeDataList;  // arc
}
@property (nonatomic, strong) HomeDataList *homeDataList;  // arc和mrc都可
@end


@implementation MainPageController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.title = @"首页";
        self.bIsNeedDownRefresh = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 发送请求获取数据
    //[self sendGetHomeListDataRequest];
    
    // 创建视图
    [self createView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.homeDataList)
    {
        [self sendGetHomeListDataRequest];
    }
}

// 请求首页信息
- (void)sendGetHomeListDataRequest
{
    HomeDataList *listdata = [[HomeDataList alloc] initWithRequestType:HOMELISTINFO_TYPE];
    
    [self requestWithData:listdata
                  success:^(id responseData){
                      
                      if (!responseData || [responseData isKindOfClass:[NSNull class]])
                      {
                          return;
                      }
                      //_homeDataList = [((HomeDataList *)responseData) retain];  // mrc
                      self.homeDataList = (HomeDataList *)responseData;
                      self.tableView.tableHeaderView = [self createTableHeaderView];
                      [self setDataTypeArray];
                      [self.tableView reloadData];
                      
                      // 保存联系电话，联系电话，产品介绍url等
                  }
                   failed:^(id error){}];
}


// 创建视图
- (void)createView
{
    self.navLeftBarItemView.barImgView.image = [UIImage imageNamed:@"mainpage_bell_image"];
    self.navRightBarItemView.barImgView.image = [UIImage imageNamed:@"mainpage_more_image"];
    //self.navRightBarItemView.barLabel.text = @"#_#";
    
//    self.tableView.tableHeaderView = [self headerViewOfTableView];
}

//  创建tableView的headerView
- (UIView *)createTableHeaderView
{
    CGFloat headerHeight = 154.0;
    CGRect rect = CGRectMake(0.0, 0.0, kSCREEN_WIDTH, headerHeight);
    UIView *headerView = [[UIView alloc] initWithFrame:rect];
    headerView.backgroundColor = kBACKGROUND_COLOR;
    
    // 广告图
    CGFloat bannerHeight = 130.0;
    rect.size.height = bannerHeight;
    //NSArray *images = [self getBannerImage]; // *_* 真机下载图片速度太慢，导致卡死
    //HMBannerView *bannerView = [[HMBannerView alloc] initWithFrame:rect scrollDirection:0 images:images];
    NSMutableArray *imagesUrl = [[NSMutableArray alloc] init];
    for (BannerData *bannerData in self.homeDataList.bannerDataList)
    {
        [imagesUrl addObject:bannerData.imgUrl];
    }
    HMBannerView *bannerView = [[HMBannerView alloc] initWithFrame:rect scrollDirection:ScrollDirectionLandscape images:imagesUrl];
    bannerView.bDelegate = self; // 点击图片打开wap链接
    bannerView.rollingDelayTime = 3.0;
    [headerView addSubview:bannerView];
    
    // 最新项目label
    CGFloat lbX = 24.0;
    CGFloat lbY = CGRectGetMaxY(bannerView.frame);
    CGFloat lbW = kSCREEN_WIDTH - lbX;
    CGFloat lbH = headerHeight - bannerHeight;
    rect = CGRectMake(lbX, lbY, lbW, lbH);
    UILabel *newestLb = [KUtils createLabelWithFrame:rect
                                               text:@"最新项目"
                                           fontSize:16.0f
                                      textAlignment:NSTextAlignmentLeft
                                                tag:0];
    [newestLb setBackgroundColor:kBACKGROUND_COLOR];
    [headerView addSubview:newestLb];
    
    return headerView;
}

// 获取banner图片数组
- (NSArray *)getBannerImage
{
    // 直接下载图片 原生  // *_* 真机下载图片速度太慢，导致卡死，需要异步下载
    NSMutableArray *imgArr = [[NSMutableArray alloc] init];
    for (BannerData *bannerdata in self.homeDataList.bannerDataList)
    {
        NSURL *imgurl = [NSURL URLWithString:bannerdata.imgUrl];
        NSData *imgdata = [NSData dataWithContentsOfURL:imgurl];
        UIImage *img = [UIImage imageWithData:imgdata];
        if (img)
        {
            [imgArr addObject:img];
        }
    }
    return imgArr;
    
    
    
    
//    // 先查缓存后下载
//    NSMutableArray *imgArr = [[NSMutableArray alloc] init];
//    for (BannerData *bannerdata in self.homeDataList.bannerDataList)
//    {
//        // 缓存中找图片
//        UIImage *cachedImg = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:bannerdata.imgUrl]; //memory缓存
//        if (!cachedImg)
//        {
//            cachedImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:bannerdata.imgUrl]; //disk缓存
//        }
//        if (cachedImg)
//        {
//            // 缓存中找到
//            [imgArr addObject:cachedImg];
//        }
//        else
//        {
//            // 缓存中没找到，下载去
//        }
//    }
//    return imgArr;
    
    
//    // SDImageCache
//    NSMutableArray *imgArr = [[NSMutableArray alloc] init];
//    for (BannerData *bannerdata in self.homeDataList.bannerDataList)
//    {
//        UIImageView *imgView = [[UIImageView alloc] init];
//        //[imgView sd_setImageWithURL:[NSURL URLWithString:bannerdata.imgUrl] placeholderImage:nil];
//        [imgView sd_setImageWithURL:[NSURL URLWithString:bannerdata.imgUrl]
//                   placeholderImage:nil
//                          completed:^(UIImage *image,
//                                      NSError *error,
//                                      SDImageCacheType cacheType,
//                                      NSURL *imgageURL){
//                              
//                              if (image)
//                              {
//                                  [imgArr addObject:image];
//                              }
//                              //*_* 异步，return了才add
//                              
//                              //[self refreshBannerImg]
//                              
//                          }];
//    }
//    return imgArr;
    
}

// 清除图盘缓存
- (void)clearSDImgCache
{
    [[SDWebImageManager sharedManager].imageCache clearMemory];
    [[SDWebImageManager sharedManager].imageCache clearDisk];
}


// HMBannerViewDalegate 点击图片用UIImageView打开Wap链接
- (void)bannerView:(HMBannerView *)bannerView didSelectImageView:(NSInteger)index
{
    if (self.homeDataList.bannerDataList)
    {
        BannerData *bannerdata = [self.homeDataList.bannerDataList objectAtIndex:index];
        if (![KUtils isNullOrEmptyStr:bannerdata.linkUrl])
        {
            WebViewController *bannerWebVC = [[WebViewController alloc] initWithTitle:bannerdata.name UrlStr:bannerdata.linkUrl];
            bannerWebVC.delegate = self;
            //UIViewController *bannerWebVC = [self createWebVCWithTitle:bannerdata.name UrlStr:bannerdata.linkUrl];
            
            [self.tabBarController.navigationController pushViewController:bannerWebVC animated:YES];
        }
    }
}

//// WebViewController Delegate
//- (void)webStopByParticularUrl_Success
//{
//    [self.tabBarController.navigationController pushViewController:(UIViewController *) animated:(BOOL)];
//}
//- (void)webStopByParticularUrl_FaileWithMsg:(NSString *)errMsg
//{
//}


// NavBarItemViewDelegate 点击导航栏按钮
- (void)clickNavBarItemView:(NavBarItemView *)navBarItemView navBarType:(NavBarType)type
{
    if (type == LeftBarType)
    {
        // 创建网贷新闻页面
        NewsViewController *newsVC = [[NewsViewController alloc] init];
        //[self.navigationController pushViewController:newsVC animated:YES];
        [self.tabBarController.navigationController pushViewController:newsVC animated:YES];
        //newsVC = nil;
    }
    else if (type == RightBarType)
    {
        // 创建设置界面
        SettingViewController *settingVC = [[SettingViewController alloc] init];
        [self.tabBarController.navigationController pushViewController:settingVC animated:YES];
    }
}


// 设置数据类型 _dataTypeArray  *_* 多行标的，1行描述
- (void)setDataTypeArray
{
    _dataTypeArray = [[NSMutableArray alloc] init];
    for (int i=0; i<_homeDataList.bidDataList.count; i++)
    {
        [_dataTypeArray addObject:@(Invest_NewestProType)];
    }
    [_dataTypeArray addObject:[NSNumber numberWithInt:Invest_BidType]];
}

#pragma mark - UITableView DataSource + Delegate

// UITableView 返回块数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// UITableView 返回块中的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.homeDataList)
    {
        return _dataTypeArray.count; //*_* 2行标的，1行描述
    }
    else
    {
        return 0;
    }
}

// UITableView 装载数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSInteger row = indexPath.row;
    InvestListViewItemType type = [[_dataTypeArray objectAtIndex:row] integerValue];
    switch (type)
    {
        case Invest_NewestProType:
        {
            static NSString *bidInfoCellIdentifier = @"BidInfoCell";
            BidInfoCell *bidCell = (BidInfoCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:bidInfoCellIdentifier];
            if (!bidCell)
            {
                bidCell = [[BidInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bidInfoCellIdentifier];
            }
            NSArray *bidArr = self.homeDataList.bidDataList;
            BidData *data = [bidArr objectAtIndex:row];
            if (data)
            {
                [bidCell showData:data];
                bidCell.tag = type;
            }
            cell = bidCell;
            break;
        }
        case Invest_BidType:
        {
            static NSString *tipInfoCellIdentifier = @"TipInfoCellIdentifier";
            TipInfoCell *tipCell = (TipInfoCell *)[tableView dequeueReusableCellWithIdentifier:tipInfoCellIdentifier];
            if (!tipCell)
            {
                tipCell = [[TipInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tipInfoCellIdentifier];
            }
            TipData *data = self.homeDataList.tipData;
            if (data)
            {
                tipCell.titleLb.text = @"散标投资";
                NSString *contentText = [NSString stringWithFormat:@"年利率 %@ - %@ %ld起投", data.minRate, data.maxRate, (long)data.minInvest];
                tipCell.contentLb.text = contentText;
                tipCell.tag = type;
            }
            cell = tipCell;
            break;
        }
        default:
        {
            break;
        }
    }
    
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
    
    NSInteger row = indexPath.row;
    UITableViewCell *tempCell = [tableView cellForRowAtIndexPath:indexPath];
    InvestListViewItemType type = tempCell.tag;
    
    switch (type)
    {
        case Invest_NewestProType:
        {
            BidData *biddata = [self.homeDataList.bidDataList objectAtIndex:row];
            [SettingManager shareInstance].bidID = biddata.Id;
            InvestDetailViewController *investDetailVC = [[InvestDetailViewController alloc] init];
            [self.tabBarController.navigationController pushViewController:investDetailVC animated:YES];
            break;
        }
        case Invest_BidType:
        {
            [[HomeTabBarController getInstance] selectTabBarAtIndex:1 withAnimated:YES];
            break;
        }
        default:
        {
            break;
        }
    }
}

// 下拉刷新
- (void)downRefreshRequest
{
    [self sendGetHomeListDataRequest];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
