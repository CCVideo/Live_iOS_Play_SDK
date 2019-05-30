//
//  CCChatBaseView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/21.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCPrivateChatView.h"//私聊

NS_ASSUME_NONNULL_BEGIN
typedef void(^PublicChatBlock)(NSString *msg);//公聊发送消息回调

typedef void(^PrivateChatBlock)(NSString *anteid,NSString *msg);//私聊发送消息回调

@interface CCChatBaseView : UIView
@property (nonatomic, strong)CCPrivateChatView            *ccPrivateChatView;//私聊视图
@property (nonatomic, strong)NSMutableArray               *publicChatArray;//公聊数组
@property (nonatomic, copy)  PrivateChatBlock             privateChatBlock;//私聊回调

/**
 初始化方法

 @param block 公聊回调
 @param input 是否有输入框
 @return self
 */
-(instancetype)initWithPublicChatBlock:(PublicChatBlock)block
                               isInput:(BOOL)input;


/**
 reload所有公聊视图

 @param array 公聊数组
 */
-(void)reloadPublicChatArray:(NSMutableArray *)array;


/**
 添加公聊数组，并且reload(ps:适用于直播回放加载)

 @param array 直播回放的时候,每秒钟加载一些数据,用array盛放这一秒中的聊天数组
 */
- (void)addPublicChatArray:(NSMutableArray *)array;


/**
 添加一条公聊聊天

 @param object dataSource处理过的数组,需要处理最后一条数据，并加载
 */
-(void)addPublicChat:(id)object;

/**
 刷新私聊

 @param dict 私聊字典
 */
- (void)reloadPrivateChatDict:(NSMutableDictionary *)dict anteName:anteName anteid:anteid;

/**
 点击私聊按钮(ps:点击menuView的时候，需要主动调用此方法,用来弹出私聊视图);
 */
-(void)privateChatBtnClicked;
/**
 聊天审核,刷新聊天记录
 
 @param arr 需要被刷新的某一行数组
 @param publicArr 更新过的数组
 */
-(void)reloadStatusWithIndexPaths:(NSMutableArray *)arr
                        publicArr:(NSMutableArray *)publicArr;

/**
 图片刷新
 
 @param indexPath 需要被刷新的某一行数组
 @param publicArr 更新过的数组
 */
-(void)reloadStatusWithIndexPath:(NSIndexPath *)indexPath
                        publicArr:(NSMutableArray *)publicArr;
@end

NS_ASSUME_NONNULL_END
