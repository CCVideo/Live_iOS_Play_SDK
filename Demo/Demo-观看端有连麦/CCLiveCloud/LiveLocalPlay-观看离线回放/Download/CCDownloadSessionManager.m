//
//  CCDownloadSessionManager.m
//  Demo
//
//  Created by zwl on 2019/2/25.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "CCDownloadSessionManager.h"
#import <UIKit/UIDevice.h>
#import "NSURLSession+CCCorrectedResumeData.h"

#define IOS_SYSTEMVERSION     ([[[UIDevice currentDevice] systemVersion] floatValue])
#define DOWNLOADMODELSAVENAME                   @"downloadModelsSave.data"


/**
 *  下载模型
 */
@interface CCDownloadModel ()

// >>>>>>>>>>>>>>>>>>>>>>>>>>  task info
// 下载状态
@property (nonatomic, assign) CCDownloadState state;
// 下载任务
//@property (nonatomic, strong) NSURLSessionDownloadTask *task;
//下载地址
@property (nonatomic, strong) NSString * downloadURL;
// 下载文件路径,下载完成后有值,把它移动到你的目录
@property (nonatomic, strong) NSString *filePath;
//文件名
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
// 下载时间
@property (nonatomic, strong) NSDate *downloadDate;
// 断点续传需要设置这个数据
@property (nonatomic, strong) NSData *resumeData;

@property (nonatomic,strong)NSString *responseToken;

@property (nonatomic, strong)NSString *userId;

@property (nonatomic, strong)NSString *videoId;

@end

/**
 *  下载进度
 */
@interface CCDownloadProgress ()
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


@interface CCDownloadSessionManager () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSString *backgroundConfigure;

// 文件管理
@property (nonatomic, strong) NSFileManager *fileManager;
// 缓存文件目录
@property (nonatomic, strong) NSString *downloadDirectory;
// 下载seesion会话
@property (nonatomic, strong) NSURLSession *session;
// 回调代理的队列
@property (strong, nonatomic) NSOperationQueue *queue;
//加密 新生成的newKey
@property (nonatomic,copy)NSString *tokenKey;
//下载队列
@property (nonatomic,strong)NSMutableArray * downloadModels;

//zwl test
//是否需要每隔一段时间 ，就本地化一下数据，防止发生crash时，出现的数据不同步问题 或者在这个delegate方法里，resumeData如果存在的话，给初值- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
//@property (nonatomic,strong)NSTimer * saveTimer;

@end

//每隔一段时间，进行一次数据本地化，防止发生crash时，出现的数据不同步问题
//static NSInteger saveTimerSecond = 1;

@implementation CCDownloadSessionManager

+ (CCDownloadSessionManager *)manager
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _backgroundConfigure = @"CCDownloadSessionManager.backgroundConfigure";
        _maxDownloadCount = 1;
        _resumeDownloadFIFO = YES;
        _isBatchDownload = YES;
        _allowsCellular =YES;

        //初始化 下载队列
        NSString * savePath = [NSString stringWithFormat:@"%@/%@",self.downloadDirectory,DOWNLOADMODELSAVENAME];
        if ([NSKeyedUnarchiver unarchiveObjectWithFile:savePath]) {
            _downloadModels = [[NSMutableArray alloc]initWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:savePath]];
            //初始化时， 若任务正在进行中，全部暂停
            if (_downloadModels.count != 0) {
                for (CCDownloadModel * downloadModel in _downloadModels) {
                    if (downloadModel.state == CCDownloadStateRunning) {
                        [self suspendWithDownloadModel:downloadModel];
                    }
                    if (downloadModel.decompressionState == 1) {
                        downloadModel.decompressionState = 0;
                    }
                }
            }
                
        }else{
            _downloadModels = [[NSMutableArray alloc]init];
        }
        
//        [self startSaveTimer];
    }
    return self;
}

- (void)configureBackroundSession
{
    if (!_backgroundConfigure) {
        return;
    }
    [self session];
}

#pragma mark - getter

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

- (NSURLSession *)session
{
    if (!_session) {
        if (_backgroundConfigure) {
            if (IOS_SYSTEMVERSION >= 8.0) {
                NSURLSessionConfiguration *configure = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_backgroundConfigure];
                //这里在 新建request 上 设置了
//                configure.allowsCellularAccess =_allowsCellular;
                _session = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:self.queue];

            }else{
                _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:_backgroundConfigure]delegate:self delegateQueue:self.queue];
            }
        }else {
            _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.queue];
        }
    }
    return _session;
}

- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount = 4;
    }
    return _queue;
}

- (NSString *)downloadDirectory
{
    if (!_downloadDirectory) {
        _downloadDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DWDownloadCache"];
        [self createDirectory:_downloadDirectory];
    }
    return _downloadDirectory;
}

-(NSArray<CCDownloadModel *> *)downloadModelList
{
    return self.downloadModels;
}

#pragma mark - public
/*
+(CCDownloadModel *)createDownloadModel:(DWVodVideoModel *)videoMdoel Quality:(NSString *)quality AndOthersInfo:(NSDictionary *)othersInfo
{
    if (!videoMdoel) {
        return nil;
    }
    
    //开启授权验证，没权限，禁止下载
    if (videoMdoel.authorize && !videoMdoel.authorize.enable) {
        NSLog(@"该视频无下载权限");
        return nil;
    }
    
    //查询不到清晰度 返回nil
    __block DWVideoQualityModel * qualityModel = nil;

    //分别对视频清晰度，音频清晰度进行查询
    [videoMdoel.videoQualities enumerateObjectsUsingBlock:^(DWVideoQualityModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.quality integerValue] == [quality integerValue]) {
            qualityModel = obj;
            *stop = YES;
        }
    }];
    
    if (!qualityModel) {
        [videoMdoel.radioQualities enumerateObjectsUsingBlock:^(DWVideoQualityModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.quality integerValue] == [quality integerValue]) {
                qualityModel = obj;
                *stop = YES;
            }
        }];
    }
    
    if (!qualityModel) {
        NSLog(@"未查询到当前清晰度");
        return nil;
    }
    
    CCDownloadSessionManager * manager = [CCDownloadSessionManager manager];
    CCDownloadModel * downloadModel = [manager createDownloadModel:qualityModel.playUrl MediaType:qualityModel.mediaType Quality:qualityModel.quality Desp:qualityModel.desp VideoId:videoMdoel.videoId Token:videoMdoel.token UserId:videoMdoel.CCUserId VRMode:videoMdoel.vrmode AndOthersInfo:othersInfo];
    return downloadModel;
}
 */

-(CCDownloadModel *)createDownloadModel:(NSString *)downloadURL MediaType:(NSString *)mediaType Quality:(NSString *)quality Desp:(NSString *)desp VideoId:(NSString *)videoId Token:(NSString *)token UserId:(NSString *)userId VRMode:(BOOL)vrMode AndOthersInfo:(NSDictionary *)othersInfo
{
    CCDownloadModel * downloadModel = [[CCDownloadModel alloc]init];
    
    //zwl test
    //pcm下载链接 拼接r参数
    if ([downloadURL containsString:@"pcm?"]) {
        //拼接r参数 为随机数
        NSURL *url = [NSURL URLWithString:downloadURL];
        if (![url query]) {
            downloadURL =[downloadURL stringByAppendingFormat:@"?r=%d",rand()];
        }else{
            downloadURL =[downloadURL stringByAppendingFormat:@"&r=%d",rand()];
        }
        
    }
    downloadModel.downloadURL = [downloadURL copy];
    downloadModel.videoId = [videoId copy];
    downloadModel.responseToken = token ? [token copy] : @"";
    downloadModel.userId = userId ? [userId copy] : @"";
    downloadModel.mediaType = mediaType ? [NSString stringWithFormat:@"%@",mediaType] : @"1";
    downloadModel.quality = quality ? [NSString stringWithFormat:@"%@",quality] : nil;
    downloadModel.desp = desp ? [desp copy] : nil;
    downloadModel.vrMode = vrMode;
    downloadModel.othersInfo = othersInfo;
    //生成文件存储路径
    NSString *type;
    if ([downloadModel.downloadURL containsString:@"mp4?"]) {
        type = @"mp4";
    }else if([downloadModel.downloadURL containsString:@"pcm?"]){
        type = @"pcm";
    }else if ([downloadModel.downloadURL containsString:@"m4a?"]){
        type = @"m4a";
    }else if ([downloadModel.downloadURL containsString:@"mp3?"]){
        type = @"mp3";
    }else if ([downloadModel.downloadURL containsString:@"aac?"]){
        type = @"aac";
    }
    downloadModel.mimeType = type;

    if (!downloadModel.quality) {
        downloadModel.fileName = [NSString stringWithFormat:@"%@.%@",downloadModel.videoId,downloadModel.mimeType];
    }else{
        downloadModel.fileName = [NSString stringWithFormat:@"%@-%@.%@",downloadModel.videoId, downloadModel.quality,downloadModel.mimeType];
    }
        
    return downloadModel;
}

// 获取下载模型
- (CCDownloadModel *)downLoadingModelForURLString:(NSString *)URLString
{
    for (CCDownloadModel * downloadModel in self.downloadModels) {
        if ([downloadModel.downloadURL isEqualToString:URLString]) {
            return downloadModel;
        }
    }
    
    return nil;
}

- (void)startWithDownloadModel:(CCDownloadModel *)downloadModel progress:(CCDownloadProgressBlock)progress state:(DWDownloadStateBlock)state
{
    downloadModel.progressBlock = progress;
    downloadModel.stateBlock = state;
    
    [self startWithDownloadModel:downloadModel];
}

- (void)startWithDownloadModel:(CCDownloadModel *)downloadModel
{
    if (!downloadModel) {
        return;
    }
    
    //判断任务是否已完成 ，若完成，那么直接return
    if ([self isCompletedDownload:downloadModel]) {
        return;
    }
    
    if (downloadModel.state == CCDownloadStateReadying) {
        [self downloadModel:downloadModel error:nil];
        return;
    }
    
    // 验证是否存在 || 正在下载中
    NSURLSessionDownloadTask * task = [self getDownloadTask:downloadModel];
    if (task && task.state == NSURLSessionTaskStateRunning) {
        downloadModel.state = CCDownloadStateRunning;
        [self downloadModel:downloadModel error:nil];
        return;
    }
    
    //保存model数据，并且本地化
    if (![self.downloadModels containsObject:downloadModel]) {
        [self.downloadModels addObject:downloadModel];
        if (![self saveDownloadModels]) {
        }
    }
    
    [self resumeWithDownloadModel:downloadModel];
}

// 暂停下载
- (void)suspendWithDownloadModel:(CCDownloadModel *)downloadModel
{
    if (!downloadModel) {
        return;
    }

    if (downloadModel.state != CCDownloadStateRunning) {
        return;
    }
    
    downloadModel.state = CCDownloadStateSuspended;
    
    NSURLSessionDownloadTask * task = [self getDownloadTask:downloadModel];
    [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
    }];
}

// 恢复下载
- (void)resumeWithDownloadModel:(CCDownloadModel *)downloadModel
{
    if (!downloadModel) {
        return;
    }
    
    //判断任务是否已完成 ，若完成，那么直接return
    if ([self isCompletedDownload:downloadModel]) {
        return;
    }
    
    if (downloadModel.state == CCDownloadStateRunning) {
        return;
    }
    
    //非媒体类型数据，不需要做此判断
    if (downloadModel.videoId) {
        //URL时效性判断 ，如果超时return
        if (![self isValidateURLWithDownloadModel:downloadModel]) {
            return;
        }
    }
    
    //控制，处理 下载数量
    if (![self canResumeDownlaodModel:downloadModel]) {
        return;
    }

    // 如果task 不存在 或者 取消了
    NSURLSessionDownloadTask * task = [self getDownloadTask:downloadModel];
    if (!task || task.state == NSURLSessionTaskStateCanceling) {
        
        NSData * resumeData = downloadModel.resumeData;
        
        if ([self isValideResumeData:resumeData]) {
            
            if (IOS_SYSTEMVERSION == 10.0 || IOS_SYSTEMVERSION == 10.1) {
                //为了解决iOS10.0 10.1的BUG
                task = [self.session downloadTaskWithCorrectResumeData:resumeData];
            }else{
                task = [self.session downloadTaskWithResumeData:resumeData];
            }
            
        }else {
            //只有新建的request设置才会有效果
//            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadModel.downloadURL]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadModel.downloadURL]];
            request.allowsCellularAccess = self.allowsCellular;
            task = [self.session downloadTaskWithRequest:request];
        }
        task.taskDescription = downloadModel.downloadURL;
        downloadModel.downloadDate = [NSDate date];
    }
    
    if (!downloadModel.downloadDate) {
        downloadModel.downloadDate = [NSDate date];
    }
    
    //加密
    if (downloadModel.responseToken) {
        [self createTokenKey:downloadModel];
    }
    
    [task resume];
    downloadModel.state = CCDownloadStateRunning;
    [self downloadModel:downloadModel error:nil];

    if (![self saveDownloadModels]) {
    }
    
//    [self startSaveTimer];
}

//删除任务
-(void)deleteWithDownloadModel:(CCDownloadModel *)downloadModel
{
    if (!downloadModel) {
        return;
    }
    
    //应该不出出现这种情况，多做层判断
    if (![self.downloadModels containsObject:downloadModel]) {
        return;
    }
    
    [self deleteLoaclDataAndDownloadModel:downloadModel];
    
    @synchronized (self) {
        [self.downloadModels removeObject:downloadModel];
    }
    
    [self willResumeNextWithDowloadModel];

    if (![self saveDownloadModels]) {
    }
}

//删除全部任务
-(void)deleteAllDownloadModel
{
    @synchronized (self) {
        for (CCDownloadModel * downloadModel in self.downloadModels) {
            [self deleteLoaclDataAndDownloadModel:downloadModel];
        }
        
        [self.downloadModels removeAllObjects];
    }
    if (![self saveDownloadModels]) {
    }
    
//    [self stopSaveTimer];
}

//判断当前资源是已被下载
-(BOOL)checkLocalResourceWithVideoId:(NSString *)videoId WithQuality:(NSString *)quality
{
    if (!videoId || !quality) {
        return NO;
    }
    
    for (CCDownloadModel * model in self.downloadModels) {
        if ([model.videoId isEqualToString:videoId] && [model.quality isEqualToString:[NSString stringWithFormat:@"%@",quality]]) {
            return YES;
        }
    }
    
    return NO;
}

//判断当前下载任务是否超时
//与取当前系统时间 作对比，如果系统时间被修改了，这里比较就没有意义了
-(BOOL)isValidateURLWithDownloadModel:(CCDownloadModel *)downloadModel
{
    NSRange range =[downloadModel.downloadURL rangeOfString:@"t="];
    NSRange timeRang =NSMakeRange(range.location+2, 10);
    NSString * oldStr =[downloadModel.downloadURL substringWithRange:timeRang];
    
    NSDate * date =[NSDate date];
    NSString * timeString =[NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    NSString * nowString =[timeString substringWithRange:NSMakeRange(0, 10)];
    
    if ([nowString integerValue] >= [oldStr integerValue]) {
        return NO;
    }
    
    return YES;
}

//当URL失效时，修改url，继续下载
-(void)reStartDownloadUrlWithNewUrlString:(NSString *)newUrlString AndDownloadModel:(CCDownloadModel *)downloadModel
{
    if (!newUrlString || !downloadModel) {
        return;
    }
    
    if (![self.downloadModels containsObject:downloadModel]) {
        return;
    }
    
    if (downloadModel.state == CCDownloadStateRunning) {
        //如果当前任务在进行中，那不需要修改resumeData
        return;
    }
    
    if (!downloadModel.resumeData) {
        return;
    }
    
    /*
     iOS 大于12 用archivedDataWithRootObject: requiringSecureCoding: 方法 用NSCoding的
     iOS 大于等于11.3 小于12 用archivedDataWithRootObject: requiringSecureCoding: 方法 ，别的用xml的
     iOS <11.3 用archivedDataWithRootObject: 方法 用xml的
     */
    
    NSData * resumeData = downloadModel.resumeData;
    //生成一个新的NSURLMutableRequest
    NSMutableURLRequest *newResumeRequest =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:newUrlString]];
    if (IOS_SYSTEMVERSION >= 12) {
        
        NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:resumeData];
        NSDictionary * resumeDataDic = [[unarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:nil] mutableCopy];
        [unarchiver finishDecoding];
        
        //生成 newRequestData
        NSInteger bytes = [[resumeDataDic objectForKey:@"NSURLSessionResumeBytesReceived"] integerValue];
        NSString *bytesStr = [NSString stringWithFormat:@"bytes=%ld-",(long)bytes];
        [newResumeRequest addValue:bytesStr forHTTPHeaderField:@"Range"];
        NSData * newRequestData = [NSKeyedArchiver archivedDataWithRootObject:newResumeRequest requiringSecureCoding:YES error:nil];
        
        NSDictionary * newResumeDict = [self getNewResumeOldResumeDict:resumeDataDic NewRequestData:newRequestData WithUrlString:newUrlString];
        
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:newResumeDict forKey:@"NSKeyedArchiveRootObjectKey"];
        [archiver finishEncoding];
        downloadModel.resumeData = data;
        
    }else if (IOS_SYSTEMVERSION >= 11.3){
        
        NSMutableDictionary *resumeDataDic =[NSPropertyListSerialization propertyListWithData:resumeData options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
        
        //生成 newRequestData
        //iOS11.3 之后应该就 得使用secureCoding了，不用的话，request生成的data无法继续下载
        NSInteger bytes = [[resumeDataDic objectForKey:@"NSURLSessionResumeBytesReceived"] integerValue];
        NSString *bytesStr = [NSString stringWithFormat:@"bytes=%ld-",(long)bytes];
        [newResumeRequest addValue:bytesStr forHTTPHeaderField:@"Range"];
        NSData * newRequestData = [NSKeyedArchiver archivedDataWithRootObject:newResumeRequest requiringSecureCoding:YES error:nil];
        
        NSDictionary * newResumeDict = [self getNewResumeOldResumeDict:resumeDataDic NewRequestData:newRequestData WithUrlString:newUrlString];
        
        NSData *data =[NSPropertyListSerialization dataWithPropertyList:newResumeDict format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
        downloadModel.resumeData = data;
        
    }else{
        
        NSMutableDictionary *resumeDataDic =[NSPropertyListSerialization propertyListWithData:resumeData options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
        
        //为NSURLMutableRequest 为 HTTP 请求的头部增加了一个 Range
        NSInteger bytes =[[resumeDataDic objectForKey:@"NSURLSessionResumeBytesReceived"] integerValue];
        NSString *bytesStr =[NSString stringWithFormat:@"bytes=%ld-",(long)bytes];
        [newResumeRequest addValue:bytesStr forHTTPHeaderField:@"Range"];
        
        // 重新将 NSURLMutableRequest encode 为 NSData 。
        NSData *newRequestData =[NSKeyedArchiver archivedDataWithRootObject:newResumeRequest];
        
        NSDictionary * newResumeDict = [self getNewResumeOldResumeDict:resumeDataDic NewRequestData:newRequestData WithUrlString:newUrlString];
        
        NSData *data =[NSPropertyListSerialization dataWithPropertyList:newResumeDict format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
        downloadModel.resumeData = data;

    }
    
    downloadModel.downloadURL = [newUrlString copy];
    
    //整理完毕。。 继续下载
    [self resumeWithDownloadModel:downloadModel];
}

-(void)setBackgroundSessionCompletionHandler:(void (^)())completionHandler
{
    if (completionHandler) {
        completionHandler();
    }
    
    [self saveDownloadModels];
    
    if ([_delegate respondsToSelector:@selector(backgroundSessionCompletion)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate backgroundSessionCompletion];
        });
    }
}

#pragma mark - NSURLSessionDownloadDelegate
// 恢复下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    CCDownloadModel *downloadModel = [self downLoadingModelForURLString:downloadTask.taskDescription];
    
//    if (!downloadModel || downloadModel.state == DWDownloadStateSuspended) {
//        return;
//    }
    downloadModel.state = CCDownloadStateRunning;

    downloadModel.progress.resumeBytesWritten = fileOffset;
}

// 监听文件下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    CCDownloadModel *downloadModel = [self downLoadingModelForURLString:downloadTask.taskDescription];

    //    if (!downloadModel || downloadModel.state == DWDownloadStateSuspended) {
//        return;
//    }
    downloadModel.state = CCDownloadStateRunning;
    
    float progress = (double)totalBytesWritten/totalBytesExpectedToWrite;
    
    int64_t resumeBytesWritten = downloadModel.progress.resumeBytesWritten;
 
  
    NSTimeInterval downloadTime = -1 * [downloadModel.downloadDate timeIntervalSinceNow];
    float speed = (totalBytesWritten - resumeBytesWritten) / downloadTime;

    int64_t remainingContentLength = totalBytesExpectedToWrite - totalBytesWritten;
    int remainingTime = ceilf(remainingContentLength / speed);
    
    downloadModel.progress.bytesWritten = bytesWritten;
    downloadModel.progress.totalBytesWritten = totalBytesWritten;
    downloadModel.progress.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    downloadModel.progress.progress = progress;
    downloadModel.progress.speed = speed;
    downloadModel.progress.remainingTime = remainingTime;
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self downloadModel:downloadModel updateProgress:downloadModel.progress];
    });
    
}

// 下载成功
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    CCDownloadModel *downloadModel = [self downLoadingModelForURLString:downloadTask.taskDescription];
    
    if (location) {
        // 移动文件到下载目录
        [self moveFileAtURL:location toPath:downloadModel.filePath];
    }
}

// 下载完成 暂停 删除 取消 crash
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
//    NSLog(@"didCompleteWithError %s %d %@",__func__,__LINE__,error);
    
    CCDownloadModel *downloadModel = [self downLoadingModelForURLString:task.taskDescription];

    //如果是删除任务时，这里downloadModel ，应该会不存在的
    if (!downloadModel && task.state == NSURLSessionTaskStateCompleted) {
        //调用task cancel的时候， 这里竟然是 NSURLSessionTaskStateCompleted 这个状态
//        NSLog(@"取消，并且删除了数据");
        return;
    }
    
    downloadModel.progress.resumeBytesWritten = 0;

    //同步下载进度。 否则如果app强退时，本地的数据进度还是上次下载的
    //外部连续点击 可能会导致两个值都为0  这里做下判断
    if (task.countOfBytesReceived != 0 && task.countOfBytesExpectedToReceive != 0) {
        downloadModel.progress.totalBytesWritten = task.countOfBytesReceived;

        downloadModel.progress.totalBytesExpectedToWrite = task.countOfBytesExpectedToReceive;
        downloadModel.progress.resumeBytesWritten = task.countOfBytesExpectedToReceive - task.countOfBytesReceived;
        float progress = (double)task.countOfBytesReceived/task.countOfBytesExpectedToReceive;
        downloadModel.progress.progress = progress;
    }
    

    NSData * resumeData = nil;
    if (error) {
        resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
    }
    if (error && resumeData) {
        //暂停 取消 crash 情况
        downloadModel.resumeData = resumeData;
            
        // 手动取消，当做暂停
        dispatch_async(dispatch_get_main_queue(), ^(){
            downloadModel.state = CCDownloadStateSuspended;
            [self downloadModel:downloadModel error:nil];

            [self willResumeNextWithDowloadModel];
            
            //最后save 应该会好一点吧
            [self saveDownloadModels];
        });

    }else if (error && !resumeData){
        // 下载失败
        //如果是取消任务的话，会生成resumeData ，没有这个resumeData，证明下载失败了
        dispatch_async(dispatch_get_main_queue(), ^(){
            downloadModel.state = CCDownloadStateFailed;
            [self downloadModel:downloadModel error:error];

            [self willResumeNextWithDowloadModel];
            
            [self saveDownloadModels];
        });
    }else{
        //error 不存在
        //下载完成
        dispatch_async(dispatch_get_main_queue(), ^(){
            downloadModel.state = CCDownloadStateCompleted;
            [self downloadModel:downloadModel error:nil];
            
            //下载完成 ，清空resumeData
            downloadModel.resumeData = nil;
            [self willResumeNextWithDowloadModel];
            
            [self saveDownloadModels];
        });
    }
    
}

#pragma mark - private
//存储本地数据
-(BOOL)saveDownloadModels
{
    @synchronized (self) {
        //保存下载中的
        NSString * savePath = [NSString stringWithFormat:@"%@/%@",self.downloadDirectory,DOWNLOADMODELSAVENAME];
        return [NSKeyedArchiver archiveRootObject:self.downloadModels toFile:savePath];
    }
}

//  创建缓存目录文件
- (void)createDirectory:(NSString *)directory
{
    if (![self.fileManager fileExistsAtPath:directory]) {
        [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

//移动文件
- (void)moveFileAtURL:(NSURL *)srcURL toPath:(NSString *)dstPath
{
    if (!dstPath) {
        NSLog(@"error filePath is nil!");
        return;
    }
    NSError *error = nil;
    if ([self.fileManager fileExistsAtPath:dstPath] ) {
        [self.fileManager removeItemAtPath:dstPath error:&error];
        if (error) {
            NSLog(@"removeItem error %@",error);
        }
    }
    
    NSURL *dstURL = [NSURL fileURLWithPath:dstPath];
    [self.fileManager moveItemAtURL:srcURL toURL:dstURL error:&error];
    if (error){
        NSLog(@"moveItem error:%@",error);
    }
}

- (void)downloadModel:(CCDownloadModel *)downloadModel error:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(downloadModel:error:)]) {
        [_delegate downloadModel:downloadModel error:error];
    }

    if (downloadModel.stateBlock) {
        downloadModel.stateBlock(downloadModel, error);
    }
}

- (void)downloadModel:(CCDownloadModel *)downloadModel updateProgress:(CCDownloadProgress *)progress
{
    if (_delegate && [_delegate respondsToSelector:@selector(downloadModel:didUpdateProgress:)]) {
        [_delegate downloadModel:downloadModel didUpdateProgress:progress];
    }
    
    if (downloadModel.progressBlock) {
        downloadModel.progressBlock(progress,downloadModel);
    }
}

//判断resumeData 是否可用
- (BOOL)isValideResumeData:(NSData *)resumeData
{
    if (!resumeData || resumeData.length == 0) {
        return NO;
    }
    return YES;
}

//判断当前model是否已下载完成
-(BOOL)isCompletedDownload:(CCDownloadModel *)downloadModel
{
    if (downloadModel.state == CCDownloadStateCompleted) {
        return YES;
    }
    return NO;
}

//删除某个download的缓存文件，download对象的删除在外部进行操作
-(void)deleteLoaclDataAndDownloadModel:(CCDownloadModel *)downloadModel
{
    if (downloadModel.state == CCDownloadStateRunning) {
        //在下载中，先取消任务
        NSURLSessionDownloadTask * task = [self getDownloadTask:downloadModel];
//        [task cancel];
//        NSLog(@"%d  task:%@",__LINE__,task);
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            
        }];
    }
    
    //清空本地缓存文件
    if ([self.fileManager fileExistsAtPath:downloadModel.filePath]) {
        //如果下载已完成，那么本地才有文件 否则应该没有这个路径下的文件
        [self.fileManager removeItemAtPath:downloadModel.filePath error:nil];
    }
    
    NSString * otherFilePath = nil;
    if ([downloadModel.filePath hasSuffix:downloadModel.mimeType]) {
        otherFilePath = [downloadModel.filePath substringWithRange:NSMakeRange(0, downloadModel.filePath.length - (downloadModel.mimeType.length + 1))];
    }else{
        otherFilePath = [NSString stringWithFormat:@"%@.%@",downloadModel.filePath,downloadModel.mimeType];
    }
    if ([self.fileManager fileExistsAtPath:otherFilePath]) {
        [self.fileManager removeItemAtPath:otherFilePath error:nil];
    }
}

//控制下载任务 是否可以进行
- (BOOL)canResumeDownlaodModel:(CCDownloadModel *)downloadModel
{
    if (_isBatchDownload) {
        return YES;
    }
    
    @synchronized (self) {
        
        //查询当前有几个进行中的任务
        NSInteger downloadingCount = 0;
        for (CCDownloadModel * model in self.downloadModels) {
            if (model.state == CCDownloadStateRunning) {
                downloadingCount++;
            }
        }
        
        if (downloadingCount >= _maxDownloadCount) {
            downloadModel.state = CCDownloadStateReadying;
            [self downloadModel:downloadModel error:nil];

            return NO;
        }
        
        return YES;
    }
}

//开始下一个下载任务
- (void)willResumeNextWithDowloadModel
{
    if (_isBatchDownload) {
        return;
    }
    
    @synchronized (self) {
        //查找 是否还有在等待中的
        __weak typeof(self) weakSelf = self;
        if (_resumeDownloadFIFO) {
            //正序查找
            [self.downloadModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (((CCDownloadModel *)obj).state == CCDownloadStateReadying) {
                    [weakSelf resumeWithDownloadModel:obj];
                }
            }];
        }else{
            //倒序查找
            [self.downloadModels enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (((CCDownloadModel *)obj).state == CCDownloadStateReadying) {
                    [weakSelf resumeWithDownloadModel:obj];
                }
            }];
        }
    }
}

-(void)setMaxDownloadCount:(NSInteger)maxDownloadCount
{
    if (maxDownloadCount <= 0) {
        maxDownloadCount = 1;
    }
    
    if (maxDownloadCount > 4) {
        maxDownloadCount = 4;
    }

    _maxDownloadCount = maxDownloadCount;
}

//根据model 找到task
-(NSURLSessionDownloadTask *)getDownloadTask:(CCDownloadModel *)downloadModel
{
    @synchronized (self) {
        for (NSURLSessionDownloadTask * task in [self sessionDownloadTasks]) {
            if ([task.taskDescription isEqualToString:downloadModel.downloadURL]) {
                return task;
            }
        }
        return nil;
    }
}

// 获取所有的后台下载session
- (NSArray *)sessionDownloadTasks
{
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        tasks = downloadTasks;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    NSLog(@"%d %@",__LINE__,tasks);
    return tasks;
}

//重新生成resumeDataDict
-(NSDictionary *)getNewResumeOldResumeDict:(NSDictionary *)oldResumeDict NewRequestData:(NSData *)newRequestData WithUrlString:(NSString *)urlString
{
    NSMutableDictionary * returnDict = [NSMutableDictionary dictionary];
    [returnDict setObject:newRequestData forKey:@"NSURLSessionResumeCurrentRequest"];
    [returnDict setObject:urlString forKey:@"NSURLSessionDownloadURL"];
    [returnDict setObject:[oldResumeDict objectForKey:@"NSURLSessionResumeBytesReceived"] forKey:@"NSURLSessionResumeBytesReceived"];
    
    //NSURLSessionResumeInfoVersion  版本不同 字段稍有不同
    if ([[oldResumeDict objectForKey:@"NSURLSessionResumeInfoVersion"] integerValue] == 1) {
        //NSURLSessionResumeInfoLocalPath
        [returnDict setObject:[oldResumeDict objectForKey:@"NSURLSessionResumeInfoLocalPath"] forKey:@"NSURLSessionResumeInfoLocalPath"];
    }else{
        [returnDict setObject:[oldResumeDict objectForKey:@"NSURLSessionResumeInfoTempFileName"] forKey:@"NSURLSessionResumeInfoTempFileName"];
    }
    
    if ([oldResumeDict objectForKey:@"NSURLSessionResumeByteRange"]) {
        [returnDict setObject:[oldResumeDict objectForKey:@"NSURLSessionResumeByteRange"] forKey:@"NSURLSessionResumeByteRange"];
    }
    
    return returnDict;
}

/*

//开启定时器
-(void)startSaveTimer
{
    if (!self.saveTimer) {
        self.saveTimer = [NSTimer scheduledTimerWithTimeInterval:saveTimerSecond target:self selector:@selector(saveTimerAction) userInfo:nil repeats:YES];
    }
}

//关闭定时器
-(void)stopSaveTimer
{
    if (self.saveTimer) {
        [self.saveTimer invalidate];
        self.saveTimer = nil;
    }
}

-(void)saveTimerAction
{
    @autoreleasepool {
        NSArray * array = [NSArray arrayWithArray:self.downloadModels];
        BOOL canSave = NO;
        for (CCDownloadModel * downloadModel in array) {
            if (downloadModel.state == DWDownloadStateRunning) {
                //只要有一个正在进行中的任务，就存储
                canSave = YES;
                break;
            }
        }
        
        if (canSave) {
            if ([self saveDownloadModels]) {
                NSLog(@"%s save success",__func__);
            }
        }else{
            [self stopSaveTimer];
            NSLog(@"%s stopSaveTimer",__func__);
        }
    }
}
*/
     
//加密
-(void)createTokenKey:(CCDownloadModel *)downloadModel
{
 
}

//V6下存储pcm视频播放所需的key
-(void)writeConfigFile:(CCDownloadModel *)downloadModel
{

}

@end
