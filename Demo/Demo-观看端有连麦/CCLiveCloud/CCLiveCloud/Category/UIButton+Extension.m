//
//  UIButton+Extension.m
//  renrentong
//
//  Created by 刘川 on 16/7/6.
//  Copyright © 2016年 com.lanxum. All rights reserved.
//

#import "UIButton+Extension.h"



@implementation UIButton (Extension)
/** 设置图片和选择后的图片 **/
+ (instancetype)buttonWithImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName tag:(NSInteger)tag target:(id)target sel:(SEL)sel{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
    btn.tag = tag;
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
/** 普通标题和背景颜色 */
+ (instancetype) buttonWithTitle:(NSString*) title backGroudColor:(UIColor*) color
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.layer.cornerRadius = 5;
    [btn.layer masksToBounds];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateHighlighted];
    [btn setBackgroundColor:color];
    return btn;
}


/**标题,文字颜色,文字大小 */
+ (instancetype) buttonWithTitle:(NSString*) title TitleColor:(UIColor*) color TitleSize:(CGFloat) size{
    UIButton *customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBtn setTitle:title forState:UIControlStateNormal];
    [customBtn setTitleColor:color forState:UIControlStateNormal];
    customBtn.titleLabel.font = [UIFont systemFontOfSize:size];
    return customBtn;
}


/**标题,文字颜色,文字大小,icon图标 */
+ (instancetype) buttonWithTitle:(NSString*) title TitleColor:(UIColor*) color TitleSize:(CGFloat) size IconImage:(UIImage*) icon{
    UIButton *customBtn = [self buttonWithTitle:title TitleColor:color TitleSize:size];
    [customBtn setImage:icon forState:UIControlStateNormal];
    return customBtn;
}


/**标题,颜色,文字大小,普通背景图片,高亮背景图 */
+ (instancetype) buttonWithTitle:(NSString*) title TitleColor:(UIColor*) color TitleSize:(CGFloat) size BackgroundNormalImage:(UIImage*) backgroundNormalImage BackgroundHighlightedImage:(UIImage*) backgroundHighlightedImage{
    UIButton *customBtn = [self buttonWithTitle:title TitleColor:color TitleSize:size];
    [customBtn setBackgroundImage:backgroundNormalImage forState:UIControlStateNormal];
    [customBtn setBackgroundImage:backgroundHighlightedImage forState:UIControlStateHighlighted];
    return customBtn;
}
/**标题,颜色,文字大小,普通背景图片,高亮背景图 ,圆角半径,边框颜色,边框尺寸*/
+ (instancetype) buttonWithTitle:(NSString*) title TitleColor:(UIColor*) color TitleSize:(CGFloat) size BackgroundNormalImage:(UIImage*) backgroundNormalImage BackgroundHighlightedImage:(UIImage*) backgroundHighlightedImage CornerRadius:(CGFloat) cornerRadius BorderColor:(UIColor*) borderColor BorderWidth:(CGFloat) borderWidth{
    UIButton *customBtn = [self buttonWithTitle:title TitleColor:color TitleSize:size BackgroundNormalImage:backgroundNormalImage BackgroundHighlightedImage:backgroundHighlightedImage];
    if (cornerRadius !=0) {
        [customBtn.layer setCornerRadius:cornerRadius];
        [customBtn.layer setMasksToBounds:YES];
    }
    if (borderColor) {
        customBtn.layer.borderColor = [borderColor CGColor];
    }
    if (borderWidth != 0) {
        customBtn.layer.borderWidth = borderWidth;
    }
    return customBtn;
}

-(void)setBackgroundWithStretchImageName:(NSString*)imageName{
    UIImage*bgImage=[UIImage imageNamed:imageName];
    bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(bgImage.size.height/2-1, bgImage.size.width/2-1, bgImage.size.height/2-1, bgImage.size.width/2-1) resizingMode:UIImageResizingModeStretch];
    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
}


@end

//@implementation UIButton (MyFont)
//
//+ (void)load{
//    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
//    Method myImp = class_getInstanceMethod([self class], @selector(myInitWithCoder:));
//    method_exchangeImplementations(imp, myImp);
//}
//
//- (id)myInitWithCoder:(NSCoder*)aDecode{
//    [self myInitWithCoder:aDecode];
//    if (self) {
//        
//        //部分不像改变字体的把tag值设置成333跳过
//        if(self.titleLabel.tag !=333){
//            CGFloat fontSize =self.titleLabel.font.pointSize;
//            self.titleLabel.font = [UIFont systemFontOfSize:fontSize * WIDTH_RATIO];
//        }
//    }
//    return self;
//}
//
//@end
//
//
//@implementation UILabel (myFont)
//
//+ (void)load{
//    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
//    Method myImp = class_getInstanceMethod([self class], @selector(myInitWithCoder:));
//    method_exchangeImplementations(imp, myImp);
//}
//
//- (id)myInitWithCoder:(NSCoder*)aDecode{
//    [self myInitWithCoder:aDecode];
//    if (self) {
//        //部分不像改变字体的把tag值设置成333跳过
//        if(self.tag !=333){
//            CGFloat fontSize =self.font.pointSize;
//            self.font = [UIFont systemFontOfSize:fontSize * WIDTH_RATIO];
//        }
//    }
//    return self;
//}
//
//@end
//
//@implementation UITextField (myFont)
//
//+ (void)load{
//    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
//    Method myImp = class_getInstanceMethod([self class], @selector(myInitWithCoder:));
//    method_exchangeImplementations(imp, myImp);
//}
//
//- (id)myInitWithCoder:(NSCoder*)aDecode{
//    [self myInitWithCoder:aDecode];
//    if (self) {
//        //部分不像改变字体的把tag值设置成333跳过
//        if(self.tag !=333){
//            CGFloat fontSize =self.font.pointSize;
//            self.font = [UIFont systemFontOfSize:fontSize * WIDTH_RATIO];
//        }
//    }
//    return self;
//}
//
//@end
//
//@implementation UITextView (myFont)
//
//+ (void)load{
//    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
//    Method myImp = class_getInstanceMethod([self class], @selector(myInitWithCoder:));
//    method_exchangeImplementations(imp, myImp);
//}
//
//- (id)myInitWithCoder:(NSCoder*)aDecode{
//    [self myInitWithCoder:aDecode];
//    if (self) {
//        //部分不像改变字体的把tag值设置成333跳过
//        if(self.tag !=333){
//            CGFloat fontSize =self.font.pointSize;
//            self.font = [UIFont systemFontOfSize:fontSize * WIDTH_RATIO];
//        }
//    }
//    return self;
//}
//
//@end

