//
//  CommunityPubQueue.h
//  mobaxx
//
//  Created by licheng on 16/6/16.
//  Copyright © 2016年 billnie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// 基类，论坛帖与公告贴公用发布队列
@interface PubNode_Communit : NSObject

@property (nonatomic, strong)  NSString  *communitId;  // 社区id

@end


// 论坛帖
@interface PubNode_Forum : PubNode_Communit

typedef NS_ENUM(NSInteger, MediaType)
{
    MediaType_None = -1,
    MediaType_Image,
    MediaType_Audio,
    MediaType_Video,
};

@property (nonatomic, assign)  NSInteger      subTypeEnum;          // 类型（文字txt、图片img、语音audio、视频video）
@property (nonatomic, strong)  NSString       *title;               // 标题
//@property (nonatomic, strong)  NSTextStorage  *textStorage;         // 图文混合
@property (nonatomic, strong)  NSArray        *resourceArr;         // 图文混合
@property (nonatomic, strong)  NSString       *audioPath;           // 语音或视频帖子文件名
@property (nonatomic, assign)  int32_t        audioTotalSeconds;    // 音频或视频的时长
@property (nonatomic, assign)  int32_t        audioExpiresSeconds;  // 音频或视频的有效期（多少秒之后过期）
@property (nonatomic, strong)  NSString       *videoUrlStr;         // 视频地址

@end


// 公告贴
@interface PubNode_Notice : PubNode_Communit

typedef NS_ENUM(NSInteger, PubType)
{
    PubType_Add = -1,
    PubType_Edit,
    PubType_Background,  // *_*社区背景介绍
};

@property (nonatomic, strong) NSString *title;        // 标题
@property (nonatomic, strong) NSString *link;         // 公告链接
@property (nonatomic, strong) NSArray  *resourceArr;  // 自定义模板公告详情和图文混排部分
@property (nonatomic, strong) UIImage  *imgPoster;    // 海报图片
@property (nonatomic, strong) UIImage  *imgBanner;    // 置顶发布时的banner图片
@property (nonatomic, assign) PubType  type;          // 发布类型（新建/修改/社区背景介绍）
@property (nonatomic, strong) NSString *replaceId;    // url参数：-1不置顶/0一般置顶/>0替换置顶，值为要替换公告帖子的id
@property (nonatomic, strong) NSString *postId;       // 帖子id（修改时使用，新建时没用）

@end




// 发布队列
@interface CommunityPubQueue : NSObject

@property (atomic, strong) NSMutableArray *taskArr;

+ (id)sharedQueue;

- (void)addTask:(PubNode_Communit *)node;

@end
