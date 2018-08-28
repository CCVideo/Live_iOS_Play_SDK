//
//  UIButtonImageLabel.m
//  NewCCDemo
//
//  Created by cc on 2016/11/22.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "UIButtonImageLabel.h"

@implementation UIButtonImageLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIImage*)createImageWithColor: (UIColor*) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (instancetype)buttonImage:(NSString *)image Label:(NSString *)label frame:(CGRect)frame {
    UIButtonImageLabel *button = [self buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = CCRGBColor(255,102,51);
    button.frame = frame;
    [button setTitle:label forState:UIControlStateNormal];
    UIImage *imageView = [UIImage imageNamed:image];
    [button setImage:imageView forState:UIControlStateNormal];
    [button setImage:imageView forState:UIControlStateHighlighted];
    [button setBackgroundImage:[button createImageWithColor:CCRGBColor(255,102,51)] forState:UIControlStateNormal];
    [button setBackgroundImage:[button createImageWithColor:CCRGBColor(248,92,40)] forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSDictionary *attributes = @{NSFontAttributeName:button.titleLabel.font};
    CGSize titleSize = [label boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil].size;
    CGSize imageSize = imageView.size;
    [button setImageEdgeInsets:UIEdgeInsetsMake(0,titleSize.width + CCGetRealFromPt(12) / 2,0,-(titleSize.width + CCGetRealFromPt(12) / 2))];
    
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0,-(imageSize.width + CCGetRealFromPt(12) / 2),0,(imageSize.width + CCGetRealFromPt(12) / 2))];
    
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:CCGetRealFromPt(8)];

    return button;
}

@end


















