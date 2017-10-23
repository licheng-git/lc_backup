//
//  WebViewController.h
//  lcAhwTest
//
//  Created by licheng on 15/4/23.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WebVC_Delegate<NSObject>

@optional
- (void)webStopByParticularUrl_Success;
- (void)webStopByParticularUrl_FaileWithMsg:(NSString *)errMsg;

@end


@interface WebViewController : UIViewController

@property (nonatomic, assign) id<WebVC_Delegate> delegate;

- (instancetype)initWithTitle:(NSString *)title UrlStr:(NSString *)urlStr;

@end
