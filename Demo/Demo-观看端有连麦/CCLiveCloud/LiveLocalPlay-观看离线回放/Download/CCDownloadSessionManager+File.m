//
//  CCDownloadSessionManager+File.m
//  Demo
//
//  Created by zwl on 2019/5/5.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "CCDownloadSessionManager+File.h"
#import <objc/message.h>

@interface CCDownloadModel ()
//下载地址
@property (nonatomic, strong) NSString * downloadURL;
//文件名
@property (nonatomic, strong) NSString * fileName;
//文件后缀名
@property (nonatomic,strong) NSString * mimeType;

@end

//现阶段，给直播组使用。 仅下载文件。不做其他用途

@implementation CCDownloadSessionManager (File)

+(CCDownloadModel *)createDownloadModelWithUrl:(NSString *)downloadURL FileName:(NSString *)fileName MimeType:(NSString *)mimeType AndOthersInfo:(NSDictionary *)othersInfo
{
    if (!downloadURL) {
        return nil;
    }
    
    CCDownloadModel * downloadModel = [[CCDownloadModel alloc]init];
    downloadModel.downloadURL = [downloadURL copy];
    downloadModel.mimeType = [mimeType copy];
    downloadModel.othersInfo = othersInfo;
    downloadModel.fileName = [NSString stringWithFormat:@"%@.%@",fileName,downloadModel.mimeType];
    downloadModel.decompressionState = 0;
    return downloadModel;
}

-(void)decompressionFinish:(CCDownloadModel *)downloadModel
{
    /*
     1.删除旧路径文件
     2.改名
     3.保存本地
     */
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:downloadModel.filePath]) {
        NSError * error = nil;
        if (![fileManager removeItemAtPath:downloadModel.filePath error:&error]) {
            NSLog(@"文件删除失败 error:%@",error);
        }
    }
    downloadModel.fileName = [downloadModel.fileName substringWithRange:NSMakeRange(0, downloadModel.fileName.length - (downloadModel.mimeType.length + 1))];
    downloadModel.decompressionState = 2;
    
#if !OBJC_OLD_DISPATCH_PROTOTYPES
    ((void (*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"saveDownloadModels"));
#else
    objc_msgSend(self, NSSelectorFromString(@"saveDownloadModels"));
#endif

}

-(BOOL)checkLocalResourceWithUrl:(NSString *)downloadURL
{
    if (!downloadURL) {
        return NO;
    }
    
    for (CCDownloadModel * model in self.downloadModelList) {
        if ([model.downloadURL isEqualToString:downloadURL]) {
            return YES;
        }
    }
    
    return NO;
}

@end
