//
//  NSURLSession+CCCorrectedResumeData.h
//  Demo
//
//  Created by luyang on 2017/4/18.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (CCCorrectedResumeData)

- (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData;

@end
