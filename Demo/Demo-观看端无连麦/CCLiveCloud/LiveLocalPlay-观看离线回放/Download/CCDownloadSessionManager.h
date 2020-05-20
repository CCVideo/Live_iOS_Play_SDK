//
//  CCDownloadSessionManager.h
//  Demo
//
//  Created by zwl on 2019/2/25.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCDownloadModel.h"

NS_ASSUME_NONNULL_BEGIN

// 下载代理
@protocol CCDownloadSessionDelegate <NSObject>

@optional
// 更新下载进度
- (void)downloadModel:(CCDownloadModel *)downloadModel didUpdateProgress:(CCDownloadProgress *)progress;

// 更新下载状态
- (void)downloadModel:(CCDownloadModel *)downloadModel error:(NSError *)error;

// 后台下载完成时回调
- (void)backgroundSessionCompletion;

@end

@interface CCDownloadSessionManager : NSObject

/**
 下载任务队列
 */
@property(nonatomic,strong,readonly) NSArray <CCDownloadModel *> * downloadModelList;

/**
 代理
 */
@property(nonatomic,weak) id<CCDownloadSessionDelegate> delegate;

/**
  注意：修改下载设置后，对已经存在的下载任务可能无效，请清空下载任务之后修改设置
 */

/**
 是否允许使用移动流量 YES支持 NO不支持 默认支持
 */
@property(nonatomic,assign)BOOL allowsCellular;

/**
 全部并发 默认YES, 当YES时，忽略maxDownloadCount
 */
@property(nonatomic,assign)BOOL isBatchDownload;

/**
 允许同时下载的最大并发数,默认为1，最大为4
 */
@property(nonatomic,assign)NSInteger maxDownloadCount;

/**
 等待下载队列 先进先出 默认YES， 当NO时，先进后出
 */
@property(nonatomic,assign)BOOL resumeDownloadFIFO;

/**
 初始化CCDownloadSessionManager

 @return CCDownloadSessionManager对象
 */
+(CCDownloadSessionManager *)manager;

/**
 配置后台session
 */
-(void)configureBackroundSession;

/**
 * 初始化CCDownloadModel

 @param videoMdoel 点播视频model 非空
 @param quality 媒体品质 非空
 @param othersInfo 自定义字段 可为空
 @return 创建成功返回CCDownloadModel对象，如果失败，返回nil
 */
//+(CCDownloadModel *)createDownloadModel:(DWVodVideoModel *)videoMdoel Quality:(NSString *)quality AndOthersInfo:(NSDictionary * _Nullable )othersInfo;

/**
 开始下载任务

 @param downloadModel CCDownloadModel对象
 */
-(void)startWithDownloadModel:(CCDownloadModel *)downloadModel;

/**
 开始下载任务 ，所有回调均已回到主线程中

 @param downloadModel CCDownloadModel对象
 @param progress 下载进度回调
 @param state 下载状态变动回调
 */
-(void)startWithDownloadModel:(CCDownloadModel *)downloadModel progress:(CCDownloadProgressBlock)progress state:(DWDownloadStateBlock)state;

/**
 暂停下载任务

 @param downloadModel CCDownloadModel对象
 */
-(void)suspendWithDownloadModel:(CCDownloadModel *)downloadModel;

/**
 恢复下载任务

 @param downloadModel CCDownloadModel对象
 */
-(void)resumeWithDownloadModel:(CCDownloadModel *)downloadModel;

/**
 删除下载任务以及本地缓存

 @param downloadModel CCDownloadModel对象
 */
-(void)deleteWithDownloadModel:(CCDownloadModel *)downloadModel;

/**
 删除全部任务
 */
-(void)deleteAllDownloadModel;

/**
 获取下载模型

 @param URLString 下载地址
 @return CCDownloadModel对象
 */
- (CCDownloadModel *)downLoadingModelForURLString:(NSString *)URLString;

/**
 判断当前资源是已在下载队列中

 @param videoId 视频id  非空
 @param quality 媒体品质 非空
 @return YES 已存在  NO 未存在
 */
-(BOOL)checkLocalResourceWithVideoId:(NSString *)videoId WithQuality:(NSString *)quality;

/**
 判断downloadModel下载链接是否有效

 @param downloadModel CCDownloadModel对象
 @return YES有效 NO无效，需重新获取下载链接
 */
-(BOOL)isValidateURLWithDownloadModel:(CCDownloadModel *)downloadModel;


/**
 根据新的下载地址，继续下载此任务

 @param newUrlString 新的下载地址
 @param downloadModel 需要修改的downloadModel
 */
-(void)reStartDownloadUrlWithNewUrlString:(NSString *)newUrlString AndDownloadModel:(CCDownloadModel *)downloadModel;



/**
 获取appdelegate，handleEventsForBackgroundURLSession事件回调

 @param completionHandler completionHandler
 */
-(void)setBackgroundSessionCompletionHandler:(void (^)())completionHandler;

@end

NS_ASSUME_NONNULL_END
