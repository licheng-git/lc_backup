//
//  SettingViewController.h
//  lcAhwTest
//
//  Created by licheng on 15/4/27.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/message.h>
#import "BaseViewController.h"
#import "CustomIOSAlertView.h"
#import "DialogView.h"
#import "DialogView1.h"
#import "ActionSheetExt.h"
#import "ValidateCodeView.h"
#import "DBOperator.h"
#import "SlideViewController.h"
#import "aVC.h"
#import "bVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "QBImagePickerController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "NSString+Addtions.h"
#import "threadViewController.h"
#import "socketViewController.h"
#import "AudioViewController.h"
#import "MediaViewController.h"
#import "blockViewController.h"
#import "requestViewController.h"
#import "navViewController.h"
#import "aes_desViewController.h"
#import "signatureViewController.h"
#import "2dViewController.h"
#import "3dViewController.h"
#import "MapViewController.h"
#import "addressbookViewController.h"
#import "bluetoothViewController.h"
#import "taskViewController.h"
#import "keyboardViewController.h"
#import "dragViewController.h"
#import "KLineViewController.h"

@interface SettingViewController : BaseViewController<
                                                        UITextViewDelegate,
                                                        UIActionSheetDelegate,
                                                        ActionSheetExtDelegate,
                                                        UICollectionViewDataSource, UICollectionViewDelegate,
                                                        UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                                        QBImagePickerControllerDelegate
                                                     >

@property (nonatomic, strong) UIImage *imgTest;

@end


@interface MyObj : NSObject<NSCopying>
{}
@property (nonatomic) NSString *str;
@property (nonatomic) NSMutableString *mutableStr;
@property (nonatomic) NSArray *arr;
@property (nonatomic) NSMutableArray *mutableArr;
@property (nonatomic) int kk;
@end

