//
//  CCChatViewDataSourceManager.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/21.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CCChatViewDataSourceManagerDelegate <NSObject>
/**
 更新加载完成后的图片cell

 @param indexPath 图片位置
 @param chatArr 聊天数组
 */
-(void)updateIndexPath:(NSIndexPath *)indexPath chatArr:(NSMutableArray *)chatArr;

@end


typedef void(^InsertDanMuBlock)(CCPublicChatModel *model);//发送弹幕回调

@interface CCChatViewDataSourceManager : NSObject

@property (nonatomic, weak)id<CCChatViewDataSourceManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray<CCPublicChatModel*> * publicChatArray;//公聊数组

/**
 单例模式

 @return 返回一个处理数据的单例对象
 */
+(CCChatViewDataSourceManager *)sharedManager;

/**
 加载直播的历史聊天数据(最多60条)

 @param objectArr 直播历史聊天数据
 @param userDic 用户字典
 @param viewerId 观看者id
 @param groupId groupid
 */
-(void)initWithPublicArray:(NSArray *)objectArr
                   userDic:(NSMutableDictionary *)userDic
                  viewerId:(NSString *)viewerId
                   groupId:(NSString *)groupId;

/**
 加载观看回放的历史聊天数据(当数据量过大时，分两次返回)

 @param objectArr 直播回放聊天数据
 @param groupId groupId
 */
-(void)initWithPlayBackChatArray:(NSArray *)objectArr
                         groupId:(NSString *)groupId;

/**
 新聊天数据

 @param dic 聊天字典
 @param userDic userDic
 @param viewerId 观看者id
 @param groupId groupid
 @param block 发送弹幕
 */
-(void)addPublicChat:(NSDictionary *)dic
             userDic:(NSMutableDictionary *)userDic
            viewerId:(NSString *)viewerId
             groupId:(NSString *)groupId
          danMuBlock:(InsertDanMuBlock)block;


/**
 收到广播消息

 @param dic 广播字典
 */
-(void)addRadioMessage:(NSDictionary *)dic;


/**
更新imageCell的行高

 @param indexPath cell的位置
 @param imageSize 图片大小
 */
-(void)updateCellHeightWithIndexPath:(NSIndexPath *)indexPath
                           imageSize:(CGSize)imageSize;

/**
 判断是否存在这张图片

 @param url 图片链接地址
 @return 返回值
 */
-(BOOL)existImageWithUrl:(NSString *)url;
#pragma mark - 添加一条私聊下载图片
/**
 添加一条私聊下载图片

 @param url url
 @param size 图片大小
 */
-(void)setURL:(NSString *)url withImageSize:(CGSize)size;

/**
 返回一个下载过的图片大小

 @param msg 未处理的url
 @return 图片大小
 */
-(CGSize)getImageSizeWithMsg:(NSString *)msg;
/**
 移除缓存的数据
 */
-(void)removeData;
@end

NS_ASSUME_NONNULL_END
