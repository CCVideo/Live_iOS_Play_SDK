//
//  QuestionNaire.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuestionNaire : UIView


/**
 初始化方法

 @param title 问卷标题
 @param url 第三方问卷链接
 @param isScreenLandScape 是否是全屏
 @return self
 */
-(instancetype)initWithTitle:(NSString *)title
                         url:(NSString *)url
           isScreenLandScape:(BOOL)isScreenLandScape;

@end
