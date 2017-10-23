//
//  storyboardViewController.m
//  lcAhwTest
//
//  Created by licheng on 16/3/25.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "storyboardViewController.h"
#import "Masonry.h"
#import "BGTableViewRowActionWithImage.h"

@interface storyboardViewController ()
{
    NSArray *_titleArr;
    NSArray *_imgNameArr;
}
@property (strong, nonatomic) IBOutlet UIView *contentView;
@end

@implementation storyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"kk.bundle" ofType:nil];
    //NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Frameworks/Base.famework" ofType:nil];
    //NSBundle *kkBundle = [NSBundle bundleWithPath:bundlePath];
    
    //NSBundle *kkBundle = [NSBundle bundleForClass:kkViewController.class];
    //NSBundle *kkBundle = [NSBundle bundleForClass:self.class];
    //UIImage *imgAdd = [UIImage imageNamed:@"kk_add" inBundle:kkBundle compatibleWithTraitCollection:nil];
    
    
    // storyboard UIViewController
    //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"sb" bundle:nil];
    //UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"vcId"];
    
    // xib UIViewController
    ////kkViewController *vc = [[kkViewController alloc] init];  // *_*
    //NSBundle *bundle = [NSBundle bundleForClass:self.class];
    ////kkViewController *vc = [[kkViewController alloc] initWithNibName:nil bundle:bundle];
    ////kkViewController *vc = [[kkViewController alloc] initWithNibName:@"kkViewController" bundle:bundle];
    //kkViewController *vc = [[kkViewController alloc] initWithNibName:NSStringFromClass(kkViewController.class) bundle:bundle];
    
    // xib UIView
    //NSBundle *bundle = [NSBundle bundleForClass:self.class];
    ////NSArray *arr = [bundle loadNibNamed:@"kkView" owner:self options:nil];
    //NSArray *arr = [bundle loadNibNamed:NSStringFromClass(kkView.class) owner:self options:nil];
    //kkView *v = arr[0];
    
    // xib UITableViewCell
    //UINib *nib = [UINib nibWithNibName:@"" bundle:bundle];
    //[self.tableView registerNib:nib forCellReuseIdentifier:noticeListlidentifier];
    
    
    
    _titleArr = @[@"最新话题", @"消息", @"数据分析", @"设置", @"登出"];
    _imgNameArr = @[@"note_left_menu_topic", @"note_left_menu_msg", @"note_left_menu_analyse", @"note_left_menu_setting", @"note_left_menu_exit"];
    
//    // 自动布局要更改frame需在viewDidLayoutSubviews方法中
//    CGFloat tempW = kSCREEN_WIDTH * 0.9;
//    CGRect tempFrame = _contentView.frame;
//    tempFrame.size.width = tempW;
//    _contentView.frame = tempFrame;
    
    
    // https:/ /github.com/SnapKit/Masonry
    CGFloat tempW = kSCREEN_WIDTH * 0.9;
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(tempW);
    }];
    NSLog(@"%f,%f,%f,%f", _contentView.frame.origin.x, _contentView.frame.origin.y, _contentView.frame.size.width, _contentView.frame.size.height);
    [_contentView layoutIfNeeded];
    NSLog(@"%f,%f,%f,%f", _contentView.frame.origin.x, _contentView.frame.origin.y, _contentView.frame.size.width, _contentView.frame.size.height);
    
    
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH - 120, 100, 100, 50)];
    [self.view addSubview:testView];
    UIButton *btn0 = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [testView addSubview:btn0];
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectZero];
    [btn1 setTitle:@"发送" forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"note_left_menu_msg"] forState:UIControlStateNormal];
    [testView addSubview:btn1];
    
    //btn1.translatesAutoresizingMaskIntoConstraints = NO;
    [self view:testView allEdgesOfSubview:btn1];
    
//    for (NSLayoutConstraint *constraint in testView.constraints) {
//        if ([constraint.secondItem isEqual:btn0] && constraint.secondAttribute == NSLayoutAttributeLeading) {
//            constraint.constant = -testView.frame.size.width / 2;
//        }
//        else if ([constraint.secondItem isEqual:btn1] && constraint.secondAttribute == NSLayoutAttributeTrailing) {
//            constraint.constant = testView.frame.size.width / 2;
//        }
//    }
    for (NSLayoutConstraint *constraint in testView.constraints) {
        if ([constraint.secondItem isEqual:btn1] && constraint.secondAttribute == NSLayoutAttributeLeading) {
            constraint.constant = -testView.frame.size.width / 2;
        }
    }
    
    testView.backgroundColor = [UIColor orangeColor];
    btn0.backgroundColor = [UIColor yellowColor];
    btn1.backgroundColor = [UIColor greenColor];
    
}

//-(void)viewDidLayoutSubviews {
//    //[super viewDidLayoutSubviews];
//    CGFloat tempW =  kSCREEN_WIDTH * 0.9;
//    CGRect tempFrame = _contentView.frame;
//    tempFrame.size.width = tempW;
//    _contentView.frame = tempFrame;
//    //_inforView.frame ...
//    //_tableView.frame ...
//}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titleArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (tableView.frame.size.height - tableView.tableHeaderView.frame.size.height) / _titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = _titleArr[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:_imgNameArr[indexPath.row]];
    
    return cell;
}


//// 分割线左边靠最左边
//-(void)viewDidLayoutSubviews
//{
//    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        _tableView.separatorInset = UIEdgeInsetsZero;
//    }
//    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
//    }
//}
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"哈哈" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"tableView:editActionsForRowAtIndexPath:");
        [self setEditing:NO animated:YES];
    }];
    rowAction.backgroundColor = [UIColor greenColor];
    BGTableViewRowActionWithImage *rowAction1 =
    [BGTableViewRowActionWithImage rowActionWithStyle:UITableViewRowActionStyleNormal
                                                title:@"嘿嘿"
                                           titleColor:[UIColor blueColor]
                                      backgroundColor:[UIColor orangeColor]
                                                image:[UIImage imageNamed:@"note_left_menu_setting"]
                                        forCellHeight:50
                                              handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
    }];
    return @[rowAction, rowAction1];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}


- (void)view:(UIView *)selfView toSubview:(UIView *)subview withEdge:(NSLayoutAttribute)la
{
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:selfView
                                                          attribute:la
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:subview
                                                          attribute:la
                                                         multiplier:1.0f
                                                           constant:0.0f];
    [selfView addConstraint:lc];
}
- (void)view:(UIView *)selfView allEdgesOfSubview:(UIView *)subview
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self view:selfView toSubview:subview withEdge:NSLayoutAttributeTop];
    [self view:selfView toSubview:subview withEdge:NSLayoutAttributeBottom];
    [self view:selfView toSubview:subview withEdge:NSLayoutAttributeLeading];
    [self view:selfView toSubview:subview withEdge:NSLayoutAttributeTrailing];
}


@end

