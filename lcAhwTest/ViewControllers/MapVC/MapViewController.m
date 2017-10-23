//
//  MapViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/11/25.
//  Copyright © 2015年 lc. All rights reserved.
//

#import "MapViewController.h"

#import <CoreLocation/CoreLocation.h>

#import <MapKit/MapKit.h>
#import "AnnotationObj.h"
#import "AnnotationObj_callout.h"
#import "AnnotationObjView_callout.h"

@interface MapViewController()<CLLocationManagerDelegate, MKMapViewDelegate>
{
    CLLocationManager *_locationManager;  // 地理定位
//    CLGeocoder        *_geocoder;         // 地理编码
    
    MKMapView *_mapView;  // 地图
    UITextField *_tf;  // 地图搜索框
}
@end

@implementation MapViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.bIsNeedTapGesture = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"地图";
    self.view.backgroundColor = [UIColor greenColor];
    
    //[self createMapView_simple];
    [self testLocation];
    [self createMapView];
}




#pragma mark - 地理定位 CLLocationManager

// 定位：targets info -> NSLocationAlwaysUsageDescription / NSLocationWhenInUseUsageDescription

- (void)testLocation
{
    if (![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"地理定位 服务不可用");
        return;
    }
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 100;  // 定位过滤器，减少定位装置轮询次数，至少移动了100米再通知委托处理更新
    //[_locationManager requestWhenInUseAuthorization];  // 使用时请求用户授权  *_*
    [_locationManager requestAlwaysAuthorization];
    [_locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager 错误 *_* %@", error);
    if (error.code == kCLErrorDenied)
    {
        NSLog(@"地理定位权限没开");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    
    // 获取坐标 精度纬度等
    CLLocation *newLocation = locations[0];
    NSLog(@"经度 %.2f", newLocation.coordinate.longitude);
    NSLog(@"纬度 %f", newLocation.coordinate.latitude);
    NSLog(@"海拔 %f", newLocation.altitude);
    NSLog(@"航向 %f", newLocation.course);
    NSLog(@"速度 %f", newLocation.speed);
    
    // 反地理编码 根据坐标 获取地名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"placemarks.count = %d", placemarks.count);
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        //NSLog(@"%@", placemark);
        NSLog(@"placemark.name  %@", placemark.name);
        NSLog(@"国家编码  %@", [placemark.addressDictionary objectForKey:@"CountryCode"]);
        NSLog(@"国家     %@", [placemark.addressDictionary objectForKey:@"Country"]);
        NSLog(@"省       %@", [placemark.addressDictionary objectForKey:@"State"]);
        NSLog(@"市       %@", [placemark.addressDictionary objectForKey:@"City"]);
        NSLog(@"区       %@", [placemark.addressDictionary objectForKey:@"SubLocality"]);
        NSLog(@"街道     %@", [placemark.addressDictionary objectForKey:@"Thoroughfare"]);
        NSLog(@"门牌号   %@", [placemark.addressDictionary objectForKey:@"SubThoroughfare"]);
        NSLog(@"街＋门   %@", [placemark.addressDictionary objectForKey:@"Street"]);
        NSLog(@"地址     %@", [placemark.addressDictionary objectForKey:@"FormattedAddressLines"]);
    }];
    NSLog(@"异步的 *_* locations.count = %lu", locations.count);
    
    // 地理编码 根据地名 获取坐标
    NSString *addressStr = @"安陆";
    CLGeocoder *geocoder1 = [[CLGeocoder alloc] init];
    [geocoder1 geocodeAddressString:addressStr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark = [placemarks firstObject];
        CLLocation *location = placemark.location;
        NSLog(@"%@ 经度 %.2f",addressStr, location.coordinate.longitude);
        NSLog(@"%@ 纬度 %f",addressStr, location.coordinate.latitude);
    }];
    
}




#pragma mark - 地图 MKMapItem  打开系统地图App

- (void)createMapView_simple
{
    // 当前位置
    MKMapItem *mapItem = [MKMapItem mapItemForCurrentLocation];
    NSDictionary *dicOptions = @{ MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard) };
    [mapItem openInMapsWithLaunchOptions:dicOptions];
    
//    // 一个位置
//    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//    [geocoder geocodeAddressString:@"深圳市" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        CLPlacemark *clPlacemark = [placemarks firstObject];
//        MKPlacemark *mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:clPlacemark];
//        NSDictionary *dicOptions = @{ MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard) };
//        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:mkPlacemark];
//        [mapItem openInMapsWithLaunchOptions:dicOptions];
//    }];

//    // 多个位置  （注意异步）
//    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//    [geocoder geocodeAddressString:@"深圳" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        CLPlacemark *clPlacemark0 = [placemarks firstObject];
//        MKPlacemark *mkPlacemark0 = [[MKPlacemark alloc] initWithPlacemark:clPlacemark0];
//        [geocoder geocodeAddressString:@"安陆" completionHandler:^(NSArray *placemarks, NSError *error) {
//            CLPlacemark *clPlacemark1 = [placemarks firstObject];
//            MKPlacemark *mkPlacemark1 = [[MKPlacemark alloc] initWithPlacemark:clPlacemark1];
//            NSDictionary *dicOptions=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
//            MKMapItem *mapItem0 = [[MKMapItem alloc] initWithPlacemark:mkPlacemark0];
//            MKMapItem *mapItem1 = [[MKMapItem alloc] initWithPlacemark:mkPlacemark1];
//            [MKMapItem openMapsWithItems:@[mapItem0, mapItem1] launchOptions:dicOptions];
//        }];
//    }];
}




#pragma mark - 地图 MKMapView

- (void)createMapView
{
    CGRect rect = CGRectMake(10, kDEFAULT_ORIGIN_Y + 10, kSCREEN_WIDTH - 20, kSCREEN_HEIGHT - kDEFAULT_ORIGIN_Y - 20);
    _mapView = [[MKMapView alloc] initWithFrame:rect];
    [self.view addSubview:_mapView];
    _mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;  // 地图类型
    //_mapView.userTrackingMode = MKUserTrackingModeFollow;  // 用户位置追踪模式 （定位需联网）
    //_mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(22.54, 114.02), MKCoordinateSpanMake(0.5, 0.5));  // 设置范围  center为中心，span为+-经纬度
//    MKCoordinateRegion region = { { 22.54, 114.02 }, { 1, 1 } };
//    [_mapView setRegion:region animated:YES];
    
    // 搜索框
   _tf = [KUtils createTextFieldWithFrame:CGRectMake(10, 10, 200, 30) fontSize:13 enable:YES delegate:self tag:0];
    _tf.backgroundColor = [UIColor lightGrayColor];
    _tf.placeholder = @" 搜索 ";
    [_mapView addSubview:_tf];
    UIButton *btn = [KUtils createButtonWithFrame:CGRectMake(220, 10, 50, 30) title:@"搜索" titleColor:[UIColor blueColor] target:self tag:0];
    [_mapView addSubview:btn];
    
    // 添加手势，获取地图上点击处的经纬度
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPressOnMap:)];
    tapGesture.numberOfTapsRequired = 1;
    [_mapView addGestureRecognizer:tapGesture];
    
    // 添加大头针
    AnnotationObj *annation = [[AnnotationObj alloc] init];
    annation.title = @"title标题";
    annation.subtitle = @"subtitle子标题";
    annation.coordinate = CLLocationCoordinate2DMake(22.54, 114.02);  // 深圳车公庙(22.54,114.02)，安陆(31.26,113.69)
    annation.imgPin = [UIImage imageNamed:@"user_head_image"];
    annation.imgCalloutLeft = [UIImage imageNamed:@"loading.gif"];
    annation.imgCalloutRight = [UIImage imageNamed:@"loading.gif"];
    [_mapView addAnnotation:annation];
    
    AnnotationObj *annation1 = [[AnnotationObj alloc] init];
    annation1.title = @"hello 哈";
    annation1.subtitle = @"hi 嘿嘿嘿嘿嘿嘿嘿嘿嘿嘿嘿嘿嘿嘿嘿嘿嘿嘿噶";
    annation1.coordinate = CLLocationCoordinate2DMake(22.54, 114.03);
    annation1.imgPin = [UIImage imageNamed:@"top-message-round"];
    annation1.imgCalloutLeft = [UIImage imageNamed:@"loading.gif"];
    annation1.imgCalloutRight = [UIImage imageNamed:@"loading.gif"];
    [_mapView addAnnotation:annation1];
    
    AnnotationObj_callout *annation2 = [[AnnotationObj_callout alloc] init];
    annation2.coordinate = CLLocationCoordinate2DMake(22.53, 114.02);
    annation2.bFlag_ShowCustomCalloutView = NO;  // 刚开始时不弹出calloutView
    annation2.img = [UIImage imageNamed:@"loading.gif"];
    annation2.title = @"自定义大头针和弹出层";
    [_mapView addAnnotation:annation2];
}


- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    NSLog(@"地图加载失败 *_* %@", error);
}

//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
//{
//    NSLog(@"didUpdateUserLocation *_* %@", userLocation.location);
//}


// 修改大头针视图（若想使用系统默认大头针则return nil）
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[AnnotationObj class]])
    {
        // 修改大头针
        static NSString *key = @"AnnotationKey";
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:key];
        // 如果缓存池中不存在则新建
        if (!annotationView)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:key];
            annotationView.canShowCallout = YES;  // 允许点击交互，弹出系统calloutView
            //annotationView.draggable = YES;  // 允许拖动
        }
        annotationView.annotation = annotation;  // 缓存池中存在
        annotationView.image = ((AnnotationObj *)annotation).imgPin;  // 修改大头针图标
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:((AnnotationObj *)annotation).imgCalloutLeft];  // 修改详情左侧视图
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 80)];
        view.backgroundColor = [UIColor orangeColor];
        annotationView.rightCalloutAccessoryView = view;
        annotationView.detailCalloutAccessoryView = [[UIImageView alloc] initWithImage:((AnnotationObj *)annotation).imgPin];  // iOS9 （iOS8及以下应使用AnnotationObjView_callout）
        
        return annotationView;
    }
    else if ([annotation isKindOfClass:[AnnotationObj_callout class]])
    {
        // 自定义大头针的弹出层calloutView  （原理：didSelect时先删除系统的，再add自定义的大头针视图再次触发此委托方法）
        AnnotationObj_callout *annotationCallout = (AnnotationObj_callout *)annotation;
        if (annotationCallout.bFlag_ShowCustomCalloutView == NO)  // 一开始用系统的
        {
            static NSString *key = @"AnnotationKey";
            MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:key];
            if (!annotationView)
            {
                annotationView = [(MKPinAnnotationView *)[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:key];
                annotationView.canShowCallout = NO;  // 自定义calloutView
                annotationView.pinColor = MKPinAnnotationColorPurple;
                annotationView.animatesDrop = YES;
            }
            annotationView.annotation = annotationCallout;
            return annotationView;
        }
        else  // 点击后替换为自定义的，带弹出层calloutView
        {
            static NSString *key = @"AnnotationKey";
            AnnotationObjView_callout *annotationView = (AnnotationObjView_callout *)[_mapView dequeueReusableAnnotationViewWithIdentifier:key];
            if (!annotationView)
            {
                annotationView = [[AnnotationObjView_callout alloc] initWithAnnotation:annotation reuseIdentifier:key];
                annotationView.canShowCallout = NO;  // 自定义calloutView
                //annotationView.calloutOffset = CGPointMake(50, 0);  // 定义详情视图偏移量
            }
            annotationView.annotationObj_callout = annotationCallout;  // 设置自定义ui
            return annotationView;
        }
    }
    
    // 由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    return nil;
}

// 选中大头针
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"didSelectAnnotationView *_* %@", view.annotation.title);
    
    // 自定义大头针的弹出层calloutView （实际上是加一个自定义的盖住系统的）
    if ([view.annotation isKindOfClass:[AnnotationObj_callout class]])
    {
        //[_mapView removeAnnotation:view.annotation];
        AnnotationObj_callout *annation = [[AnnotationObj_callout alloc] init];
        annation.coordinate = view.annotation.coordinate;
        annation.bFlag_ShowCustomCalloutView = YES;  // 需要弹出calloutView
        annation.img = ((AnnotationObj_callout *)view.annotation).img;
        [_mapView addAnnotation:annation];
    }
}

// 取消选中大头针
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"didDeselectAnnotationView *_* %@", view.annotation.title);
    
    // 删除 自定义大头针的弹出层calloutView
    [_mapView.annotations enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[AnnotationObj_callout class]] && ((AnnotationObj_callout *)obj).bFlag_ShowCustomCalloutView)
        {
            [_mapView removeAnnotation:obj];
        }
    }];
}




// 地图 搜索
- (void)buttonAction:(id)sender
{
    if (![KUtils isNullOrEmptyStr:_tf.text])
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:_tf.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            CLPlacemark *clPlacemark = [placemarks firstObject];
            NSLog(@"%@ *_* 经度 %.2f ; 纬度 %f", _tf.text, clPlacemark.location.coordinate.longitude, clPlacemark.location.coordinate.latitude);
            _mapView.region = MKCoordinateRegionMake(clPlacemark.location.coordinate, MKCoordinateSpanMake(0.5, 0.5));
        }];
    }
    
    [self.activeTextField resignFirstResponder];
    self.activeTextField = nil;
}

- (void)textFieldValueChange:(UITextField *)sender
{
}


// 手势，获取地图上点击处的经纬度
- (void)tapPressOnMap:(UIGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:_mapView];
    CLLocationCoordinate2D coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];  // 获取点击处的经纬度
    NSLog(@"*_* 经度 %.2f ; 纬度 %f", coordinate.longitude, coordinate.latitude);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"placemarks.count = %d", placemarks.count);
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        //NSLog(@"%@", placemark);
        NSLog(@"placemark.name  %@", placemark.name);
        NSLog(@"国家编码  %@", [placemark.addressDictionary objectForKey:@"CountryCode"]);
        NSLog(@"国家     %@", [placemark.addressDictionary objectForKey:@"Country"]);
        NSLog(@"省       %@", [placemark.addressDictionary objectForKey:@"State"]);
        NSLog(@"市       %@", [placemark.addressDictionary objectForKey:@"City"]);
        NSLog(@"区       %@", [placemark.addressDictionary objectForKey:@"SubLocality"]);
        NSLog(@"街道     %@", [placemark.addressDictionary objectForKey:@"Thoroughfare"]);
        NSLog(@"门牌号   %@", [placemark.addressDictionary objectForKey:@"SubThoroughfare"]);
        NSLog(@"街＋门   %@", [placemark.addressDictionary objectForKey:@"Street"]);
        NSLog(@"地址     %@", [placemark.addressDictionary objectForKey:@"FormattedAddressLines"]);
    }];
}

@end
