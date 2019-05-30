//
//  UILabel+Extension.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/26.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "UILabel+Extension.h"

@implementation UILabel (Extension)
+ (UILabel *)labelWithText:(NSString *)text fontSize:(UIFont *)fontSize textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment{
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = fontSize;
    label.textColor = textColor;
    label.textAlignment = textAlignment;
    return label;
}
@end
