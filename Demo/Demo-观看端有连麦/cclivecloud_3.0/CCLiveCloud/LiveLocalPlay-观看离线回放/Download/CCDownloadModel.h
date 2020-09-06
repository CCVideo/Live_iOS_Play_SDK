//
//  CCDownloadModel.h
//  Demo
//
//  Created by luyang on 2017/4/18.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>


// 下载状态
typedef NS_ENUM(NSUInteger, CCDownloadState) {
    CCDownloadStateNone,        // 未下载 或 下载删除了
    CCDownloadStateReadying,    // 等待下载
    CCDownloadStateRunning,     // 正在下载
    CCDownloadStateSuspended,   // 下载暂停
    CCDownloadStateCompleted,   // 下载完成
    CCDownloadStateFailed       // 下载失败
};

@class CCDownloadProgress;
@class CCDownloadModel;

// 进度更新block
typedef void (^CCDownloadProgressBlock)(CCDownloadProgress *progress,CCDownloadModel *downloadModel);
// 状态更新block
typedef void (^DWDownloadStateBlock)(CCDownloadModel *downloadModel, NSError *error);


/**
 *  下载模型
 */
@interface CCDownloadModel : NSObject

// >>>>>>>>>>>>>>>>>>>>>>>>>>  download info
/// 下载地址
@property (nonatomic, strong, readonly) NSString * downloadURL;
/// 文件名 默认nil 则为下载URL中的文件名
@property (nonatomic, strong, readonly) NSString * fileName;
/// 加密
@property (nonatomic, strong, readonly) NSString * responseToken;
/// 文件类型 1 视频 2 音频
@property (nonatomic, strong, readonly) NSString * mediaType;
/// 文件后缀名
@property (nonatomic ,strong, readonly) NSString * mimeType;
/// 清晰度
@property (nonatomic, strong, readonly) NSString * quality;
/// 清晰度描述
@property (nonatomic, strong, readonly) NSString * desp;
/// VR视频
@property (nonatomic, assign, readonly) BOOL vrMode;
/// 非点播业务不需要关注此值  解压状态 0 未解压  1 解压中 2 解压完成 3 解压失败
@property (nonatomic, assign) NSInteger decompressionState;
//@property (nonatomic, strong) dispatch_queue_t decompressionQueue;

/// URL失效后的断点续传需要设置这个数据
@property (nonatomic, strong, readonly) NSData * resumeData;
/// 自定义字段 根据自己需求适当添加
@property (nonatomic, strong) NSDictionary * othersInfo;

/*
 *用户信息
 *视频videoId
 */
@property (nonatomic, strong, readonly)NSString * userId;

@property (nonatomic, strong, readonly)NSString * videoId;


// >>>>>>>>>>>>>>>>>>>>>>>>>>  task info
/// 下载状态
@property (nonatomic, assign, readonly) CCDownloadState state;
/// 下载进度
@property (nonatomic, strong ,readonly) CCDownloadProgress *progress;
/// 存储路径
@property (nonatomic, strong, readonly) NSString * filePath;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  download block
/// 下载进度更新block
@property (nonatomic, copy) CCDownloadProgressBlock progressBlock;
/// 下载状态更新block
@property (nonatomic, copy) DWDownloadStateBlock stateBlock;

@end

/**
 *  下载进度
 */
@interface CCDownloadProgress : NSObject

/// 续传大小
@property (nonatomic, assign, readonly) int64_t resumeBytesWritten;
/// 这次写入的数量
@property (nonatomic, assign, readonly) int64_t bytesWritten;
/// 已下载的数量
@property (nonatomic, assign, readonly) int64_t totalBytesWritten;
/// 文件的总大小
@property (nonatomic, assign, readonly) int64_t totalBytesExpectedToWrite;
/// 下载进度
@property (nonatomic, assign, readonly) float progress;
/// 下载速度
@property (nonatomic, assign, readonly) float speed;
/// 下载剩余时间
@property (nonatomic, assign, readonly) int remainingTime;



@end
