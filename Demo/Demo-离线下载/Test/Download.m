//
//  DrawBitmapView.h
//  CCavPlayDemo
//
//  Created by cc on 15/6/25.
//  Copyright (c) 2015年 ma yige. All rights reserved.
//

#import "Download.h"
#import "FileManager.h"

#define IOS12 [[UIDevice currentDevice].systemVersion floatValue]>=12?YES:NO

@interface Download ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property(nonatomic, strong)NSURLSession                *session;
@property(nonatomic, strong)NSURLSessionDownloadTask    *downloadTask;
@property(nonatomic,  copy)NSString                     *alreadyDownloadPath; // 已经下载下来的数据存放的位置。
@property(nonatomic,  copy)NSString                     *tempStr; // 临时文件路径

// 声明3个属性，用于计算下载速度
@property(nonatomic, assign)long long                   bytesRead;
@property(nonatomic, copy)  NSString                    *speed;

@end

@implementation Download

- (NSURLSession *)session{ // 建立请求
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)cancel {
    // 取消下载。
    [_downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        if (IOS12 && resumeData.length >0) {
            if (resumeData == nil) {
                
            }else { 
                NSMutableDictionary *plist = [[FileManager sharedInstance]plist];
                NSMutableDictionary *dicItem = [plist objectForKey:_downLoadUrl];
                [dicItem setObject:resumeData forKey:@"dataString"];
                [plist setObject:dicItem forKey:_downLoadUrl];
                [[FileManager sharedInstance]saveplist:plist];
            }
        }

    }];
    _downloadTask = nil;
}

// 开始下载
- (void)start {
    // 继续下载
    [self cancel];
    if ([self getResumeData]) {
        NSData * resumeData = [self getResumeData];
        _downloadTask = [self.session downloadTaskWithResumeData:resumeData];
    } else {
        _downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:_downLoadUrl]];
    }
    _date = [NSDate date];
    [_downloadTask resume];
}

// 下载完成调用的方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
        NSMutableDictionary *plist = [[FileManager sharedInstance]plist];
        NSMutableDictionary *dicItem = [plist objectForKey:_downLoadUrl];
    if(dicItem) {
        long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:location.path error:nil].fileSize;
        if(dicItem[@"totalSize"] == nil && fileSize > 5000) {
            _totalSize = fileSize;
            _alreadyDownLoadSize = _totalSize;
            _downloadType = DOWNLOAD_FINISH_NOTAVAILABLE;
            [dicItem setObject:[NSString stringWithFormat:@"%d",_downloadType] forKey:@"downloadType"];
            [dicItem setObject:[NSString stringWithFormat:@"%lld",_totalSize] forKey:@"alreadyDownLoadSize"];
            [dicItem setObject:[NSString stringWithFormat:@"%lld",_totalSize] forKey:@"totalSize"];
            // 将此字典更新至plist文件中
            [plist setObject:dicItem forKey:_downLoadUrl];
            // 更新数据库
            [[FileManager sharedInstance]saveplist:plist];

            // 如果正在下载的block实现了，则调取相应的block
            if (self.loadingBlock && _totalSize > 5000) {
                // 把速度转化为KB或M
                self.speed = [self formatByteCount:0];
                // 维护变量，将计算过的清零
                self.bytesRead = 0.0;
                self.loadingBlock(_alreadyDownLoadSize,_totalSize,self.speed);
            }
            
            NSString *toPath = [self.alreadyDownloadPath stringByAppendingString:self.fileName];
            NSLog(@"complet---location.path = %@,toPath = %@",location.path,toPath);
            [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:toPath error:nil];
            SaveToUserDefaults(_downLoadUrl, @(_totalSize));
            if (self.complet) {
                self.complet();
            }
        } else if ([dicItem[@"totalSize"] longLongValue] > 5000) {
            _downloadType = DOWNLOAD_FINISH_NOTAVAILABLE;
            _alreadyDownLoadSize = _totalSize;
            
            [dicItem setObject:[NSString stringWithFormat:@"%d",_downloadType] forKey:@"downloadType"];
            [dicItem setObject:[NSString stringWithFormat:@"%lld",_totalSize] forKey:@"alreadyDownLoadSize"];
            [dicItem setObject:[NSString stringWithFormat:@"%lld",_totalSize] forKey:@"totalSize"];
            // 将此字典更新至plist文件中
            [plist setObject:dicItem forKey:_downLoadUrl];
            // 更新数据库
            [[FileManager sharedInstance]saveplist:plist];
            
            NSString *toPath = [self.alreadyDownloadPath stringByAppendingString:self.fileName];
            NSLog(@"complet---location.path = %@,toPath = %@",location.path,toPath);
            [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:toPath error:nil];
            SaveToUserDefaults(_downLoadUrl, @(_totalSize));
            if (self.complet) {
                self.complet();
            }
        } else if(self.error) {
            [self URLSession:session error:nil];
        }
    }
}

// 定期发送的下载进度的通知
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    SaveToUserDefaults(_downLoadUrl, @(totalBytesWritten));
    
    NSDate *currentDate = [NSDate date];
    double time = [currentDate timeIntervalSinceDate:self.date];
    self.bytesRead+=bytesWritten;
    NSMutableDictionary *plist = [[FileManager sharedInstance]plist];
    NSMutableDictionary *dicItem = [plist objectForKey:_downLoadUrl];
    if(dicItem) {
        if (time > 1 && totalBytesExpectedToWrite > 5000) {
            _alreadyDownLoadSize = totalBytesWritten;
            _totalSize = totalBytesExpectedToWrite;
            
            [dicItem setObject:[NSString stringWithFormat:@"%lld",_alreadyDownLoadSize] forKey:@"alreadyDownLoadSize"];
            [dicItem setObject:[NSString stringWithFormat:@"%lld",_totalSize] forKey:@"totalSize"];
            // 将此字典更新至plist文件中
            [plist setObject:dicItem forKey:_downLoadUrl];
            // 更新数据库
            [[FileManager sharedInstance]saveplist:plist];
            // 判断是否存在当前的下载plist文件中
            [self saveResumeData];
            
            // 如果正在下载的block实现了，则调取相应的block
            if (self.loadingBlock && _totalSize > 5000) {
                // 计算速度
                long long speed = self.bytesRead/time;
                // 把速度转化为KB或M
                self.speed = [self formatByteCount:speed];
                // 维护变量，将计算过的清零
                self.bytesRead = 0.0;
                self.date = currentDate;
                self.loadingBlock(totalBytesWritten,totalBytesExpectedToWrite,self.speed);
                //        }
            } else if(self.error || _totalSize <= 5000){
                [self URLSession:session error:nil];
            }
        }
    }
}

-(NSString *)cleanResumeData:(NSString *)dataString {
    if([dataString containsString:@"<key>NSURLSessionResumeByteRange</key>"]) {
        NSRange rangeKey = [dataString rangeOfString:@"<key>NSURLSessionResumeByteRange</key>"];
        NSString *headStr = [dataString substringToIndex:rangeKey.location];
        NSString *backStr = [dataString substringFromIndex:rangeKey.location];
        
        NSRange rangeValue = [backStr rangeOfString:@"</string>\n\t"];
        NSString *tailStr = [backStr substringFromIndex:rangeValue.location + rangeValue.length];
        dataString = [headStr stringByAppendingString:tailStr];
        //            NSLog(@"dataString = %@",dataString);
    }
    return dataString;
}

// 将下载信息保存到本地
- (void)saveResumeData{ // 主要是完成了先将未名下载信息进行解析，获取其真正的信息。然后再接着下载。
    __weak typeof(self) vc = self;
    // 此方法就是要获取刚开始下载的那些data，先通过取消下载，获取到data，然后将data内的数据存储到本地。之后再data的基础上继续下载。
    [vc.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            NSMutableDictionary *plist = [[FileManager sharedInstance]plist];
            NSMutableDictionary *dicItem = [plist objectForKey:vc.downLoadUrl];
        
        
//        BOOL ios12 =[[UIDevice currentDevice].systemVersion floatValue]>=12?YES:NO;
        
        if (IOS12) {
            if (resumeData && dicItem) {
            [dicItem setObject:resumeData forKey:@"dataString"];
            [plist setObject:dicItem forKey:vc.downLoadUrl];
            [[FileManager sharedInstance]saveplist:plist];
            
            if(vc.downloadType == DOWNLOAD_LOADING) {
               
                vc.downloadTask = [vc.session downloadTaskWithResumeData:resumeData];
                // 继续下载
                [vc.downloadTask resume];
            }
            }
        }else {
        
         if (resumeData && dicItem) {
         NSString *dataString = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
         dataString = [self cleanResumeData:dataString];
         NSString *tempName = [dataString componentsSeparatedByString:@"<key>NSURLSessionResumeInfoTempFileName</key>\n\t<string>"].lastObject;
         tempName = [tempName componentsSeparatedByString:@"</string>"].firstObject;
         
         [dicItem setObject:tempName forKey:@"tempName"];
         [dicItem setObject:dataString forKey:@"dataString"];
         [plist setObject:dicItem forKey:vc.downLoadUrl];
         [[FileManager sharedInstance]saveplist:plist];
         vc.tempName = tempName;
         //                NSLog(@"---filename = %@,downloadsize = %lld,tempName = %@",self.fileName,_alreadyDownLoadSize,tempName);
         vc.downloadTask = nil;
         // 保存完信息之后开始继续下载。（不知道什么情况下会存在下载的东西不是自己点击的? 我知道了，就是要实现退出app还可以断点下载的。我去！）
         if(vc.downloadType == DOWNLOAD_LOADING) {
         vc.downloadTask = [vc.session downloadTaskWithResumeData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
         //                    vc.downloadTask = [vc.session downloadTaskWithResumeData:resumeData];
         // 继续下载
         [vc.downloadTask resume];
         }
         }
        }
    }];
}

// 获取已下载的data
- (NSData *)getResumeData{
    NSMutableDictionary *plist = [[FileManager sharedInstance]plist];
    NSMutableDictionary *dicItem = [plist objectForKey:_downLoadUrl];
    
    if (IOS12 && dicItem) {
        
        NSData *resumeData =[dicItem objectForKey:@"dataString"];
        return resumeData;
    } else {
         if(dicItem) {
         NSString *dataString = [dicItem objectForKey:@"dataString"];
         if (dataString.length > 0)
         {
         dataString = [self cleanResumeData:dataString];
         NSData *resumeData = [dataString  dataUsingEncoding:NSUTF8StringEncoding];
         NSError *error = nil;
         NSDictionary *resumeDic = [NSPropertyListSerialization propertyListWithData:resumeData options:NSPropertyListImmutable format:nil error:&error];
         //            NSLog(@"error:%@", error);
         NSMutableDictionary *muteResumeDic = [NSMutableDictionary dictionaryWithDictionary:resumeDic];
         [muteResumeDic setObject:GetFromUserDefaults(_downLoadUrl) forKey:@"NSURLSessionResumeBytesReceived"];
         //            NSLog(@"%s__%@", __func__, dataString);
         
         NSData *resume = [NSPropertyListSerialization dataWithPropertyList:muteResumeDic format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
         //        return [dataString dataUsingEncoding:NSUTF8StringEncoding];
         return resume;
         }
         }
    }
    return nil;
}

// 暂停
- (void)suspended{
    [self cancel];
}

- (void)URLSession:(NSURLSession *)session error:(NSError *)error {
    if(error) {
        NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        if(resumeData == nil) return;
        NSError *error = nil;
        NSDictionary *resumeDic = [NSPropertyListSerialization propertyListWithData:resumeData options:NSPropertyListImmutable format:nil error:&error];
//        NSLog(@"NSURLSessionResumeBytesReceived = %@",[resumeDic objectForKey:@"NSURLSessionResumeBytesReceived"]);
        SaveToUserDefaults(_downLoadUrl, [resumeDic objectForKey:@"NSURLSessionResumeBytesReceived"]);
    }
    
    if((error == nil || error.code != -999) && _downloadType != DOWNLOAD_FINISH_NOTAVAILABLE && _downloadType != DOWNLOAD_FINISH_AVAILABLE) {
        NSMutableDictionary *plist = [[FileManager sharedInstance]plist];
        NSMutableDictionary *dicItem = [plist objectForKey:self.downLoadUrl];
        if (self.error && dicItem) {
            self.error();
            self.downloadType = DOWNLOADD_ERROR;
            if (error && [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
                NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
                NSString *dataString = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
                NSString *tempName = [dataString componentsSeparatedByString:@"<key>NSURLSessionResumeInfoTempFileName</key>\n\t<string>"].lastObject;
                tempName = [tempName componentsSeparatedByString:@"</string>"].firstObject;
                
                [dicItem setObject:tempName forKey:@"tempName"];
                [dicItem setObject:dataString forKey:@"dataString"];
                self.tempName = tempName;
            }
            [dicItem setObject:[NSString stringWithFormat:@"%d",_downloadType] forKey:@"downloadType"];
            [plist setObject:dicItem forKey:self.downLoadUrl];
            [[FileManager sharedInstance]saveplist:plist];
        }
    }
}

#pragma mark - ------ 错误
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    NSLog(@"请求失效，error：%@，errorCode = %ld", error,error.code);
    [self URLSession:session error:error];
}

// 把速度转化为KB或者M
- (NSString *)formatByteCount:(long long)size{
    return [NSString stringWithFormat:@"%@/s",[NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    [self URLSession:session error:error];
}

// 懒加载获取几个地址路径
// 已经下载的路径
- (NSString *)alreadyDownloadPath{
    if (_alreadyDownloadPath == nil) {
        _alreadyDownloadPath = [NSString stringWithFormat:@"%@/Library/%@/", NSHomeDirectory(),@"Download"];
        // 在相应的路径创建对应的文件夹
        [[NSFileManager defaultManager] createDirectoryAtPath:_alreadyDownloadPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _alreadyDownloadPath;
}

// 临时文件夹
- (NSString *)tempStr{
    return [NSString stringWithFormat:@"%@/%@/", NSHomeDirectory(), @"tmp"];
}

@end





