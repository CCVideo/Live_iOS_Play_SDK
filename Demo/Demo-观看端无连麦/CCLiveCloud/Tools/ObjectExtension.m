//
//  NSString+ObjectExtension.m
//  proselfedu
//
//  Created by zwl on 2018/5/2.
//  Copyright © 2018年 zwl. All rights reserved.
//

#import "ObjectExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ObjectExtension)

-(CGSize)calculateRectWithSize:(CGSize)size Font:(UIFont *)font WithLineSpace:(CGFloat)lineSpace;
{
    NSMutableParagraphStyle * pStyle = [[NSMutableParagraphStyle alloc]init];
    if (lineSpace != 0) {
        pStyle.lineSpacing = lineSpace;
    }
    CGSize returnSize = [self boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:pStyle} context:nil].size;
    
    
    //处理下是不是只有一行 只有一行的话 返回font.height
    if (ceil(returnSize.height) < (font.lineHeight * 2 + lineSpace)) {
        return CGSizeMake(ceil(returnSize.width), font.lineHeight);
    }
    
    return CGSizeMake(ceil(returnSize.width), ceil(returnSize.height));
}

@end

@implementation UIColor (ObjectExtension)

+(UIColor *)colorWithLight:(UIColor *)lightColor Dark:(UIColor *)darkColor
{
//    if (@available(iOS 13.0, *)) {
//        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
//            if (tc.userInterfaceStyle == UIUserInterfaceStyleLight){
//                return lightColor;
//            }else if (tc.userInterfaceStyle == UIUserInterfaceStyleDark){
//                return darkColor;
//            }
//            return lightColor;
//        }];
//    } else {
        return lightColor;
//    }
}

-(UIImage*)createImage
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(UIImage*)createImageWithSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(BOOL)isEqualColor:(UIColor *)otherColor
{
    if (CGColorEqualToColor(self.CGColor, otherColor.CGColor)) {
        return YES;
    }
    return NO;
}

@end

@implementation UILabel (ObjectExtension)

-(CGRect)boundingRectForStringRange:(NSRange)range
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:[self attributedText]];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:[self bounds].size];
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    return [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
}

@end

