//
//  UILabel+Extension.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/26.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Extension)

/**
 创建一个label

 @param text label内容
 @param fontSize 文字大小
 @param textColor 文字颜色
 @param textAlignment 文字样式
 @return label
 */
+(UILabel *)labelWithText:(NSString *)text
                 fontSize:(UIFont *)fontSize
                textColor:(UIColor *)textColor
            textAlignment:(NSTextAlignment)textAlignment;

@end

NS_ASSUME_NONNULL_END
