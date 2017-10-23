//
//  Constants.h
//  lcAhwTest
//
//  Created by licheng on 15/4/13.
//  Copyright (c) 2015年 lc. All rights reserved.
//

//  此文件存放所有公共部分用到的常量

#ifndef lcAhwTest_Constants_h
#define lcAhwTest_Constants_h


// 屏幕的宽和高
#define kSCREEN_WIDTH           [UIScreen mainScreen].bounds.size.width
#define kSCREEN_HEIGHT          [[UIScreen mainScreen] bounds].size.height

// 高度
#define kNAVIGATION_HEIGHT      44.0f    // 导航高度
#define kSTATUSBAR_HEIGHT       20.0f    // 状态条高度（电池、网络）
#define kBOTTOM_HEIGHT          49.0f    // 底部tabBar的高度

// 间隔
#define kLEFT_SPACE             12.0f    // 距离屏幕两边间隔
#define kTOP_SPACE              20.0f    // 距离导航条间隔
#define kLINE_SPACE             5.0f     // 分割线上下端间隔

// 设置rgb颜色
#define kCOLORRGB(r,g,b)    [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

// 背景色
#define kBACKGROUND_COLOR    kCOLORRGB(244.0, 245.0, 249.0)   
// 导航条颜色
#define kNAV_BG_COLOR        kCOLORRGB(241, 83, 71)
// tableView背景色
//#define kTABLEVIEW_BG_COLOR  kCOLORRGB(255, 255, 255)
// textFeild文字颜色
#define kTextFieldFontColor  kCOLORRGB(121.0, 121.0, 121.0)

// 默认tag
#define kDEFAULT_TAG 0

// 应用程序AppID
#define kAppID  @"1017221198"



#define kDEFAULT_ORIGIN_Y    ([KUtils isIOS7] ? 64.0f : 0.0f)

#endif
