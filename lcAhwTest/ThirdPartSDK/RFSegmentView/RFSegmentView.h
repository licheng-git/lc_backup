//
//  RFSegmentView.h
//  RFSegmentView



#import <UIKit/UIKit.h>
@protocol RFSegmentViewDelegate <NSObject>
@optional
- (void)segmentViewSelectIndex:(NSInteger)index;
@end

@interface RFSegmentView : UIView
/**
 *  设置风格颜色
 */
@property(nonatomic, strong) UIColor *tintColor;
@property(nonatomic, assign) id<RFSegmentViewDelegate> delegate;

@property(nonatomic, assign) NSInteger selectedIndex; // 当前选中的item

/**
 *  默认构造函数
 *
 *  @param frame frame
 *  @param items title字符串数组
 *
 *  @return 当前实例
 */
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;

@end
