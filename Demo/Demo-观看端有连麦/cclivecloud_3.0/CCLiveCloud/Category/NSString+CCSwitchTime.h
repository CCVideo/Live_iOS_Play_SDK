//
//  NSString+CCSwitchTime.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/10.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CCSwitchTime)

/**
 将某个时间转化成时间戳

 @param formatTime 时间
 @param format 格式
 @return 时间戳
 */
+ (NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format;


/**
 将某个时间戳转化成时间

 @param timestamp 时间戳
 @param format 格式
 @return 时间
 */
+ (NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format;


/**
 *    @brief    获取当前时间戳
 */
+ (NSString *)getNowTimeTimestamp;

@end

NS_ASSUME_NONNULL_END
