//
//  DrawBitmapView.h
//  CCavPlayDemo
//
//  Created by cc on 15/6/25.
//  Copyright (c) 2015年 ma yige. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    DOWNLOAD_LOADING,
    DOWNLOAD_PAUSE,
    DOWNLOAD_FINISH_NOTAVAILABLE,
    DOWNLOAD_FINISH_AVAILABLE,
    DOWNLOADD_ERROR,
    DOWNLOAD_FINISH_ZIPARCHIVE_ERROR,
}DownloadType;

@interface Download : NSObject
@property (nonatomic, copy) NSString                *downLoadUrl;       // 下载地址
@property (nonatomic, copy) NSString                *fileName;  // 文件存储名
@property (nonatomic, copy) NSString                *tempName;
@property(nonatomic,assign)long long                alreadyDownLoadSize;
@property(nonatomic,assign)long long                totalSize;
@property(nonatomic, strong)NSDate                  *date;
@property(nonatomic,assign)DownloadType             downloadType;
//@property(nonatomic,assign)NSInteger                rowIndex;
@property(nonatomic, copy)NSString                  *insertDateStr;

@property (nonatomic, copy) void(^loadingBlock)(long long alreadyDownLoadSize,long long totalSize,NSString *speed); // 下载回调
@property (nonatomic, copy) void(^complet)();           // 完成回调
@property (nonatomic, copy) void(^error)();             // 错误回调

// 开始下载
- (void)start;
// 暂停下载
- (void)suspended;
// 取消下载
- (void)cancel;

@end
