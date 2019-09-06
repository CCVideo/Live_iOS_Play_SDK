//
//  UIButton+Extension.h
//  renrentong
//
//  Created by 刘川 on 16/7/6.
//  Copyright © 2016年 com.lanxum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIButton (Extension)

/** 设置图片和选择后的图片 **/
+(instancetype) buttonWithImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName tag:(NSInteger)tag target:(id)target sel:(SEL)sel;

/** 标题和背景 */
+ (instancetype) buttonWithTitle:(NSString*) title backGroudColor:(UIColor*) color;

-(void)setBackgroundWithStretchImageName:(NSString*)imageName;//设置拉伸的背景图片


/* 标题,文字颜色,文字大小 */
+ (instancetype) buttonWithTitle:(NSString*) title TitleColor:(UIColor*) color TitleSize:(CGFloat) size;


/** 标题,文字颜色,文字大小,icon图标 */
+ (instancetype) buttonWithTitle:(NSString*) title TitleColor:(UIColor*) color TitleSize:(CGFloat) size IconImage:(UIImage*) icon;


/** 标题,颜色,文字大小,普通背景图片,高亮背景图 */
+ (instancetype) buttonWithTitle:(NSString*) title TitleColor:(UIColor*) color TitleSize:(CGFloat) size BackgroundNormalImage:(UIImage*) backgroundNormalImage BackgroundHighlightedImage:(UIImage*) backgroundHighlightedImage;


/** 标题,颜色,文字大小,普通背景图片,高亮背景图 ,圆角半径,边框颜色,边框尺寸*/
+ (instancetype) buttonWithTitle:(NSString*) title TitleColor:(UIColor*) color TitleSize:(CGFloat) size BackgroundNormalImage:(UIImage*) backgroundNormalImage BackgroundHighlightedImage:(UIImage*) backgroundHighlightedImage CornerRadius:(CGFloat) cornerRadius BorderColor:(UIColor*) borderColor BorderWidth:(CGFloat) borderWidth;



@end

/**
 *  button
 */
@interface UIButton (MyFont)

@end


/**
 *  Label
 */
@interface UILabel (myFont)

@end

/**
 *  TextField
 */

@interface UITextField (myFont)

@end

/**
 *  TextView
 */
@interface UITextView (myFont)
@end
