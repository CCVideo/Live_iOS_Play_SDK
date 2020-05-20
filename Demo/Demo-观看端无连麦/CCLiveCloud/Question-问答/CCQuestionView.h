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
 *    @brief    问答来源
 *    QuestionSourceTypeFromLive 观看直播
 *    QuestionSourceTypeFromLiveHistory 直播查看历史问答
 *    QuestionSourceTypeFromReplay 观看回放
 */
typedef NS_ENUM(NSUInteger, QuestionSourceType) {
    QuestionSourceTypeFromLive,
    QuestionSourceTypeFromLiveHistory,
    QuestionSourceTypeFromReplay,
};

/**
 *    @brief    问答回调
 *    @param    message   发送的问答消息
 */
typedef void(^QuestionBlock)(NSString *message);

/**
 *    @brief    问答代理
 */
@protocol CCQuestionViewDelegate <NSObject>
@optional
/**
 *    @brief    直播查看历史问答代理方法
 *    @param    currentPage 当前分页
 */
- (void)livePlayLoadHistoryDataWithPage:(int)currentPage;
/**
 *    @brief    观看回放查看更多问答代理方法
 *    @param    currentPage   当前分页
 */
- (void)replayLoadMoreDataWithPage:(int)currentPage;

@end

@interface CCQuestionView : UIView

@property(nonatomic,weak)id<CCQuestionViewDelegate>delegate;

/**
 *    @brief    初始化方法
 *    @param questionBlock 问答回调
 *    @param input 是否有输入框
 *    @return self
 */
-(instancetype)initWithQuestionBlock:(QuestionBlock)questionBlock input:(BOOL)input;

/**
 *    @brief    重载问答数据
 *    @param QADic 问答字典
 *    @param keysArrAll 回答Key数组
 *    @param questionSourceType 问答数据来源
 *    @param currentPage 当前分页 （查看历史问答时传当前分页，否则传0）
 *                       查看历史问答：QuestionSourceTypeFromLiveHistory 和 QuestionSourceTypeFromReplay
 *    @param isDoneAllData 是否加载完所有数据 （查看历史问答时标记是否已加载全部问答，否则传YES）
 */
-(void)reloadQADic:(NSMutableDictionary *)QADic
        keysArrAll:(NSMutableArray *)keysArrAll
questionSourceType:(QuestionSourceType)questionSourceType
       currentPage:(int)currentPage
     isDoneAllData:(BOOL)isDoneAllData;


@end



NS_ASSUME_NONNULL_END
