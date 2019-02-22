//
//  CCAlertView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/25.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^AlertActionBlock)(NSInteger index);//点击回调

typedef void(^SureActionBlock)(void);//确认按钮回调

typedef void(^CancelActionBlock)(void);//取消按钮回调

typedef enum : NSUInteger {
    CCAlertStyleActionSheet,//操作表样式
    CCAlertStyleActionAlert,//提示框样式
} CCAlertStyle;
@interface CCAlertView : UIView


@property (nonatomic, copy)   AlertActionBlock actionBlock;

@property (nonatomic, copy)   CancelActionBlock cancelActionBlock;
/**
 初始化方法

 @param title 提示框的title
 @param alertStyle 提示的样式
 @param arr 按钮文字的数组
 @return self
 */
-(instancetype)initWithTitle:(nullable NSString *)title
                  alertStyle:(CCAlertStyle)alertStyle
                   actionArr:(nullable NSArray *)arr;


/**
 初始化提示框

 @param title 提示文字
 @param sure 确认文字
 @param cancel 取消文字
 @param block 确认回调
 @return l
 */
-(instancetype)initWithAlertTitle:(NSString *)title
                       sureAction:(nullable NSString *)sure
                     cancelAction:(nullable NSString *)cancel
                        sureBlock:(nullable SureActionBlock)block;
@end

NS_ASSUME_NONNULL_END
