//
//  CCPlayBackInteractionView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/14.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCPlayBackView.h"//视频视图
#import "LoadingView.h"//加载
#import "InformationShowView.h"//提示
#import "CCSDK/SaveLogUtil.h"//日志
#import "CCIntroductionView.h"//简介
#import "CCQuestionView.h"//问答
#import "Dialogue.h"//模型
#import "CCChatBaseView.h"//新聊天
#import "CCChatViewDataSourceManager.h"//聊天数据处理
#import "CCDocView.h"//文档
NS_ASSUME_NONNULL_BEGIN

@interface CCPlayBackInteractionView : UIView
@property (nonatomic,assign)BOOL                          isScreenLandScape;//是否横屏
@property (nonatomic,assign)float                         playBackRate;//播放速率
@property (nonatomic,strong)UIView                      * shadowView;//滚动条
@property (nonatomic,strong)UIView                      * lineView;
@property (nonatomic,strong)UIView                      * line;
@property (nonatomic,strong)NSTimer                     * timer;//计时器
@property (nonatomic,copy)  NSString                    * roomName;
@property (nonatomic,strong)UIButton                    * changeButton;//切换窗口
@property (nonatomic,assign)NSInteger                     sliderValue;//滑动值
@property (nonatomic,assign)NSInteger                     templateType;
@property (nonatomic,strong)LoadingView                 * loadingView;//加载视图
@property (nonatomic,strong)UIScrollView                * scrollView;
@property (nonatomic,strong)UISegmentedControl          * segment;//功能切换,文档,聊天等

@property (nonatomic,strong)CCIntroductionView          * introductionView;//简介视图

@property (nonatomic,strong)CCQuestionView              * questionChatView;//问答视图
@property (nonatomic,strong)NSMutableDictionary         * QADic;//问答z字典
@property (nonatomic,strong)NSMutableArray              * keysArrAll;//所有数据

@property (nonatomic,strong)CCChatViewDataSourceManager * manager;//数据处理
@property (nonatomic,strong)CCChatBaseView              * chatView;//聊天
@property (nonatomic,strong)NSMutableArray              * publicChatArray;//公聊
@property (nonatomic,assign)int                           currentChatTime;//当前聊天时间
@property (nonatomic,assign)int                           currentChatIndex;//当前索引
@property (nonatomic,copy)  NSString                    * groupId;//聊天分组

@property (nonatomic,strong)CCDocView                   * docView;//文档


/**
 初始化方法

 @param frame frame
 @param isSmallDocView 是否是文档小窗模式
 @return self
 */
-(instancetype)initWithFrame:(CGRect)frame docViewType:(BOOL)isSmallDocView;

#pragma mark- 房间信息
/**
 *    @brief  获取房间信息，主要是要获取直播间模版来类型，根据直播间模版类型来确定界面布局
 *    房间简介：dic[@"desc"];
 *    房间名称：dic[@"name"];
 *    房间模版类型：[dic[@"templateType"] integerValue];
 *    模版类型为1: 聊天互动： 无 直播文档： 无 直播问答： 无
 *    模版类型为2: 聊天互动： 有 直播文档： 无 直播问答： 有
 *    模版类型为3: 聊天互动： 有 直播文档： 无 直播问答： 无
 *    模版类型为4: 聊天互动： 有 直播文档： 有 直播问答： 无
 *    模版类型为5: 聊天互动： 有 直播文档： 有 直播问答： 有
 *    模版类型为6: 聊天互动： 无 直播文档： 无 直播问答： 有
 */
-(void)roomInfo:(NSDictionary *)dic playerView:(CCPlayBackView *)playerView;
#pragma mark- 聊天
/**
 *    @brief    解析本房间的历史聊天数据
 */
-(void)onParserChat:(NSArray *)chatArr;
/* 自定义方法 */
/**
 *    @brief    通过传入时间获取聊天信息
 */
-(void)parseChatOnTime:(int)time;
#pragma mark- 问答
/**
 *    @brief  收到提问&回答
 *    @param  questionArr [{content             //问答内容
                            encryptId           //加密ID
                            groupId             //分组ID
                            isPublish           //1 发布的问答 0 未发布的问答
                            questionUserId      //问答用户ID
                            questionUserName    //问答用户名
                            time                //问答时间
                            triggerTime         //问答具体时间}]
 *    @param  answerArr  [{answerUserId         //回复用户ID
                           answerUserName       //回复名
                           answerUserRole       //回复角色（主讲、助教）
                           content              //回复内容
                           encryptId            //加密ID
                           groupId              //分组ID
                           isPrivate            //1 私聊回复 0 公共回复
                           time = 135;          //回复时间
                           triggerTime          //回复具体时间}]
 */
- (void)onParserQuestionArr:(NSArray *)questionArr onParserAnswerArr:(NSArray *)answerArr;

#pragma mark - 移除数据（退出回放时调用)
-(void)removeData;

@end

NS_ASSUME_NONNULL_END
