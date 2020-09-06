//
//  PrivateChatViewForOne.h
//  NewCCDemo
//
//  Created by cc on 2016/12/7.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

typedef void(^CloseBtnClicked)();//点击关闭按钮回调

typedef void(^ChatIcBtnClicked)();//聊天回调

typedef void(^IsResponseBlock)(CGFloat y);//回复回调

typedef void(^IsNotResponseBlock)();//不回复回调

@interface PrivateChatViewForOne : UIView


/**
 私聊界面初始化方法

 @param closeBlock 关闭回调
 @param chatBlock 聊天回调
 @param isResponseBlock 回复回调
 @param isNotResponseBlock 不回复回调
 @param dataArrayForOne 私聊数据数组
 @param anteid 私聊id
 @param anteName 私聊昵称
 @param isScreenLandScape 是否是全屏
 @return self
 */
-(instancetype)initWithCloseBlock:(CloseBtnClicked)closeBlock ChatClicked:(ChatIcBtnClicked)chatBlock isResponseBlock:(IsResponseBlock)isResponseBlock isNotResponseBlock:(IsNotResponseBlock)isNotResponseBlock dataArrayForOne:(NSMutableArray *)dataArrayForOne anteid:(NSString *)anteid anteName:(NSString *)anteName isScreenLandScape:(BOOL)isScreenLandScape;


/**
 更新私聊数据内容

 @param dataArray 私聊数组
 */
-(void)updateDataArray:(NSMutableArray *)dataArray;

@end
