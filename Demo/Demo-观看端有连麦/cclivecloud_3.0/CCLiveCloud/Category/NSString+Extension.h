//
//  NSString+Extension.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/27.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extension)

/**
 过滤字符串 将0.1.2.3转换为A,B,C,D

 @return 过滤后的字符串
 */
+(NSString *)stringWithFilterStr:(NSString *)fliterStr withType:(NSInteger)type;
/**
 秒数转固定格式的时间字符串
 
 @param time 秒数
 @return 时间字符串
 */
+(NSString *)timeFormat:(NSInteger)time;
@end

NS_ASSUME_NONNULL_END
