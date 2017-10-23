//
//  AnnotationObj.h
//  lcAhwTest
//
//  Created by licheng on 15/12/2.
//  Copyright © 2015年 lc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AnnotationObj : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

// 以下是自定义的
@property (nonatomic) UIImage *imgPin;
@property (nonatomic) UIImage *imgCalloutLeft;
@property (nonatomic) UIImage *imgCalloutRight;

@end
