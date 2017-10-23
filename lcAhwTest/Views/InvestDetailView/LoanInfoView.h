//
//  LoanInfoView.h
//  lcAhwTest
//
//  Created by licheng on 15/5/5.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoanInfoView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *loanInfoArr;

@end
