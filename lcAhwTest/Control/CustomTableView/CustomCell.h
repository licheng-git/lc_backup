//
//  CustomCell.h
//  lcAhwTest
//
//  Created by licheng on 15/5/7.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CustomCellHeight 24.0

@interface CustomCell : UITableViewCell

// 通用cell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(NSArray *)data;

@end
