//
//  UIColor+RCColor.h
//  RCloudMessage
//
//  Created by Liv on 15/4/3.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RCColor)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

//UIColor 转UIImage
+ (UIImage*) imageWithColor: (UIColor*) color;
/// 生成随机颜色
///
/// @return 随机颜色
+ (UIColor *)cz_randomColor;
@end
