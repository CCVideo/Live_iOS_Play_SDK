//
//  TopView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/26.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CloseBlock)(void);
@interface TopView : UIView


/**
 顶部视图背景

 @param title 顶部标题
 @param closeBlock 关闭按钮
 @return topView
 */
-(instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title closeBlock:(CloseBlock)closeBlock;


/**
 隐藏关闭按钮

 @param hidden 是否隐藏
 */
-(void)hiddenCloseBtn:(BOOL)hidden;
@end

NS_ASSUME_NONNULL_END
