//
//  DWDownloadUtility.h
//  DWDownloadManagerDemo
//
//  Created by luyang on 17/4/18.
//  
//

#import <Foundation/Foundation.h>

/**
 *  下载工具类
 */
@interface CCDownloadUtility : NSObject

// 返回文件大小
+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength;

// 返回文件大小的单位
+ (NSString *)calculateUnit:(unsigned long long)contentLength;




@end
