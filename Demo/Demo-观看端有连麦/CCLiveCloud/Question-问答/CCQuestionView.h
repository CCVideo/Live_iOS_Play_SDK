//
//  CCQuestionView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/6.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 问答回调

 @param message 发送的问答消息
 */
typedef void(^QuestionBlock)(NSString *message);

@interface CCQuestionView : UIView


/**
 初始化方法

 @param questionBlock 问答回调
 @param input 是否有输入框
 @return self
 */
-(instancetype)initWithQuestionBlock:(QuestionBlock)questionBlock input:(BOOL)input;

/**
 重载问答数据

 @param QADic 问答字典
 @param keysArrAll 回答字典
 */
-(void)reloadQADic:(NSMutableDictionary *)QADic keysArrAll:(NSMutableArray *)keysArrAll;

@end



NS_ASSUME_NONNULL_END
