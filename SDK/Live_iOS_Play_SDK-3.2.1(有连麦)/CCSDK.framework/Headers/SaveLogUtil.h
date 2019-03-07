//
//  SaveLogUtil.h
//  NewCCDemo
//
//  Created by ubuntu on 2017/11/20.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SDKVersion @"3.2.1"

@interface SaveLogUtil : NSObject

+ (instancetype)sharedInstance;

-(void)isNeedToSaveLog:(BOOL)needsave;

-(void)saveLog:(NSString *)logStr action:(NSString *)action;
-(NSString *)getCurrentSDKVersion;

@end
