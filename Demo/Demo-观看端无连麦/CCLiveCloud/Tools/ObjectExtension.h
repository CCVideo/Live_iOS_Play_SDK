//
//  NSString+ObjectExtension.h
//  proselfedu
//
//  Created by zwl on 2018/5/2.
//  Copyright © 2018年 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ObjectExtension)

//计算文本大小
-(CGSize)calculateRectWithSize:(CGSize)size Font:(UIFont *)font WithLineSpace:(CGFloat)lineSpace;

@end

@interface UIColor (ObjectExtension)

///生成色值
+(UIColor *)colorWithLight:(UIColor *)lightColor Dark:(UIColor *)darkColor;

//色值生成图片
-(UIImage*)createImage;

//根据size生成图片
-(UIImage*)createImageWithSize:(CGSize)size;

///判断色值是否相等
-(BOOL)isEqualColor:(UIColor *)otherColor;

@end

@interface UILabel (ObjectExtension)

-(CGRect)boundingRectForStringRange:(NSRange)range;

@end

