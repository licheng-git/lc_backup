//
//  NotePubQueue.h
//  mobaxx
//
//  Created by billnie on 1/4/2016.
//  Copyright © 2016 billnie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaseFramework/BaseFramework.h>

@interface PubNode : NSObject

@property (nonatomic, assign)  NSInteger            artType;           // 帖子类型
@property (nonatomic, strong)  NSString             *text;             // 文字内容
@property (nonatomic, strong)  NSMutableArray       *tempImageData;    // 图片帖子数据
@property (nonatomic, strong)  NSMutableArray       *imageMarkData;    // 图片标签数据
@property (nonatomic, strong)  NSMutableArray       *atUserList;       // @用户列表
@property (nonatomic, strong)  NSMutableDictionary  *picDescDict;      // 图片帖子描述
//@property (nonatomic, strong)  NSString             *filePath;         // 语音或视频文件路径  *_*连续发送会覆盖
@property (nonatomic, strong)  NSData               *fileData;         // 语音或视频文件内容
@property (nonatomic, strong)  NSData               *videoThumbData;   // 视频缩略图
@property (nonatomic, strong)  NSString             *videoLinkThird;   // 第三方视频地址
@property (nonatomic, assign)  int32_t              mediaTm;           // 音频或视频的时长
@property (nonatomic, assign)  int32_t              mediaexpiresTm;    // 音频或视频的有效期（多少秒之后过期）
@property (nonatomic, strong)  NSString             *location;         // 地理定位

@end


@interface NotePubQueue : NSObject

@property (atomic, strong) NSMutableArray *taskArr;

+ (instancetype)sharedPubQueue;

- (void)addPubTask:(PubNode *)node;

- (NSData *)videoThumbnail:(NSString *)filePath;

@end
