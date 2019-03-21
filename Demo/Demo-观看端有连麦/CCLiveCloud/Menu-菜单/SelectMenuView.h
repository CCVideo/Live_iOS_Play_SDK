//
//  SelectMenuView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2018/12/24.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    NewPrivateMessage,//新私聊
    NewAnnouncementMessage,//新公告
} NewMessageState;
//私聊回调
typedef void(^PrivateBlock)(void);
//#ifdef LIANMAI_WEBRTC
//连麦回调
typedef void(^LianmaiBlock)(void);
//#endif
//公告回调
typedef void(^AnnouncementBlock)(void);

@interface SelectMenuView : UIView

@property (nonatomic, strong) UIButton         *menuBtn;//菜单按钮
@property (nonatomic, strong) UIButton         *privateChatBtn;//私聊按钮
@property (nonatomic, strong) UIButton         *lianmaiBtn;//连麦按钮
//#ifdef LIANMAI_WEBRTC
//连麦点击回调
@property (nonatomic, copy) LianmaiBlock             lianmaiBlock;
//#endif
@property (nonatomic, strong) UIButton         *announcementBtn;//公告按钮
//私聊点击回调
@property (nonatomic, copy) PrivateBlock             privateBlock;
//公告点击回调
@property (nonatomic, copy) AnnouncementBlock        announcementBlock;

/**
 隐藏btn方法

 @param hidden 是否隐藏
 */
-(void)hiddenAllBtns:(BOOL)hidden;

/**
 隐藏menuView
 
 @param hidden 是否隐藏
 */
-(void)hiddenMenuViews:(BOOL)hidden;


/**
 隐藏私聊按钮(适配无聊天的房间类型)
 */
-(void)hiddenPrivateBtn;

#pragma mark - 新消息提醒
/**
 新消息提示

 @param messageState 消息内容
 */
-(void)showInformationViewWithTitle:(NewMessageState)messageState;

/**
 更新新消息
 */
-(void)updateMessageFrame;

/**
 移除新消息
 */
-(void)removeAllInformationView;

@end

NS_ASSUME_NONNULL_END
