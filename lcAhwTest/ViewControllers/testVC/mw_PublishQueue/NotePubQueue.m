//
//  NotePubQueue.m
//  mobaxx
//
//  Created by billnie on 1/4/2016.
//  Copyright © 2016 billnie. All rights reserved.
//

#import "NotePubQueue.h"
#include <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>
#import "CommonDefines.h"


@implementation PubNode
@end


@interface NotePubQueue()<EventSyncPublisher>
{
    dispatch_queue_t _serialQueue;
    //dispatch_semaphore_t sem;
}

@end

@implementation NotePubQueue

+ (instancetype)sharedPubQueue {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        self.taskArr = [[NSMutableArray alloc] init];
        _serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);  // 创建串行队
        //sem = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)addPubTask:(PubNode *)node {
    [self.taskArr addObject:node];
    DLog(@"task count = %ld", self.taskArr.count);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_sync(_serialQueue, ^{
            PubNode *node0 = self.taskArr[0];
            [self.taskArr removeObjectAtIndex:0];
            [self execTask:node0];
            //dispatch_semaphore_signal(sem);
        });
        //dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    });
}

- (void)execTask:(PubNode *)node {
    [self postNote:node notify:^(NSInteger cmd, NSString *str, NSDictionary *dic) {
        DLog(@"%ld, %@, %@", cmd, str, dic);
         if (cmd == 100) {
             [[EventBus busManager] publish:@"pubNote" eventData:@{@"message":@"帖子发送完成",@"cmd":@(KPubTopicCMD)}  by:self life:0.0f];
        }
    }];
}

- (void)postNote:(PubNode *)node notify:(void (^)(NSInteger cmd, NSString *str, NSDictionary *dic))completion {
    switch (node.artType) {
        case PArticleTypeTxt:
        {
            PPostInfo *pbArticle = [[PPostInfo alloc] init];
            pbArticle.content = node.text;
            pbArticle.position = node.location;
            
            //@用户
            if (node.atUserList.count > 0 ) {
                PAtUserList *atList = [[PAtUserList alloc] init];
                for (PUser *user in node.atUserList) {
                    PAtUser *atUser = [[PAtUser alloc] init];
                    atUser.uuid = user.uuid;
                    atUser.nickName = user.nickname;
                    [atList.listArray addObject:atUser];
                }
                pbArticle.atusers = atList;
            }
            
            NSData *data = [pbArticle data];
            NetworkManager *manager = [[NetworkManager alloc] init];
            manager.fileData = data;
            [manager requestUrl:URL_Publish params:nil method:HttpMethodPost targetVC:nil success:^(id resultObj) {
                completion(100, @"帖子上传完成", nil);
            } failure:^(id error) {
                DLog(@"帖子上传失败");
                [self showErr:error];
            }];
        }
            break;
        case PArticleTypeImage:
        {
            // 从应用服务器获取资源oss状态
            NSMutableArray *fileInfoArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < node.tempImageData.count; i++) {
                NSData *imageData = [node.tempImageData objectAtIndex:i];
                NSString *imageMD5Str = @"";
                MD5DATA(imageData, imageMD5Str);
                
                PFileInfo *fileInfo = [[PFileInfo alloc] init];
                fileInfo.digest = imageMD5Str;
                fileInfo.length = (int)imageData.length;
                fileInfo.extension = @"jpg";
                [fileInfoArray addObject:fileInfo];
            }
            
            PFileInfoArray *infoArray = [[PFileInfoArray alloc] init];
            infoArray.fileInfosArray = fileInfoArray;
            __block PUploadArray *pbUploadArray = nil;
            __block BOOL bSuccess = NO;
            NetworkManager *netRequest = [NetworkManager new];
            netRequest.fileData = [infoArray data];
            //nm.bAsync = NO;  // 同步请求
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);  // 在业务层的队列中加锁来实现同步请求
            [netRequest requestUrl:URL_OssStatusMulti params:nil method:HttpMethodPost targetVC:nil success:^(id resultObj) {
                pbUploadArray = (PUploadArray *)resultObj;
                bSuccess = YES;
                dispatch_semaphore_signal(semaphore);
            } failure:^(id error) {
                bSuccess = NO;
                dispatch_semaphore_signal(semaphore);
            }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (!bSuccess) {
                DLog(@"获取资源oss状态失败，不再执行上传资源操作");
                return;
            }
            
            netRequest.fileData = nil;
            completion(10, @"应用服务器已经生成oss上传地址，准备上传文件", nil);
            
            // 循环上传
            NSMutableArray *imgArr = [[NSMutableArray alloc] init];
            int cmd_single = 60/pbUploadArray.uploadsArray.count;
            for (int i=0; i<pbUploadArray.uploadsArray.count; i++) {
                PUpload *pbUpload = pbUploadArray.uploadsArray[i];
                if (!pbUpload.exists) {
                    netRequest.fileData = node.tempImageData[i];
                    NSMutableDictionary *tempHeadersDic = [[NSMutableDictionary alloc] init];
                    for (NSString *headerStr in pbUpload.headersArray) {
                        NSArray *array =[headerStr componentsSeparatedByString:@":"];
                        if (array.count > 0) {
                            [tempHeadersDic setObject:array[1] forKey:array[0]];
                        }
                    }
                    netRequest.headersDic = tempHeadersDic;
                    __block BOOL bSuccess_single = NO;
                    [netRequest requestUrl:pbUpload.uRL params:nil method:HttpMethodPut targetVC:nil success:^(id resultObj) {
                        bSuccess_single = YES;
                        dispatch_semaphore_signal(semaphore);
                    } failure:^(id error) {
                        bSuccess_single = NO;
                        [self showErr:error];
                        dispatch_semaphore_signal(semaphore);
                    }];
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    if (!bSuccess_single) {
                        DLog(@"单个图片上传失败 %@", pbUpload.objectKey);
                        return;  // 单个图片上传失败,不继续发帖
                    }
                    
                    completion(10+cmd_single*(i+1), [NSString stringWithFormat:@"上传文件%d/%lu到服务器", i+1, pbUploadArray.uploadsArray.count], nil);
                    netRequest.fileData = nil;
                    netRequest.headersDic = nil;
                }
                
                PImage *pbImage = [PImage new];
                pbImage.tags = [node.imageMarkData objectAtIndex:i];
                pbImage.uRL = pbUpload.objectKey;
                pbImage.des = [node.picDescDict objectForKey:[NSString stringWithFormat:@"desc%d", i]];
                [imgArr addObject:pbImage];
            }
            
            // 帖子上传到应用服务器（文字，图片描述，文件key、、、）
            PPostInfo *pbArticle = [PPostInfo new];
            pbArticle.content = node.text;
            pbArticle.position = node.location;
            pbArticle.srcType = @"image";
            pbArticle.imagesArray = imgArr;
            
            //@用户
            if (node.atUserList.count > 0 ) {
                PAtUserList *atList = [[PAtUserList alloc] init];
                for (PUser *user in node.atUserList) {
                    PAtUser *atUser = [[PAtUser alloc] init];
                    atUser.uuid = user.uuid;
                    atUser.nickName = user.nickname;
                    [atList.listArray addObject:atUser];
                }
                pbArticle.atusers = atList;
            }

            netRequest.fileData = [pbArticle data];
            __block PUpload *pbUpload;
            bSuccess = NO;
            [netRequest requestUrl:URL_Publish params:nil method:HttpMethodPost targetVC:nil success:^(id resultObj) {
                pbUpload = (PUpload *)resultObj;
                bSuccess = YES;
                dispatch_semaphore_signal(semaphore);
            } failure:^(id error) {
                bSuccess = NO;
                [self showErr:error];
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (!bSuccess) {
                DLog(@"帖子上传失败");
                return;
            }
            netRequest.fileData = nil;
            completion(100, @"帖子上传完成", nil);
        }
            break;
//        case PArticleTypeAudio:
//        case PArticleTypeVideo:
//        {
//            //NSData *data = [NSData dataWithContentsOfFile:node.filePath];
//            //NSString *extension = node.filePath.pathExtension;
//            NSData *data = node.fileData;
//            NSString *extension;
//            if (node.artType == PArticleTypeAudio) {
//                extension = @"m4a";
//            }
//            else if (node.artType == PArticleTypeVideo) {
//                extension = @"mov";
//            }
//            if (!data || data.length==0) {
//                DLog(@"帖子上传失败");
//                return;
//            }
//            completion(1, @"开始请求上传文件", nil);
//            
//            // 从应用服务器获取资源oss状态
//            NSString *str;
//            MD5DATA(data, str);
//            NSUInteger len = data.length;
//            NSDictionary *paramsDic = @{
//                                       @"digest": str,
//                                       @"length": [NSString stringWithFormat:@"%@",@(len)],
//                                       @"extension": extension
//                                    };
//            __block PUpload *pbUpload = nil;
//            __block BOOL bSuccess = NO;
//            NetworkManager *nm = [NetworkManager new];
//            //nm.bAsync = NO;  // 同步请求
//            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);  // 在业务层的队列中加锁来实现同步请求
//            [nm requestUrl:URL_OssStatus params:paramsDic method:HttpMethodGet targetVC:nil success:^(id resultObj) {
//                pbUpload = (PUpload *)resultObj;
//                bSuccess = YES;
//                dispatch_semaphore_signal(semaphore);
//            } failure:^(id error) {
//                pbUpload = nil;
//                bSuccess = NO;
//                dispatch_semaphore_signal(semaphore);
//            }];
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//            if (!bSuccess) {
//                DLog(@"获取资源oss状态失败");
//                return;
//            }
//            completion(10, @"应用服务器已经生成oss上传地址，准备上传文件", nil);
//            
//            // 上传文件到oss
//            nm = [NetworkManager new];
//            nm.fileData = data;
//            NSMutableDictionary *tempHeadersDic = [[NSMutableDictionary alloc] init];
//            for (NSString *headerStr in pbUpload.headersArray) {
//                NSArray *array =[headerStr componentsSeparatedByString:@":"];
//                if (array.count > 0) {
//                    [tempHeadersDic setObject:array[1] forKey:array[0]];
//                }
//            }
//            nm.headersDic = tempHeadersDic;
//            bSuccess = NO;
//            [nm requestUrl:pbUpload.uRL params:nil method:HttpMethodPut targetVC:nil success:^(id resultObj) {
//                bSuccess = YES;
//                dispatch_semaphore_signal(semaphore);
//            } failure:^(id error) {
//                bSuccess = NO;
//                dispatch_semaphore_signal(semaphore);
//            }];
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//            if (!bSuccess) {
//                DLog(@"帖子上传失败");
//                return;
//            }
//            nm.fileData = nil;
//            nm.headersDic = nil;
//            completion(80, @"文件上传oss成功，继续上传文件key到应用服务器", nil);
//            
//            PPostInfo *pbArticle = [[PPostInfo alloc] init];
//            if (node.artType == PArticleTypeVideo) {
//                pbArticle.srcType = @"video";
//                pbArticle.video.uRL = pbUpload.objectKey;
//                
//                // 上传视频缩略图到oss
//                //NSData *data_thumb = [self videoThumbnail:node.filePath];
//                NSData *data_thumb = node.videoThumbData;
//                if (data_thumb) {
//                    NSString *str_thumb;
//                    MD5DATA(data_thumb, str_thumb);
//                    NSUInteger len_thumb = data_thumb.length;
//                    NSDictionary *paramsDic_thumb = @{
//                                                 @"digest": str_thumb,
//                                                 @"length": [NSString stringWithFormat:@"%@",@(len_thumb)],
//                                                 @"extension": @"jpg"
//                                                 };
//                    __block PUpload *pbUpload_thumb = nil;
//                    __block BOOL bSuccess_thumb = NO;
//                    nm = [NetworkManager new];
//                    [nm requestUrl:URL_OssStatus params:paramsDic_thumb method:HttpMethodGet targetVC:nil success:^(id resultObj) {
//                        pbUpload_thumb = (PUpload *)resultObj;
//                        //bSuccess = YES;
//                        bSuccess_thumb = YES;
//                        dispatch_semaphore_signal(semaphore);
//                    } failure:^(id error) {
//                        pbUpload_thumb = nil;
//                        //bSuccess = NO;  // 缩略图上传失败不应该影响发帖
//                        bSuccess_thumb = NO;
//                        dispatch_semaphore_signal(semaphore);
//                    }];
//                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//                    if (bSuccess_thumb) {
//                        nm = [NetworkManager new];
//                        nm.fileData = data_thumb;
//                        NSMutableDictionary *tempHeadersDic = [[NSMutableDictionary alloc] init];
//                        for (NSString *headerStr in pbUpload_thumb.headersArray) {
//                            NSArray *array =[headerStr componentsSeparatedByString:@":"];
//                            if (array.count > 0) {
//                                [tempHeadersDic setObject:array[1] forKey:array[0]];
//                            }
//                        }
//                        nm.headersDic = tempHeadersDic;
//                        bSuccess_thumb = NO;
//                        [nm requestUrl:pbUpload_thumb.uRL params:nil method:HttpMethodPut targetVC:nil success:^(id resultObj) {
//                            bSuccess_thumb = YES;
//                            dispatch_semaphore_signal(semaphore);
//                        } failure:^(id error) {
//                            bSuccess_thumb = NO;
//                            dispatch_semaphore_signal(semaphore);
//                        }];
//                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//                        nm.fileData = nil;
//                        nm.headersDic = nil;
//                        if (bSuccess_thumb) {
//                            pbArticle.video.img = pbUpload_thumb.objectKey;
//                        }
//                    }
//                }
//                
//            }
//            else {
//                pbArticle.srcType = @"audio";
//                pbArticle.audio.uRL = pbUpload.objectKey;
//                pbArticle.audio.length = node.mediaTm;
//                pbArticle.audio.expires = node.mediaexpiresTm;
//            }
//            
//            // 帖子上传到应用服务器（文字，文件key、、、）
//            pbArticle.content = node.text;
//            pbArticle.position = node.location;
//            
//            //@用户
//            if (node.atUserList.count > 0 ) {
//                PAtUserList *atList = [[PAtUserList alloc] init];
//                for (PUser *user in node.atUserList) {
//                    PAtUser *atUser = [[PAtUser alloc] init];
//                    atUser.uuid = user.uuid;
//                    atUser.nickName = user.nickname;
//                    [atList.listArray addObject:atUser];
//                }
//                pbArticle.atusers = atList;
//            }
//
//            nm = [NetworkManager new];
//            nm.fileData = [pbArticle data];
//            bSuccess = NO;
//            __block PUpload *pbUpload_article = nil;
//            [nm requestUrl:URL_Publish params:nil method:HttpMethodPost targetVC:nil success:^(id resultObj) {
//                pbUpload_article = (PUpload *)resultObj;
//                bSuccess = YES;
//                dispatch_semaphore_signal(semaphore);
//            } failure:^(id error) {
//                pbUpload_article = nil;
//                bSuccess = NO;
//                [self showErr:error];
//                dispatch_semaphore_signal(semaphore);
//            }];
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//            if (!bSuccess) {
//                DLog(@"帖子上传失败");
//                return;
//            }
//            nm.fileData = nil;
//            completion(100, @"帖子上传完成", nil);
//            
//            // 文件缓存
//            NSString *savePath = [NSString stringWithFormat:@"%@/Library/Caches/%@", NSHomeDirectory(), pbUpload.objectKey];
//            CacheModel *cm = [[CacheModel alloc] init];
//            cm.serverUrl = [pbUpload.uRL componentsSeparatedByString:@"?"][0];
//            cm.localPath = [NSString stringWithFormat:@"/Library/Caches/%@", pbUpload.objectKey];
//            cm.type = (node.artType == PArticleTypeVideo) ? CacheType_Audio : CacheType_Video;
//            cm.name = [NSString stringWithFormat:@"%@", pbUpload.objectKey];
//            cm.extention = extension;
//            cm.createtime = [NSDate date];
//            if ([data writeToFile:savePath atomically:YES] && [[DBOperator shareInstance] saveFileToDbCache:cm]) {
//                DLog(@"文件缓存成功");
//            } else {
//                DLog(@"文件缓存失败");
//            }
//            
//            //// 删除临时文件
//            //if ([[NSFileManager defaultManager] fileExistsAtPath:node.filePath]) {
//            //    [[NSFileManager defaultManager] removeItemAtPath:node.filePath error:nil];
//            //}
//            
//        }
//            break;
        case PArticleTypeAudio:
        {
            //NSData *data = [NSData dataWithContentsOfFile:node.filePath];
            //NSString *extension = node.filePath.pathExtension;
            NSData *data = node.fileData;
            NSString *extension = @"m4a";
            if (!data || data.length==0) {
                DLog(@"帖子上传失败");
                return;
            }
            completion(1, @"开始请求上传文件", nil);
            
            // 从应用服务器获取资源oss状态
            NSString *str;
            MD5DATA(data, str);
            NSUInteger len = data.length;
            NSDictionary *paramsDic = @{
                                        @"digest": str,
                                        @"length": [NSString stringWithFormat:@"%@",@(len)],
                                        @"extension": extension
                                        };
            __block PUpload *pbUpload = nil;
            __block BOOL bSuccess = NO;
            NetworkManager *nm = [NetworkManager new];
            //nm.bAsync = NO;  // 同步请求
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);  // 在业务层的队列中加锁来实现同步请求
            [nm requestUrl:URL_OssStatus params:paramsDic method:HttpMethodGet targetVC:nil success:^(id resultObj) {
                pbUpload = (PUpload *)resultObj;
                bSuccess = YES;
                dispatch_semaphore_signal(semaphore);
            } failure:^(id error) {
                pbUpload = nil;
                bSuccess = NO;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (!bSuccess) {
                DLog(@"获取资源oss状态失败");
                return;
            }
            completion(10, @"应用服务器已经生成oss上传地址，准备上传文件", nil);
            
            // 上传文件到oss
            nm = [NetworkManager new];
            nm.fileData = data;
            NSMutableDictionary *tempHeadersDic = [[NSMutableDictionary alloc] init];
            for (NSString *headerStr in pbUpload.headersArray) {
                NSArray *array =[headerStr componentsSeparatedByString:@":"];
                if (array.count > 0) {
                    [tempHeadersDic setObject:array[1] forKey:array[0]];
                }
            }
            nm.headersDic = tempHeadersDic;
            bSuccess = NO;
            [nm requestUrl:pbUpload.uRL params:nil method:HttpMethodPut targetVC:nil success:^(id resultObj) {
                bSuccess = YES;
                dispatch_semaphore_signal(semaphore);
            } failure:^(id error) {
                bSuccess = NO;
                [self showErr:error];
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (!bSuccess) {
                DLog(@"帖子上传失败");
                return;
            }
            nm.fileData = nil;
            nm.headersDic = nil;
            completion(80, @"文件上传oss成功，继续上传文件key到应用服务器", nil);
            
            // 帖子上传到应用服务器
            PPostInfo *pbArticle = [[PPostInfo alloc] init];
            pbArticle.content = node.text;
            pbArticle.position = node.location;
            if (node.atUserList.count > 0 ) {
                PAtUserList *atList = [[PAtUserList alloc] init];
                for (PUser *user in node.atUserList) {
                    PAtUser *atUser = [[PAtUser alloc] init];
                    atUser.uuid = user.uuid;
                    atUser.nickName = user.nickname;
                    [atList.listArray addObject:atUser];
                }
                pbArticle.atusers = atList;
            }
            pbArticle.srcType = @"audio";
            pbArticle.audio.uRL = pbUpload.objectKey;
            pbArticle.audio.length = node.mediaTm;
            pbArticle.audio.expires = node.mediaexpiresTm;
            
            
            nm = [NetworkManager new];
            nm.fileData = [pbArticle data];
            bSuccess = NO;
            __block PUpload *pbUpload_article = nil;
            [nm requestUrl:URL_Publish params:nil method:HttpMethodPost targetVC:nil success:^(id resultObj) {
                pbUpload_article = (PUpload *)resultObj;
                bSuccess = YES;
                dispatch_semaphore_signal(semaphore);
            } failure:^(id error) {
                pbUpload_article = nil;
                bSuccess = NO;
                [self showErr:error];
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (!bSuccess) {
                DLog(@"帖子上传失败");
                return;
            }
            nm.fileData = nil;
            completion(100, @"帖子上传完成", nil);
            
            // 文件缓存
            NSString *savePath = [NSString stringWithFormat:@"%@/Library/Caches/%@", NSHomeDirectory(), pbUpload.objectKey];
            CacheModel *cm = [[CacheModel alloc] init];
            cm.serverUrl = [pbUpload.uRL componentsSeparatedByString:@"?"][0];
            cm.localPath = [NSString stringWithFormat:@"/Library/Caches/%@", pbUpload.objectKey];
            cm.type = CacheType_Audio;
            cm.name = [NSString stringWithFormat:@"%@", pbUpload.objectKey];
            cm.extention = extension;
            cm.createtime = [NSDate date];
            if ([data writeToFile:savePath atomically:YES] && [[DBOperator shareInstance] saveFileToDbCache:cm]) {
                DLog(@"文件缓存成功");
            } else {
                DLog(@"文件缓存失败");
            }
            
            //// 删除临时文件
            //if ([[NSFileManager defaultManager] fileExistsAtPath:node.filePath]) {
            //    [[NSFileManager defaultManager] removeItemAtPath:node.filePath error:nil];
            //}
        }
            break;
        case PArticleTypeVideo:
        {
            // 帖子上传参数（文件key，文字，地理位置，@用户、、、）
            PPostInfo *pbArticle = [[PPostInfo alloc] init];
            pbArticle.content = node.text;
            pbArticle.position = node.location;
            if (node.atUserList.count > 0 ) {
                PAtUserList *atList = [[PAtUserList alloc] init];
                for (PUser *user in node.atUserList) {
                    PAtUser *atUser = [[PAtUser alloc] init];
                    atUser.uuid = user.uuid;
                    atUser.nickName = user.nickname;
                    [atList.listArray addObject:atUser];
                }
                pbArticle.atusers = atList;
            }
            pbArticle.srcType = @"video";
            
            __block PUpload *pbUpload = nil;
            __block BOOL bSuccess = NO;
            NetworkManager *nm = [NetworkManager new];
            //nm.bAsync = NO;  // 同步请求
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);  // 在业务层的队列中加锁来实现同步请求
            
            if (node.videoLinkThird && node.videoLinkThird.length>0) {  // 第三方视频链接
                pbArticle.video.uRL = node.videoLinkThird;
                pbArticle.video.type = 1;
            }else {  // 本地录制的视频
                NSData *data = node.fileData;
                NSString *extension = @"mov";
                if (!data || data.length==0) {
                    DLog(@"帖子上传失败");
                    return;
                }
                completion(1, @"开始请求上传文件", nil);
                
                // 从应用服务器获取资源oss状态
                NSString *str;
                MD5DATA(data, str);
                NSUInteger len = data.length;
                NSDictionary *paramsDic = @{
                                            @"digest": str,
                                            @"length": [NSString stringWithFormat:@"%@",@(len)],
                                            @"extension": extension
                                            };
                [nm requestUrl:URL_OssStatus params:paramsDic method:HttpMethodGet targetVC:nil success:^(id resultObj) {
                    pbUpload = (PUpload *)resultObj;
                    bSuccess = YES;
                    dispatch_semaphore_signal(semaphore);
                } failure:^(id error) {
                    pbUpload = nil;
                    bSuccess = NO;
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                if (!bSuccess) {
                    DLog(@"获取资源oss状态失败");
                    return;
                }
                completion(10, @"应用服务器已经生成oss上传地址，准备上传文件", nil);
                
                // 上传文件到oss
                nm = [NetworkManager new];
                nm.fileData = data;
                NSMutableDictionary *tempHeadersDic = [[NSMutableDictionary alloc] init];
                for (NSString *headerStr in pbUpload.headersArray) {
                    NSArray *array =[headerStr componentsSeparatedByString:@":"];
                    if (array.count > 0) {
                        [tempHeadersDic setObject:array[1] forKey:array[0]];
                    }
                }
                nm.headersDic = tempHeadersDic;
                bSuccess = NO;
                [nm requestUrl:pbUpload.uRL params:nil method:HttpMethodPut targetVC:nil success:^(id resultObj) {
                    bSuccess = YES;
                    dispatch_semaphore_signal(semaphore);
                } failure:^(id error) {
                    bSuccess = NO;
                    [self showErr:error];
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                if (!bSuccess) {
                    DLog(@"帖子上传失败");
                    return;
                }
                nm.fileData = nil;
                nm.headersDic = nil;
                completion(80, @"文件上传oss成功，继续上传文件key到应用服务器", nil);
                pbArticle.video.uRL = pbUpload.objectKey;  // 上传oss成功后设置文件key上传到应用服务器
                pbArticle.video.type = 0;
                
                // 上传视频缩略图到oss
                NSData *data_thumb = node.videoThumbData;
                if (data_thumb) {
                    NSString *str_thumb;
                    MD5DATA(data_thumb, str_thumb);
                    NSUInteger len_thumb = data_thumb.length;
                    NSDictionary *paramsDic_thumb = @{
                                                      @"digest": str_thumb,
                                                      @"length": [NSString stringWithFormat:@"%@",@(len_thumb)],
                                                      @"extension": @"jpg"
                                                      };
                    __block PUpload *pbUpload_thumb = nil;
                    __block BOOL bSuccess_thumb = NO;
                    nm = [NetworkManager new];
                    [nm requestUrl:URL_OssStatus params:paramsDic_thumb method:HttpMethodGet targetVC:nil success:^(id resultObj) {
                        pbUpload_thumb = (PUpload *)resultObj;
                        //bSuccess = YES;
                        bSuccess_thumb = YES;
                        dispatch_semaphore_signal(semaphore);
                    } failure:^(id error) {
                        pbUpload_thumb = nil;
                        //bSuccess = NO;  // 缩略图上传失败不应该影响发帖
                        bSuccess_thumb = NO;
                        dispatch_semaphore_signal(semaphore);
                    }];
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    if (bSuccess_thumb) {
                        nm = [NetworkManager new];
                        nm.fileData = data_thumb;
                        NSMutableDictionary *tempHeadersDic = [[NSMutableDictionary alloc] init];
                        for (NSString *headerStr in pbUpload_thumb.headersArray) {
                            NSArray *array =[headerStr componentsSeparatedByString:@":"];
                            if (array.count > 0) {
                                [tempHeadersDic setObject:array[1] forKey:array[0]];
                            }
                        }
                        nm.headersDic = tempHeadersDic;
                        bSuccess_thumb = NO;
                        [nm requestUrl:pbUpload_thumb.uRL params:nil method:HttpMethodPut targetVC:nil success:^(id resultObj) {
                            bSuccess_thumb = YES;
                            dispatch_semaphore_signal(semaphore);
                        } failure:^(id error) {
                            bSuccess_thumb = NO;
                            dispatch_semaphore_signal(semaphore);
                        }];
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        nm.fileData = nil;
                        nm.headersDic = nil;
                        if (bSuccess_thumb) {
                            pbArticle.video.img = pbUpload_thumb.objectKey;
                        }
                    }
                }
            }
            
            // 帖子上传到应用服务器
            nm = [NetworkManager new];
            nm.fileData = [pbArticle data];
            bSuccess = NO;
            __block PUpload *pbUpload_article = nil;
            [nm requestUrl:URL_Publish params:nil method:HttpMethodPost targetVC:nil success:^(id resultObj) {
                pbUpload_article = (PUpload *)resultObj;
                bSuccess = YES;
                dispatch_semaphore_signal(semaphore);
            } failure:^(id error) {
                pbUpload_article = nil;
                bSuccess = NO;
                [self showErr:error];
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (!bSuccess) {
                DLog(@"帖子上传失败");
                return;
            }
            nm.fileData = nil;
            completion(100, @"帖子上传完成", nil);
            
            if (node.fileData && node.fileData.length>0) {  // 本地录制的视频
                // 文件缓存
                NSString *savePath = [NSString stringWithFormat:@"%@/Library/Caches/%@", NSHomeDirectory(), pbUpload.objectKey];
                CacheModel *cm = [[CacheModel alloc] init];
                cm.serverUrl = [pbUpload.uRL componentsSeparatedByString:@"?"][0];
                cm.localPath = [NSString stringWithFormat:@"/Library/Caches/%@", pbUpload.objectKey];
                cm.type = CacheType_Video;
                cm.name = [NSString stringWithFormat:@"%@", pbUpload.objectKey];
                cm.extention = @"mov";
                cm.createtime = [NSDate date];
                if ([node.fileData writeToFile:savePath atomically:YES] && [[DBOperator shareInstance] saveFileToDbCache:cm]) {
                    DLog(@"文件缓存成功");
                } else {
                    DLog(@"文件缓存失败");
                }
            }
            
        }
            break;
        default:
            break;
    }
}

- (NSData *)videoThumbnail:(NSString *)filePath
{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *assetImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    NSError *err;
    NSData *data = nil;
    CGImageRef cgImgRef_Media = [assetImageGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil error:&err];
    if (!err)
    {
        UIImage *img = [UIImage imageWithCGImage:cgImgRef_Media];
        CGImageRelease(cgImgRef_Media);
        data = UIImageJPEGRepresentation(img, 1);
    }
    return data;
}

- (void)showErr:(id)error {
    if (![error isKindOfClass:PResult.class]) {
        return;
    }
    
    PResult *pbResult_Err = (PResult *)error;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    dispatch_async(dispatch_get_main_queue(),^{
        //[MBProgressHUDHelper showHUDAlterMessage:pbResult_Err.errorMsg withView:keyWindow];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = MWErrMsg(pbResult_Err.errorCode);
        [hud show:YES];
        [hud hide:YES afterDelay:3.0];
    });
}

@end
