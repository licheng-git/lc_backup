//
//  CommunityPubQueue.m
//  mobaxx
//
//  Created by licheng on 16/6/16.
//  Copyright © 2016年 billnie. All rights reserved.
//

#import "CommunityPubQueue.h"
#import "Community.pbobjc.h"
#import "Oss.pbobjc.h"
#import "NetworkManager.h"
#import "DBOperator.h"
#import <CommonCrypto/CommonHMAC.h>
#import "EventBus.h"
#import <BaseFramework.h>

@implementation PubNode_Communit
@end

@implementation PubNode_Forum
@end

@implementation PubNode_Notice
@end


@interface CommunityPubQueue()<EventSyncPublisher>
{
    dispatch_queue_t _serialQueue;
    //dispatch_semaphore_t _semaphore;
}
@end

@implementation CommunityPubQueue

+ (id)sharedQueue {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        self.taskArr = [[NSMutableArray alloc] init];
        _serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);  // 创建串行队
        //_semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)addTask:(PubNode_Communit *)node {
    [self.taskArr addObject:node];
    NSLog(@"task count = %ld", self.taskArr.count);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_sync(_serialQueue, ^{
            PubNode_Communit *node0 = self.taskArr[0];
            [self.taskArr removeObjectAtIndex:0];
            //[self execTask:node0];
            if ([node0 isKindOfClass:[PubNode_Forum class]]) {
                [self execTask_PubForum:node0];
            }
            else if ([node0 isKindOfClass:[PubNode_Notice class]]) {
                [self execTask_PubNotice:node0];
            }
            //dispatch_semaphore_signal(_semaphore);
        });
        //dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    });
}


// 发布论坛帖
- (void)execTask_PubForum:(PubNode_Forum *)node {
    
//    // 图文混排，拆分为文字和图片资源列表  *_* main_queue
//    //NSLog(@"*_* textStorage = %@ ; textStorage.length = %li", node.textStorage, node.textStorage.length);
//    //NSLog(@"*_* textStorage.string = %@ ; textStorage.string.length = %li", node.textStorage.string, node.textStorage.string.length);
//    __block NSMutableArray *resourceArr_temp = [[NSMutableArray alloc] init];
//    [node.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, node.textStorage.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
//        NSLog(@"*_* value = %@; range = (%li,%li) , stop = %d", value, range.location, range.length, stop);
//        if (value && [value isKindOfClass:[NSTextAttachment class]]) {  // 图片
//            NSTextAttachment *taValue = (NSTextAttachment *)value;
//            NSDictionary *dicImg = @{
//                                     @"value": taValue.image,
//                                     @"type": @(MediaType_Image)
//                                     };
//            [resourceArr_temp addObject:dicImg];
//        }
//        else {  // 文字
//            NSString *str = [node.textStorage.string substringWithRange:range];
//            NSDictionary *dicStr = @{
//                                     @"value": str,
//                                     @"type": @(MediaType_None)
//                                     };
//            [resourceArr_temp addObject:dicStr];
//        }
//    }];
    NSMutableArray *resourceArr_temp = [[NSMutableArray alloc] init];
    for (id obj in node.resourceArr) {
        if ([obj isKindOfClass:[UIImage class]]) {  // 图片
            NSDictionary *dicImg = @{
                                      @"value": (UIImage *)obj,
                                      @"type": @(MediaType_Image)
                                      };
             [resourceArr_temp addObject:dicImg];
        }
        else if ([obj isKindOfClass:[NSString class]]) {  // 文字
            NSDictionary *dicStr = @{
                                      @"value": (NSString *)obj,
                                      @"type": @(MediaType_None)
                                      };
             [resourceArr_temp addObject:dicStr];
        }
    }
    
    // 加入音频资源
    if (node.audioPath) {
        NSDictionary *dicAudio = @{
                                   @"value": node.audioPath,
                                   @"type": @(MediaType_Audio)
                                   };
        [resourceArr_temp addObject:dicAudio];
    }
    
    // 加入视频资源
    if (node.videoUrlStr) {
        NSDictionary *dicVideo = @{
                                   @"value": node.videoUrlStr,
                                   @"type": @(MediaType_Video)
                                   };
        [resourceArr_temp addObject:dicVideo];
    }
    
    // 生成提交所需的资源列表
    PCommunityResourceList *pbResourceList = [[PCommunityResourceList alloc] init];
    for (NSDictionary *dic in resourceArr_temp) {
        PCommunityResource *pbResource = [[PCommunityResource alloc] init];
        //MediaType type = (MediaType)((int)dic[@"type"]);  // *_* err
        MediaType type = (MediaType)[dic[@"type"] integerValue];
        id value = dic[@"value"];
        pbResource.type = [self convertSubTypeStr:type];
        if (type == MediaType_None) {  // 文字
            //pbResource.name = [value stringValue];  // *_* err
            pbResource.name = (NSString *)value;
        }
        else if (type == MediaType_Image) {  // 图片，需上传到oss
            UIImage *img = (UIImage *)value;
            NSData *imgData = UIImageJPEGRepresentation(img, 0);
            PUpload *pbUpload_Img = [self uploadWithData:imgData extention:@"jpg"];
            if (!pbUpload_Img) {
                continue;
            }
            pbResource.name = pbUpload_Img.objectKey;
            pbResource.uRL = pbUpload_Img.uRL;
        }
        else if (type == MediaType_Audio) {  // 音频，需上传到oss
            NSString *audioPath = (NSString *)value;
            NSData *audioData = [NSData dataWithContentsOfFile:audioPath];
            PUpload *pbUpload_Audio = [self uploadWithData:audioData extention:@"m4a"];
            if (!pbUpload_Audio) {
                continue;
            }
            pbResource.name = pbUpload_Audio.objectKey;
            pbResource.uRL = pbUpload_Audio.uRL;
            pbResource.size = [NSString stringWithFormat:@"%i", node.audioTotalSeconds];
            // 删除临时文件
            if ([[NSFileManager defaultManager] fileExistsAtPath:audioPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
            }
            // 文件缓存
            NSString *savePath = [NSString stringWithFormat:@"%@/Library/Caches/%@", NSHomeDirectory(), pbUpload_Audio.objectKey];
            CacheModel *cm = [[CacheModel alloc] init];
            cm.serverUrl = [pbUpload_Audio.uRL componentsSeparatedByString:@"?"][0];
            cm.localPath = [NSString stringWithFormat:@"/Library/Caches/%@", pbUpload_Audio.objectKey];
            cm.type = CacheType_Audio;
            cm.name = [NSString stringWithFormat:@"%@", pbUpload_Audio.objectKey];
            cm.extention = @"m4a";
            cm.createtime = [NSDate date];
            if ([audioData writeToFile:savePath atomically:YES] && [[DBOperator shareInstance] saveFileToDbCache:cm]) {
                NSLog(@"文件缓存成功");
            } else {
                NSLog(@"文件缓存失败");
            }
        }
        else if (type == MediaType_Video) {  // 第三方视频
            pbResource.uRL = (NSString *)value;
        }
        [pbResourceList.resourceArray addObject:pbResource];
    }
    
    // 上传论坛帖
    PCommunityPostUpload *pbUpload_Forum = [[PCommunityPostUpload alloc] init];
    pbUpload_Forum.title = node.title;
    pbUpload_Forum.subType = [self convertSubTypeStr:node.subTypeEnum];
    //pbUpload_Forum.hasResourcesList = (node.subTypeEnum != MediaType_None);
    pbUpload_Forum.resourcesList = pbResourceList;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL bSuccess = NO;
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%@", URL_Community_Post_Forum, node.communitId];
    NetworkManager *nm = [[NetworkManager alloc] init];
    nm.fileData = [pbUpload_Forum data];
    [nm requestUrl:urlStr params:nil method:HttpMethodPost targetVC:nil success:^(id resultObj) {
        bSuccess = YES;
        dispatch_semaphore_signal(semaphore);
    } failure:^(id error) {
        bSuccess = NO;
        [self showErr:error];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (!bSuccess) {
        NSLog(@"论坛帖上传失败");
        return;
    }
    nm.fileData = nil;
    NSLog(@"论坛帖上传完成");
    [[EventBus busManager] publish:@"CommunityPubFourm" eventData:nil  by:self life:0.0f];
}


// 上传资源到oss
- (PUpload *)uploadWithData:(NSData *)data extention:(NSString *)extention {
    if (!data || data.length==0) {
        return nil;
    }
    
    // 从应用服务器获取资源oss状态
    NSLog(@"开始请求上传文件");
    NSString *str = [self md5Str:data];
    NSUInteger len= data.length;
    NSDictionary *paramsDic = @{
                                @"digest": str,
                                @"length": [NSString stringWithFormat:@"%@",@(len)],
                                @"extension": extention
                                };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);  // 在业务层的队列中加锁来实现同步请求
    __block PUpload *pbUpload = nil;
    __block BOOL bSuccess = NO;
    NetworkManager *nm = [[NetworkManager alloc] init];
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
        NSLog(@"获取文件oss状态失败");
        return nil;
    }
    NSLog(@"应用服务器已经生成oss上传地址，准备上传文件");
    
    // 检查资源状态
    if (pbUpload.exists) {
        NSLog(@"文件在oss上已经存在，不需要上传");
        return pbUpload;
    }
    
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
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    nm.fileData = nil;
    nm.headersDic = nil;
    if (!bSuccess) {
        NSLog(@"文件上传失败");
        return nil;
    }
    NSLog(@"文件上传oss成功（继续上传文件key到应用服务器）");

    return pbUpload;
}


// 本地枚举转化为服务端参数
- (NSString *)convertSubTypeStr:(MediaType)subTypeEnum {
    NSString *subTypeStr;
    if (subTypeEnum == MediaType_None) {
        subTypeStr = @"txt";
    }
    else if (subTypeEnum == MediaType_Image) {
        subTypeStr = @"img";
    }
    else if (subTypeEnum == MediaType_Audio) {
        subTypeStr = @"audio";
    }
    else if (subTypeEnum == MediaType_Video) {
        subTypeStr = @"video";
    }
    return subTypeStr;
}


//#define MD5DATA(x,y) \
//{ NSInteger len; len = [x length]; \
//const char *cStr = [x bytes]; \
//unsigned char result[16];\
//CC_MD5(cStr, (CC_LONG)len, result);\
//y= [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2],\
//result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];\
//}\

// md5
- (NSString *)md5Str:(NSData *)data {
    NSInteger len = data.length;
    const char *cStr = [data bytes];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)len, result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2],result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

// 服务端错误提示
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


// 发布公告贴
- (void)execTask_PubNotice:(PubNode_Notice *)node {
    
    // 生成提交所需的资源列表
    PCommunityResourceList *pbResourceList = [[PCommunityResourceList alloc] init];
    for (id resourceObj in node.resourceArr) {  // 模板，公告详情+图文混排内容
        PCommunityResource *pbResource = [[PCommunityResource alloc] init];
        if ([resourceObj isKindOfClass:[NSString class]]) {  // 文字
            NSString *resourceStr = (NSString *)resourceObj;
            pbResource.type = @"txt";
            pbResource.name = resourceStr;
        }
        else if ([resourceObj isKindOfClass:[UIImage class]]) {  // 图片，需上传到oss
            UIImage *resourceImg = (UIImage *)resourceObj;
            pbResource.type = @"img";
            NSData *imgData = UIImageJPEGRepresentation(resourceImg, 0);
            PUpload *pbUpload_Img = [self uploadWithData:imgData extention:@"jpg"];
            if (pbUpload_Img) {
                pbResource.name = pbUpload_Img.objectKey;
                pbResource.uRL = pbUpload_Img.uRL;
            }
        }
        [pbResourceList.resourceArray addObject:pbResource];
    }
    if (node.imgPoster) {  // 海报图片
        PCommunityResource *pbResource = [[PCommunityResource alloc] init];
        pbResource.type = @"img";
        NSData *imgData = UIImageJPEGRepresentation(node.imgPoster, 0);
        PUpload *pbUpload_ImgPoster = [self uploadWithData:imgData extention:@"jpg"];
        if (pbUpload_ImgPoster) {
            pbResource.name = pbUpload_ImgPoster.objectKey;
            pbResource.uRL = pbUpload_ImgPoster.uRL;
        }
        [pbResourceList.resourceArray addObject:pbResource];
    }
    if (node.link && node.link.length>0) {  // 模板和海报，公告链接
        PCommunityResource *pbResource = [[PCommunityResource alloc] init];
        pbResource.type = @"link";
        pbResource.uRL = node.link;
        [pbResourceList.resourceArray addObject:pbResource];
    }
    
    // 上传公告帖
    PCommunityPostUpload *pbUpload_Notice = [[PCommunityPostUpload alloc] init];
    pbUpload_Notice.title = node.title;
    pbUpload_Notice.subType = node.imgPoster ? @"poster" : @"mould";  // 模版mould；海报poster
    pbUpload_Notice.resourcesList = pbResourceList;
    if (node.imgBanner) {  // 上传banner图
        NSData *imgData_banner = UIImageJPEGRepresentation(node.imgBanner, 0);
        PUpload *pbUpload_ImgBanner = [self uploadWithData:imgData_banner extention:@"jpg"];
        if (pbUpload_ImgBanner) {
            pbUpload_Notice.bannerImg = pbUpload_ImgBanner.objectKey;
        }
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL bSuccess = NO;
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%@&replaceid=%@", URL_Community_Post_Notice, node.communitId, node.replaceId];  // 公告帖子 新建;
    HttpMethod hm = HttpMethodPost;
    if (node.type == PubType_Edit) {  // 公告帖子 修改
        urlStr = [NSString stringWithFormat:@"%@?id=%@&postid=%@&replaceid=%@", URL_Community_Post_Notice, node.communitId, node.postId, node.replaceId];
        hm = HttpMethodPut;
    }
    else if (node.type == PubType_Background) {  // 社区背景介绍
        urlStr = [NSString stringWithFormat:@"%@?id=%@", URL_Community_Post_Background, node.communitId];
        hm = HttpMethodPost;
    }
    NetworkManager *nm = [[NetworkManager alloc] init];
    nm.fileData = [pbUpload_Notice data];
    [nm requestUrl:urlStr params:nil method:hm targetVC:nil success:^(id resultObj) {
        bSuccess = YES;
        dispatch_semaphore_signal(semaphore);
    } failure:^(id error) {
        bSuccess = NO;
        [self showErr:error];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (!bSuccess) {
        NSLog(@"公告帖上传失败");
        return;
    }
    nm.fileData = nil;
    NSLog(@"公告帖上传完成");
    [[EventBus busManager] publish:@"CommunityPubNotice" eventData:nil  by:self life:0.0f];
}

@end
