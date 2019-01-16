//
//  ChatViewCell.h
//  CCLiveCloud
//
//  Created by 何龙 on 2018/12/12.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dialogue.h"
NS_ASSUME_NONNULL_BEGIN
//头像点击回调
typedef void(^HeadBtnClickBlock)(UIButton *btn);

typedef void(^ReloadBlock)(NSIndexPath *indexPath);

typedef void(^HiddenKeyBoradBlock)(BOOL hidden);

@interface ChatViewCell : UITableViewCell

/**
 头像点击回调
 */
@property (nonatomic, copy) HeadBtnClickBlock headBtnClickBlock;

/**
 刷新UI回调
 */
@property (nonatomic, copy) ReloadBlock reloadBlock;

/**
 隐藏键盘回调
 */
@property (nonatomic, copy) HiddenKeyBoradBlock hiddenBlock;

/**
 收到广播消息时调用的方法

 @param msg 广播消息
 */
-(void)setBroadcastUI:(NSString *)msg;

/**
 收到用户发送的消息

 @param model 数据模型
 @param input 是否有聊天输入
 @param indexPath cell位置
 */
-(void)setMessageUI:(Dialogue *)model
                    isInput:(BOOL)input
                      indexPath:(NSIndexPath *)indexPath;


@end

NS_ASSUME_NONNULL_END
