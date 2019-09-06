//
//  CCPrivateChatView.h
//  NewCCDemo
//
//  Created by cc on 2016/12/7.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateChatViewForOne.h"
#import "Dialogue.h"

typedef void(^CloseBtnClicked)();//关闭按钮回调

typedef void(^IsResponseBlock)(CGFloat y);//是否是回复回调

typedef void(^IsNotResponseBlock)();//不回复回调

typedef void(^CheckDotBlock)(BOOL flag);//新消息标记

@interface CCPrivateChatView : UIView

@property(nonatomic,strong)PrivateChatViewForOne    *privateChatViewForOne;//私聊对话视图


/**
 点击聊天中的头像

 @param dialogue model
 */
-(void)selectByClickHead:(Dialogue *)dialogue;


/**
 创建一个私聊对话视图

 @param dataArrayForOne 1对1 对话聊天数组
 @param anteid 私聊id
 @param anteName 私聊名称
 */
-(void)createPrivateChatViewForOne:(NSMutableArray *)dataArrayForOne anteid:(NSString *)anteid anteName:(NSString *)anteName;


/**
 初始化方法

 @param closeBlock 关闭按钮
 @param isResponseBlock 回复回调
 @param isNotResponseBlock 不回复回调
 @param dataPrivateDic 私聊字典
 @param isScreenLandScape 是否是全屏
 @return self
 */
-(instancetype)initWithCloseBlock:(CloseBtnClicked)closeBlock isResponseBlock:(IsResponseBlock)isResponseBlock isNotResponseBlock:(IsNotResponseBlock)isNotResponseBlock dataPrivateDic:(NSMutableDictionary *)dataPrivateDic isScreenLandScape:(BOOL)isScreenLandScape;


/**
 新消息回调

 @param block 新消息标记回调
 */
-(void)setCheckDotBlock1:(CheckDotBlock)block;


/**
 更新字典

 @param dic 私聊字典
 */
-(void)reloadDict:(NSDictionary *)dic anteName:anteName anteid:anteid;


/**
 显示tableView
 */
-(void)showTableView;


/**
 隐藏或显示私聊视图

 @param hidden 是否隐藏
 */
-(void)hiddenPrivateViewForOne:(BOOL)hidden;

@end
