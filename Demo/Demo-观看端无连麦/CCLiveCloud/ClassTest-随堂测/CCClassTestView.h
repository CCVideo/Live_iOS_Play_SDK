//
//  CCClassTestView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/25.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface CCClassTestView : UIView

//@property (nonatomic, assign) BOOL     shouldRmove;//是否需要移除


@property (nonatomic, copy)void(^StaticBlock)(NSString *practiceId);// 获取统计回调
@property (nonatomic, copy)void(^CommitBlock)(NSArray *arr);//提交答案回调



/**
 *    @brief    初始化方法
 *    @param testDic 随堂测答题选项字典 testDic[@"practice"][@"Type"] :0 判断，1 单选，2 多选
 *    @param isScreenLandScape 是否是全屏
 *    @return self;
 */
-(instancetype)initWithTestDic:(NSDictionary *)testDic
             isScreenLandScape:(BOOL)isScreenLandScape;

/**
 *    @brief    得到答题统计
 *    @param    resultDic 统计结果字典
 *    @param    isScreen  是否全屏
 */
-(void)getPracticeStatisWithResultDic:(NSDictionary *)resultDic isScreen:(BOOL)isScreen;
/**
 *    @brief    随堂测提交结果(The new method)
 *    rseultDic    提交结果,调用commitPracticeWithPracticeId:(NSString *)practiceId options:(NSArray *)options后执行
 */
-(void)practiceSubmitResultsWithDic:(NSDictionary *) resultDic;

/**
 停止测试
 */
-(void)stopTest;

/**
 关闭计时器
 */
-(void)stopTimer;
@end

NS_ASSUME_NONNULL_END
