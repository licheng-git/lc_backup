//
//  UITextView+lc.m
//  lcAhwTest
//
//  Created by licheng on 16/6/27.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "UITextView+lc.h"
#import <objc/runtime.h>

@interface UITextView()<UITextViewDelegate>
{
    //UILabel *_lbPlaceholder;
}
@property (nonatomic, strong) UILabel *lbPlaceholder;
@end

@implementation UITextView (lc)


#pragma mark - placeholder

- (UILabel *)lbPlaceholder {
    return objc_getAssociatedObject(self, @selector(lbPlaceholder));
}

- (void)setLbPlaceholder:(UILabel *)value {
    objc_setAssociatedObject(self, @selector(lbPlaceholder), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)placeholder {
    return objc_getAssociatedObject(self, @selector(placeholder));
}

- (void)setPlaceholder:(NSString *)value {
    objc_setAssociatedObject(self, @selector(placeholder), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!self.lbPlaceholder) {
        self.lbPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.width, 30)];
        self.lbPlaceholder.textColor = [UIColor lightGrayColor];
        self.lbPlaceholder.textAlignment = self.textAlignment;
        self.lbPlaceholder.font = self.font;
        [self addSubview:self.lbPlaceholder];
        //self.delegate = self;  // *_* 这里会覆盖掉其它地方
        //[self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];  // *_*?
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange_category:) name:UITextViewTextDidChangeNotification object:nil];
    }
    self.lbPlaceholder.text = value;
}

//#pragma mark - UITextViewDelegate
//
//- (void)textViewDidChange:(UITextView *)textView {
//    NSLog(@"*_* textview.category.delegate textViewDidChange");
//    //if (self.tempDelegate && [self.tempDelegate respondsToSelector:@selector(textViewDidChange:)]) {
//    //    [self.tempDelegate textViewDidChange:textView];
//    //}
//}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSLog(@"*_* textview.category.observer textViewDidChange");
//    if (object == self && [keyPath isEqualToString:@"text"]) {
//    }
//}

- (void)textViewDidChange_category:(NSNotification *)notification {
    NSLog(@"*_* category textViewDidChange");
    if (self.text && self.text.length > 0) {
        self.lbPlaceholder.hidden = YES;
    }
    else {
        self.lbPlaceholder.hidden = NO;
    }
}

- (void)dealloc {
    NSLog(@"*_* textview.category dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}


#pragma mark - tempTextHeight + TextHeight

- (CGFloat)temp_TextHeight {
    id obj = objc_getAssociatedObject(self, @selector(temp_TextHeight));
    return [obj doubleValue];
}

- (void)setTemp_TextHeight:(CGFloat)value {
    id valueObj = [NSString stringWithFormat:@"%f", value];
    objc_setAssociatedObject(self, @selector(temp_TextHeight), valueObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// 获取文本中字体的size
- (CGFloat)textHeight {
    CGSize constrainedSize = CGSizeMake(self.frame.size.width-10, MAXFLOAT);
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attrDic = @{ NSFontAttributeName:self.font };
    CGSize textSize = [self.text boundingRectWithSize:constrainedSize options:options attributes:attrDic context:nil].size;
    NSLog(@"tv.text.size.height = %0.2f, tv.size.height = %0.2f", textSize.height, self.frame.size.height);
    return textSize.height;
}

@end
