//
//  NSString+Extension.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/27.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)
+(NSString *)stringWithFilterStr:(NSString *)fliterStr withType:(NSInteger)type{
    NSString *str = [NSString stringWithFormat:@"%@", fliterStr];
    if (type == 0) {
        if ([str isEqualToString:@"0"]) {
            return @"√";
        }
        if ([str isEqualToString:@"1"]) {
            return @"X";
        }
    }else {
        
        if ([str isEqualToString:@"0"]) {
            return @"A";
        }
        if ([str isEqualToString:@"1"]) {
            return @"B";
        }
        if ([str isEqualToString:@"2"]) {
            return @"C";
        }
        if ([str isEqualToString:@"3"]) {
            return @"D";
        }
        if ([str isEqualToString:@"4"]) {
            return @"E";
        }
        if ([str isEqualToString:@"5"]) {
            return @"F";
        }
    }
    return @"";
}
/**
 秒数转固定格式的时间字符串
 
 @param time 秒数
 @return 时间字符串
 */
+(NSString *)timeFormat:(NSInteger)time {
    NSInteger minutes = time / 60;
    NSInteger seconds = time % 60;
    NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d",(int)minutes,(int)seconds];
    return timeStr;
}
@end
