//
//  QuestionnaireSurvey.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>
//关闭按钮回调
typedef void(^CloseBlock)(void);
//提交按钮回调
typedef void(^CommitBlock)(NSDictionary *dic);

@interface QuestionnaireSurvey : UIView


/**
 初始化方法

 @param closeblock 关闭视图回调
 @param commitblock 提交回调
 @param questionnaireDic 问卷字典
 @param isScreenLandScape 是否全屏
 @param isStastic 是否是统计
 @return self
 */
-(instancetype)initWithCloseBlock:(CloseBlock)closeblock
                      CommitBlock:(CommitBlock)commitblock
                 questionnaireDic:(NSDictionary *)questionnaireDic
                isScreenLandScape:(BOOL)isScreenLandScape
                        isStastic:(BOOL)isStastic;

/**
 提交成功

 @param success 提交回调调用的方法
 */
-(void)commitSuccess:(BOOL)success;

@end
