//
//  CCDownloadModel.m
//  Demo
//
//  Created by luyang on 2017/4/18.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import "CCDownloadModel.h"


@interface CCDownloadProgress () <NSCoding>
// 续传大小
@property (nonatomic, assign) int64_t resumeBytesWritten;
// 这次写入的数量
@property (nonatomic, assign) int64_t bytesWritten;
// 已下载的数量
@property (nonatomic, assign) int64_t totalBytesWritten;
// 文件的总大小
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;
// 下载进度
@property (nonatomic, assign) float progress;
// 下载速度
@property (nonatomic, assign) float speed;
// 下载剩余时间
@property (nonatomic, assign) int remainingTime;

@end

@interface CCDownloadModel () <NSCoding>

// >>>>>>>>>>>>>>>>>>>>>>>>>>  download info
// 下载地址
@property (nonatomic, strong) NSString *downloadURL;
// 文件名 默认nil 则为下载URL中的文件名
@property (nonatomic, strong) NSString *fileName;

//文件类型 1 视频 2 音频
@property (nonatomic,strong) NSString * mediaType;
//文件后缀名
@property (nonatomic,strong) NSString * mimeType;
//清晰度
@property (nonatomic,strong) NSString * quality;
//清晰度描述
@property (nonatomic,strong) NSString * desp;
//VR视频
@property (nonatomic,assign) BOOL vrMode;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  task info
// 下载状态
@property (nonatomic, assign) CCDownloadState state;
//本地缓存路径
@property (nonatomic, strong) NSString *filePath;
// 下载时间
@property (nonatomic, strong) NSDate *downloadDate;

// 下载进度
@property (nonatomic, strong) CCDownloadProgress *progress;
// 断点续传需要设置这个数据
@property (nonatomic, strong) NSData *resumeData;

@property (nonatomic,strong)NSString *responseToken;

@property (nonatomic, strong)NSString *userId;

@property (nonatomic, strong)NSString *videoId;

// 手动取消当做暂停
@property (nonatomic, assign) BOOL manualCancle;

@end

@implementation CCDownloadModel

- (instancetype)init
{
    if (self = [super init]) {
        _progress = [[CCDownloadProgress alloc]init];
    }
    return self;
}

-(NSString *)filePath
{
    //覆盖安装时，app路径会变，这里根据文件名动态获取
    //这里同缓存路径！！！ 不要修改错了
    NSString * savePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DWDownloadCache"];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@",savePath,self.fileName];
    return filePath;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self == [super init]) {
        
        self.downloadURL = [aDecoder decodeObjectForKey:@"downloadURL"];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.responseToken = [aDecoder decodeObjectForKey:@"responseToken"];
        self.mediaType = [aDecoder decodeObjectForKey:@"mediaType"];
        self.mimeType = [aDecoder decodeObjectForKey:@"mimeType"];
        self.quality = [aDecoder decodeObjectForKey:@"quality"];
        self.desp = [aDecoder decodeObjectForKey:@"desp"];
        self.vrMode = [aDecoder decodeBoolForKey:@"vrMode"];
        self.resumeData = [aDecoder decodeObjectForKey:@"resumeData"];
        self.othersInfo = [aDecoder decodeObjectForKey:@"othersInfo"];
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.videoId = [aDecoder decodeObjectForKey:@"videoId"];
        self.state = [aDecoder decodeIntegerForKey:@"state"];
        self.progress = [aDecoder decodeObjectForKey:@"progress"];
        self.filePath = [aDecoder decodeObjectForKey:@"filePath"];
        self.downloadDate = [aDecoder decodeObjectForKey:@"downloadDate"];
        self.decompressionState = [aDecoder decodeIntegerForKey:@"decompressionState"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.downloadURL forKey:@"downloadURL"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.responseToken forKey:@"responseToken"];
    [aCoder encodeObject:self.mediaType forKey:@"mediaType"];
    [aCoder encodeObject:self.mimeType forKey:@"mimeType"];
    [aCoder encodeObject:self.quality forKey:@"quality"];
    [aCoder encodeObject:self.desp forKey:@"desp"];
    [aCoder encodeBool:self.vrMode forKey:@"vrMode"];
    [aCoder encodeObject:self.resumeData forKey:@"resumeData"];
    [aCoder encodeObject:self.othersInfo forKey:@"othersInfo"];
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.videoId forKey:@"videoId"];
    [aCoder encodeInteger:self.state forKey:@"state"];
    [aCoder encodeObject:self.progress forKey:@"progress"];
    [aCoder encodeObject:self.filePath forKey:@"filePath"];
    [aCoder encodeObject:self.downloadDate forKey:@"downloadDate"];
    [aCoder encodeInteger:self.decompressionState forKey:@"decompressionState"];
}

@end

@implementation CCDownloadProgress

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self == [super init]) {
        self.resumeBytesWritten = [aDecoder decodeInt64ForKey:@"resumeBytesWritten"];
        self.bytesWritten = [aDecoder decodeInt64ForKey:@"bytesWritten"];
        self.totalBytesWritten = [aDecoder decodeInt64ForKey:@"totalBytesWritten"];
        self.totalBytesExpectedToWrite = [aDecoder decodeInt64ForKey:@"totalBytesExpectedToWrite"];
        self.progress = [aDecoder decodeFloatForKey:@"progress"];
        self.speed = [aDecoder decodeFloatForKey:@"speed"];
        self.remainingTime = [aDecoder decodeIntForKey:@"remainingTime"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.resumeBytesWritten forKey:@"resumeBytesWritten"];
    [aCoder encodeInt64:self.bytesWritten forKey:@"bytesWritten"];
    [aCoder encodeInt64:self.totalBytesWritten forKey:@"totalBytesWritten"];
    [aCoder encodeInt64:self.totalBytesExpectedToWrite forKey:@"totalBytesExpectedToWrite"];
    [aCoder encodeFloat:self.progress forKey:@"progress"];
    [aCoder encodeFloat:self.speed forKey:@"speed"];
    [aCoder encodeInt:self.remainingTime forKey:@"remainingTime"];
    
}

@end

