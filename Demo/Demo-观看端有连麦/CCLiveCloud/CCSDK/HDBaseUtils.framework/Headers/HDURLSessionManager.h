//
//  HDURLSessionSessionManager.h
//  HDURLSession
//
//  Created by zwl on 2020/3/23.
//  Copyright © 2020 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HDURLSessionManagerDelegate <NSObject>

@optional
/** 任务完成/中断/异常，上传，下载通用方法
 @param task 具体任务
 @param error 错误信息
 */
-(void)HDURLSessionTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

/** 上传进度回调
 @param task 具体任务
 @param bytesSent 上传字节数
 @param totalBytesSent 总上传字节数
 @param totalBytesExpectedToSend 文件总字节数
 */
-(void)HDURLSessionTask:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;

//下载方法回调
/** 恢复下载任务
 @param downloadTask 下载任务
 @param fileOffset 续下位置
 @param expectedTotalBytes 文件总字节数
 */
-(void)HDURLSessionDownloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes;

/** 下载进度监听
 @param downloadTask 下载任务
 @param bytesWritten 下载字节数
 @param totalBytesWritten 总下载字节数
 @param totalBytesExpectedToWrite 文件总字节数
 */
-(void)HDURLSessionDownloadTask:(NSURLSessionDownloadTask *)downloadTask    didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
      totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

/** 下载完成
 @param downloadTask 下载任务
 @param location 本地缓存路径，需copy到自己制定目录，方法完成后，文件会被系统删除
 */
-(void)HDURLSessionDownloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location;

@end

@interface HDURLSessionManager : NSObject

/**
 *  @brief 代理回调
 */
@property(nonatomic,weak) id <HDURLSessionManagerDelegate> delegate;

/*!
 * @method
 * @abstract 初始化对象
 * @discussion 初始化对象
 * @result HDURLSessionManager对象
 */
+(HDURLSessionManager *)sharedManager;

///上传任务初始化

/*!
 * @method
 * @abstract 初始化上传任务
 * @discussion 初始化上传任务
 * @param urlString 上传地址
 * @param params 上传参数
 * @param filePath 本地文件路径
 * @result NSURLSessionUploadTask对象
 */
-(NSURLSessionUploadTask *)getUploadTaskWithUrl:(NSString *)urlString
                                         Params:(NSDictionary *)params
                                       FilePath:(NSString *)filePath;

/*!
 * @method
 * @abstract 初始化上传任务
 * @discussion 初始化上传任务
 * @param request 上传任务
 * @param filePath 本地文件路径
 * @result NSURLSessionUploadTask对象
 */
-(NSURLSessionUploadTask *)getUploadTaskWithRequest:(NSURLRequest *)request
                                           FilePath:(NSString *)filePath;

/*!
 * @method
 * @abstract 获取全部上传任务
 * @discussion 获取全部上传任务
 * @result 全部上传任务
 */
-(NSArray <NSURLSessionUploadTask *> *)getAllUploadTasks;

/*!
 * @method
 * @abstract 初始化下载任务
 * @discussion 初始化下载任务
 * @param urlString 下载地址
 * @param params 下载参数
 * @result NSURLSessionDownloadTask对象
 */
-(NSURLSessionDownloadTask *)getDownloadTaskWithUrl:(NSString *)urlString
                                             Params:(NSDictionary *)params;

/*!
 * @method
 * @abstract 初始化下载任务
 * @discussion 初始化下载任务
 * @param request 下载任务
 * @result NSURLSessionDownloadTask对象
 */
-(NSURLSessionDownloadTask *)getDownloadTaskWithRequest:(NSURLRequest *)request;

/*!
 * @method
 * @abstract 通过resumeData初始化下载任务
 * @discussion 通过resumeData初始化下载任务
 * @param resumeData 续传数据
 * @result NSURLSessionDownloadTask对象
 */
-(NSURLSessionDownloadTask *)getDownloadTaskWithResumeData:(NSData *)resumeData;

/*!
 * @method
 * @abstract 获取全部下载任务
 * @discussion 获取全部下载任务
 * @result 全部下载任务
 */
-(NSArray <NSURLSessionDownloadTask *> *)getAllDownloadTasks;

/*!
 * @method
 * @abstract 开始任务
 * @discussion 开始任务
 * @param task 具体任务
 * @result 操作结果
 */
-(BOOL)resumeTask:(NSURLSessionTask *)task;

/*!
 * @method
 * @abstract 暂停任务
 * @discussion 暂停任务
 * @param task 具体任务
 * @result 操作结果
 */
-(BOOL)suspendTask:(NSURLSessionTask *)task;

@end
