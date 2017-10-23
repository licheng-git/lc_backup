//
//  LoanInfoView.m
//  lcAhwTest
//
//  Created by licheng on 15/5/5.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "LoanInfoView.h"
#import "KUtils.h"

#define CellHeight           25.0f
#define SectionHeaderHeight  25.0f
#define SectionFooterHeight  10.0f

#define LoanInfoKey    @"Key"
#define LoanInfoValue  @"Value"

@interface LoanInfoView()
{
    UITableView *_tableView;
    NSMutableArray *_headerViewTitleArr;  // section头标题
    NSMutableArray *_dataArrOfSections;   // 所有section的数据
}
@end

@implementation LoanInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // 创建tableView
        CGRect rect = self.bounds;  // 相对于当前loanInfoView
        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorColor = [UIColor whiteColor];  // ios6分组时无效
        [self addSubview:_tableView];
    }
    return self;
}

// 设置loanInfoArr，加载数据
- (void)setLoanInfoArr:(NSArray *)loanInfoArr
{
    _loanInfoArr = loanInfoArr;
    
    // section的标题
    _headerViewTitleArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    // 所有section的相关数据
    _dataArrOfSections = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i=0; i<_loanInfoArr.count; i++)
    {
        NSDictionary *dic = [_loanInfoArr objectAtIndex:i];
        if (![KUtils isNullOrEmptyArr:dic])
        {
            NSString *key = [dic objectForKey:LoanInfoKey];
            [_headerViewTitleArr addObject:key];
            
            NSArray *valueArr = [dic objectForKey:LoanInfoValue];
            if (![KUtils isNullOrEmptyArr:valueArr])
            {
                [_dataArrOfSections addObject:valueArr];
            }
        }
    }
    
    [_tableView reloadData];
}

// 获取对应位置的数据
- (NSDictionary *)getDictionaryWithSection:(NSInteger)section withRow:(NSInteger)row
{
    NSDictionary *dic = nil;
    if (![KUtils isNullOrEmptyArr:_dataArrOfSections])
    {
        NSArray *dataArr = [_dataArrOfSections objectAtIndex:section];
        if (![KUtils isNullOrEmptyArr:dataArr])
        {
            dic = [dataArr objectAtIndex:row];
        }
    }
    return dic;
}


#pragma mark - UITableView DataSource + Delegate

// section块数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_headerViewTitleArr && _headerViewTitleArr.count > 0)
    {
        return _headerViewTitleArr.count;
    }
    return 0;
}

// 每个section块的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [_dataArrOfSections objectAtIndex:section];
    if (array && array.count > 0)
    {
        return array.count;
    }
    return 0;
}

// load数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSDictionary *dic = [self getDictionaryWithSection:section withRow:row];
    if (![KUtils isNullOrEmptyArr:dic])
    {
        cell.textLabel.text = [NSString stringWithFormat:@"  %@ - %@", [dic objectForKey:LoanInfoKey], [dic objectForKey:LoanInfoValue]];
    }
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    
    return cell;
}

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

// section块的header高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_headerViewTitleArr && _headerViewTitleArr.count > 0)
    {
        return SectionHeaderHeight;
    }
    return 0;
}

// section块的footer高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return SectionFooterHeight;
}

// section块的header视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect = CGRectMake(10.0, 0.0, tableView.frame.size.width, SectionHeaderHeight);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor whiteColor];
    rect.size.width = 100.0;
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.text = [_headerViewTitleArr objectAtIndex:section];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:16.0];
    [view addSubview:label];
    return view;
}

// section块的footer视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGRect rect = CGRectMake(0.0, 0.0, tableView.frame.size.width, SectionFooterHeight);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

// 点击行
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
