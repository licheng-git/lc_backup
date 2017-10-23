//
//  taskViewController.h
//  lcAhwTest
//
//  Created by licheng on 16/3/8.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "BaseViewController.h"

@interface taskViewController : BaseViewController

@end


// NSTimer避免内存泄漏
@interface WeakTimerObj : NSObject
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;
@end