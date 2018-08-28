//
//  FileManager.m
//  Test
//
//  Created by cc on 2017/2/24.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "FileManager.h"

@interface FileManager()

@property(nonatomic,  copy)NSString             *downloadedPlistPath; // 正在下载进度信息保存的路径

@end

@implementation FileManager

static FileManager *instance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

// 已经下载的plist文件路径
- (NSString *)downloadedPlistPath{
    if (_downloadedPlistPath == nil) {
        NSString *record = [NSString stringWithFormat:@"%@/Library/Download/",NSHomeDirectory()];
        _downloadedPlistPath = [record stringByAppendingString:@"Download.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:record]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:record withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:_downloadedPlistPath]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            // 在相应的路径创建plist文件
            [dic writeToFile:_downloadedPlistPath atomically:YES];
        }
    }
    return _downloadedPlistPath;
}

-(NSMutableDictionary *)plist {
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:self.downloadedPlistPath];
    return plist;
}

-(void)saveplist:(NSMutableDictionary *)plist {
    [plist writeToFile:self.downloadedPlistPath atomically:YES];
}

@end
