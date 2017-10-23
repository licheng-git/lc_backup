//
//  AnnotationObj_callout.h
//  lcAhwTest
//
//  Created by licheng on 15/12/4.
//  Copyright © 2015年 lc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AnnotationObj_callout : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

// 以下是自定义的
@property (nonatomic) UIImage *img;
@property (nonatomic) BOOL bFlag_ShowCustomCalloutView;  // 默认no，用于设置annotationView.canShowCallout

@end
