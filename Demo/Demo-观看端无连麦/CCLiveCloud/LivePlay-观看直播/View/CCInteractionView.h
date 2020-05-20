//
//  CCInteractionView.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/7.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCPlayerView.h"//观看直播视频
#import "CCChatBaseView.h"//聊天
#import "CCDocView.h"//文档视图
NS_ASSUME_NONNULL_BEGIN

//隐藏更多菜单视图回调
typedef void(^HiddenMenuViewBlock)(void);

//加载弹幕
typedef void(^InsertDanMuBlock)(CCPublicChatModel *model);

//加载私聊新消息提示回调
typedef void(^NewMessageBlock)(void);

//发送公聊回调
typedef void(^ChatMessageBlock)(NSString *msg);
//问答回调
typedef void(^QuestionBlock)(NSString *message);
//发送私聊回调
typedef void(^PrivateChatMessageBlock)(NSString *anteid, NSString *msg);

@interface CCInteractionView : UIView

@property (nonatomic,strong)UISegmentedControl       * segment;//功能切换,文档,聊天等
@property (nonatomic,strong)CCChatBaseView           * chatView;//聊天
@property (nonatomic,strong)CCPlayerView             * playerView;//观看直播视频
@property (nonatomic,copy)  NSString                 * groupId;//用户的guoupId
@property (nonatomic,strong)CCDocView                * docView;//文档视图
/**
 初始化方法

 @param frame frame
 @param block 隐藏menuView回调
 @return self
 */
-(instancetype)initWithFrame:(CGRect)frame
              hiddenMenuView:(HiddenMenuViewBlock)block
                   chatBlock:(ChatMessageBlock)chatBlock
            privateChatBlock:(PrivateChatBlock)privateChatBlock
               questionBlock:(QuestionBlock)questionBlock
                 docViewType:(BOOL)isSmallDocView;
#pragma mark - 移除聊天

/**
 移除聊天
 */
-(void)removeChatView;
#pragma mark - 代替代理接收事件类
//房间信息
-(void)roomInfo:(NSDictionary *)dic withPlayView:(CCPlayerView *)playerView smallView:(UIView *)smallView;

/**
 *    @brief    服务器端给自己设置的信息(The new method)
 *    viewerId 服务器端给自己设置的UserId
 *    groupId 分组id
 *    name 用户名
 */
-(void)setMyViewerInfo:(NSDictionary *) infoDic;


#pragma mark- 聊天
/**
 *    @brief    聊天管理(The new method)
 *    status    聊天消息的状态 0 显示 1 不显示
 *    chatIds   聊天消息的id列列表
 */
-(void)chatLogManage:(NSDictionary *) manageDic;
/**
 *    @brief    收到私聊信息
 */
- (void)OnPrivateChat:(NSDictionary *)dic withMsgBlock:(NewMessageBlock)block;

/**
 *    @brief  历史聊天数据
 *    @param  chatLogArr [{ chatId         //聊天ID
                           content         //聊天内容
                           groupId         //聊天组ID
                           time            //时间
                           userAvatar      //用户头像
                           userId          //用户ID
                           userName        //用户名称
                           userRole        //用户角色}]
 */
- (void)onChatLog:(NSArray *)chatLogArr;

/*
*  @brief  收到公聊消息
  @param  message {   groupId         //聊天组ID
                      msg             //消息内容
                      time            //发布时间
                      useravatar      //用户头像
                      userid          //用户ID
                      username        //用户名称
                      userrole        //用户角色}
*/
- (void)onPublicChatMessage:(NSDictionary *)dic;
/*
 *  @brief  收到自己的禁言消息，如果你被禁言了，你发出的消息只有你自己能看到，其他人看不到
   @param  message {   groupId         //聊天组ID
                       msg             //消息内容
                       time            //发布时间
                       useravatar      //用户头像
                       userid          //用户ID
                       username        //用户名称
                       userrole        //用户角色}
 */
- (void)onBanDeleteChatMessage:(NSDictionary *)dic;

/**
 *  @brief  接收到发送的广播
 */
- (void)broadcast_msg:(NSDictionary *)dic;

/*
 *  @brief  收到自己的禁言消息，如果你被禁言了，你发出的消息只有你自己能看到，其他人看不到
 */
- (void)onSilenceUserChatMessage:(NSDictionary *)message;

/**
 *    @brief    当主讲全体禁言时，你再发消息，会出发此代理方法，information是禁言提示信息
 */
- (void)information:(NSString *)information;

#pragma mark- 问答
//发布问题的id
-(void)publish_question:(NSString *)publishId;

/**
 *    @brief  收到提问，用户观看时和主讲的互动问答信息
 *    @param  questionDic { groupId         //分组ID
                            content         //问答内容
                            userName        //问答用户名
                            userId          //问答用户ID
                            time            //问答时间
                            id              //问答主键ID
                            useravatar      //用户化身 }
 */
- (void)onQuestionDic:(NSDictionary *)questionDic;

/**
 *    @brief  收到回答
 *    @param  answerDic {content            //回复内容
                         userName           //用户名
                         questionUserId     //问题用户ID
                         time               //回复时间
                         questionId         //问题ID
                         isPrivate          //1 私聊回复 0 公聊回复}
 */
- (void)onAnswerDic:(NSDictionary *)answerDic;

/**
*    @brief  收到历史提问&回答
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
- (void)onQuestionArr:(NSArray *)questionArr onAnswerArr:(NSArray *)answerArr;

//主动调用方法
/**
 *    @brief    提问
 *    @param     message 提问内容
 */
- (void)question:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
