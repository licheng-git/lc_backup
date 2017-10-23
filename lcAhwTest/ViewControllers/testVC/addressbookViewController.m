//
//  addressbookViewController.m
//  lcAhwTest
//
//  Created by licheng on 16/1/18.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "addressbookViewController.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>

@interface addressbookViewController()<MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
@end

@implementation addressbookViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"通讯录、短信、邮件";
    [self getAddressbook];
    [self sendMsg];
    //[self sendMail];
}


// 通讯录
- (void)getAddressbook
{
    ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
    //等待同意后向下执行
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressbook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (!granted)
                                                 {
                                                     if (addressbook)
                                                     {
                                                         CFRelease(addressbook);
                                                         //addressbook = NULL;
                                                     }
                                                 }
                                                 dispatch_semaphore_signal(sema);
                                             });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    //dispatch_release(sema);  // mrc
    
    ABAuthorizationStatus authorization = ABAddressBookGetAuthorizationStatus();
    if (authorization != kABAuthorizationStatusAuthorized)
    {
        NSLog(@"无通讯录权限");
        return;
    }
    
    if (addressbook == nil)
    {
        return;
    }
    
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressbook);
    if (people == nil)
    {
        return;
    }
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                               CFArrayGetCount(people),
                                                               people);
    CFArraySortValues(peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      (void*)((long)ABPersonGetSortOrdering()));
    ABPersonCompositeNameFormat compositeNameFormat = ABPersonGetCompositeNameFormat();
//    // mrc
//    for (id p in ((NSMutableArray *)peopleMutable))
//    {
//        CFStringRef firstName = ABRecordCopyValue(p, kABPersonFirstNameProperty);
//        NSString *firstNameStr;
//        if (firstName)
//        {
//            firstNameStr = (NSString*)firstName;
//        }
//    }
    for (id p in ((__bridge NSMutableArray *)peopleMutable))
    {
        CFStringRef firstName = ABRecordCopyValue((__bridge ABRecordRef)(p), kABPersonFirstNameProperty);
        CFStringRef lastName = ABRecordCopyValue((__bridge ABRecordRef)(p), kABPersonLastNameProperty);
        NSString *firstNameStr;
        NSString *lastNameStr;
        NSString *nickNameStr;
        if (firstName)
        {
            firstNameStr = (__bridge NSString*)firstName;
        }
        if (lastName)
        {
            lastNameStr = (__bridge NSString*)lastName;
        }
        if (firstName && lastName)
        {
            if (compositeNameFormat == 1)
            {
                nickNameStr = [firstNameStr stringByAppendingString:lastNameStr];
            }
            else
            {
                nickNameStr = [lastNameStr stringByAppendingString:firstNameStr];
            }
        }
        NSLog(@"%@", nickNameStr);
        
        ABMultiValueRef phones = ABRecordCopyValue((__bridge ABRecordRef)(p), kABPersonPhoneProperty);
        CFIndex phonesCount = 0;
        if (phones)
        {
            phonesCount = ABMultiValueGetCount(phones);
        }
        NSMutableArray *phoneArr = [[NSMutableArray alloc] init];
        for (CFIndex i=0; i<phonesCount; i++)
        {
            CFStringRef phoneNumber = ABMultiValueCopyValueAtIndex(phones, i);
            if (phoneNumber)
            {
                NSString *phoneNumberStr = (__bridge NSString*)phoneNumber;
                NSLog(@"%@", phoneNumberStr);
                [phoneArr addObject:phoneNumberStr];
            }
            if (phoneNumber)
            {
                CFRelease(phoneNumber);
            }
        }
        
        if (firstName)
        {
            CFRelease(firstName);
        }
        if (lastName)
        {
            CFRelease(lastName);
        }
    }
    
    CFRelease(people);
    CFRelease(peopleMutable);
    
    
    // 查找联系人
    //ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(addressbook, (ABRecordID)recordId);  // 根据id查找
    CFArrayRef recordsRef = ABAddressBookCopyPeopleWithName(addressbook, (__bridge CFStringRef)@"lc iverson");  // 根据姓名查找（模糊查找不准）
    CFIndex recordsCount = CFArrayGetCount(recordsRef);
    for (CFIndex i=0; i<recordsCount; i++)
    {
        ABRecordRef recordRef = CFArrayGetValueAtIndex(recordsRef, i);
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
        int recordId = ABRecordGetRecordID(recordRef);
        NSLog(@"redordRef.id = %i, %@", recordId, lastName);
        if (ABPersonHasImageData(recordRef))
        {
            NSData *imgData = (__bridge NSData*)(ABPersonCopyImageData(recordRef));
        }
        CFRelease(recordRef);
    }
    CFRelease(recordsRef);
    
//    // 增、删、改
//    ABRecordRef recordRef = ABPersonCreate();
//    ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)(@"lc"), NULL);  // 名
//    ABRecordSetValue(recordRef, kABPersonLastNameProperty, (__bridge CFTypeRef)@"iverson", NULL);  // 姓
//    ABMutableMultiValueRef multiValueRef = ABMultiValueCreateMutable(kABStringPropertyType);  // 多值属性
//    ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)@"123", kABHomeLabel, NULL);  // 家庭电话
//    ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)@"abc", kABWorkLabel, NULL);  // 工作电话
//    ABRecordSetValue(recordRef, kABPersonPhoneProperty, multiValueRef, NULL);
//    ABAddressBookAddRecord(addressbook, recordRef, NULL);  // 添加
//    //ABAddressBookRemoveRecord(addressbook, recordRef, NULL);  // 删除
//    //do nothing  // 修改
//    ABAddressBookSave(addressbook, NULL);  // 提交更改保存通讯录
//    CFRelease(recordRef);
//    CFRelease(multiValueRef);
    
    
    // <AddressBookUI/AddressBookUI.h>
    // ABNewPersonViewControllerDelegate, ABUnknownPersonViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate
    //ABPersonViewController *pVC = ...
    //pVC.delegate ...
    //[self presentViewController:pVC animated:YES completion:nil];
    
}


// 发短信
- (void)sendMsg
{
    if ([MFMessageComposeViewController canSendText])  // 可以发送文本信息
    {
        MFMessageComposeViewController *msgVC = [[MFMessageComposeViewController alloc] init];
        msgVC.messageComposeDelegate = self;
        msgVC.recipients = @[@"13430430617", @"abc", @"10086"];  // 收件人
        msgVC.body = @"hello哈啰";  // 内容
        if ([MFMessageComposeViewController canSendSubject])  // 运营商支持主题
        {
            msgVC.subject = @"iOS短信测试 lc";
        }
        if ([MFMessageComposeViewController canSendAttachments])  // 运营商支持附件
        {
            //msgVC.attachments =
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"folder_references/icon_blue.png" ofType:nil];
            NSURL *url = [NSURL fileURLWithPath:path];
            //[msgVC addAttachmentURL:url withAlternateFilename:@"test.png"];
            NSData *data = [NSData dataWithContentsOfURL:url];
            [msgVC addAttachmentData:data typeIdentifier:@"public.image" filename:@"test.png"];
        }
        [self presentViewController:msgVC animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent)
    {
        NSLog(@"短信发送成功");
    }
    else if (result == MessageComposeResultFailed)
    {
        NSLog(@"短信发送失败");
    }
    else if (result == MessageComposeResultCancelled)
    {
        NSLog(@"短信发送取消");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


// 发邮件
- (void)sendMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        [mailVC setToRecipients:@[@"lc@zac.cn", @"123247442@qq.com"]];  // 收件人
        [mailVC setCcRecipients:@[@"1547006334@qq.com"]];  // 抄送人
        [mailVC setBccRecipients:@[@"licheng@zhongan.com"]];  // 密送人
        [mailVC setSubject:@"iOS邮件测试 lc"];  // 主题
        [mailVC setMessageBody:@"<html><body style='background-color:orange;'>hello哈啰</body></html>" isHTML:YES];  // 内容
        NSString *path = [[NSBundle mainBundle] pathForResource:@"folder_references/icon_blue.png" ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [mailVC addAttachmentData:data mimeType:@"image/png" fileName:@"test.png"];  // 附件
        [self presentViewController:mailVC animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultSent:
        {
            NSLog(@"邮件发送成功");
            break;
        }
        case MFMailComposeResultSaved:
        {
            NSLog(@"邮件已保存到草稿箱");
            break;
        }
        case MFMailComposeResultCancelled:
        {
            NSLog(@"邮件发送取消");
            break;
        }
        case MFMailComposeResultFailed:
        {
            NSLog(@"邮件发送失败");
            break;
        }
        default:
            break;
    }
    if (error)
    {
        NSLog(@"邮件发送过程中发生错误，%@", error);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

