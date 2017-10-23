//
//  AnnotationObjView_callout.m
//  lcAhwTest
//
//  Created by licheng on 15/12/4.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "AnnotationObjView_callout.h"

@interface AnnotationObjView_callout()
{
    UIImageView *_contentImgView;
}
@end

@implementation AnnotationObjView_callout

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.bounds = CGRectMake(0, 0, 100, 50);
        self.centerOffset = CGPointMake(0, self.bounds.size.height / 2 - 5);  // 移动位置
        self.backgroundColor = [UIColor orangeColor];
        self.alpha = 0.8;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        view.backgroundColor = [UIColor greenColor];
        [self addSubview:view];
        _contentImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        [self addSubview:_contentImgView];
    }
    return self;
}

// 自定义大头针及弹出层
- (void)setAnnotationObj_callout:(AnnotationObj_callout *)annotationObj_callout
{
    [super setAnnotation:annotationObj_callout];
    _contentImgView.image = annotationObj_callout.img;
}


@end
