//
//  CCPlayerView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/31.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"
#import "InformationShowView.h"//提示框
#import "SelectMenuView.h"//更多菜单
#import "LoadingView.h"//加载
#import "CCDocView.h"//文档视图
NS_ASSUME_NONNULL_BEGIN

@protocol CCPlayerViewDelegate <NSObject>


/**
 点击全屏按钮代理

 @param tag 1为视频为主，2为文档为主
 */
- (void)quanpingButtonClick:(NSInteger)tag;


/**
 点击退出按钮(返回竖屏或者结束直播)

 @param sender backBtn
 @param tag changeBtn的标记，1为视频为主，2为文档为主
 */
- (void)backButtonClick:(UIButton *)sender changeBtnTag:(NSInteger)tag;

/**
 点击切换视频/文档按钮

 @param tag changeBtn的tag值
 */
-(void)changeBtnClicked:(NSInteger)tag;

@end

@interface CCPlayerView : UIView

@property (nonatomic, weak)id<CCPlayerViewDelegate>       delegate;
@property (nonatomic, strong)UIView                     * topShadowView;//上面的阴影
@property (nonatomic, strong)UIView                     * bottomShadowView;//下面的阴影
@property (nonatomic, strong)UIView                     * selectedIndexView;//选择线路背景视图
@property (nonatomic, strong)UIView                     * contentView;//横屏聊天视图
@property (nonatomic, strong)UILabel                    * titleLabel;//房间标题
@property (nonatomic, strong)UILabel                    * unStart;//直播未开始
@property (nonatomic, strong)UILabel                    * userCountLabel;//在线人数
@property (nonatomic, strong)UIButton                   * backButton;//返回按钮
@property (nonatomic, strong)UIButton                   * changeButton;//切换视频文档按钮
@property (nonatomic, strong)UIButton                   * quanpingButton;//全屏按钮
@property (nonatomic, strong)UIImageView                * liveUnStart;//直播未开始视图
//@property (nonatomic, strong)CustomTextField            * chatTextField;//横屏聊天

@property (nonatomic,copy) void(^selectedRod)(NSInteger);//切换线路
@property (nonatomic,copy) void(^sendChatMessage)(NSString *);//发送聊天
@property (nonatomic,copy) void(^selectedIndex)(NSInteger,NSInteger);//切换清晰度

@property(nonatomic,strong)SelectMenuView               *menuView;//选择菜单视图

@property (nonatomic,strong)CCDocView                * smallVideoView;//文档或者小图

@property (nonatomic,strong)LoadingView              * loadingView;//加载视图
@property (nonatomic,assign)BOOL                     endNormal;//是否直播结束
@property (nonatomic,assign)NSInteger                  templateType;//房间类型
@property (nonatomic,strong)InformationShowView      *informationViewPop;

@property (nonatomic,assign)BOOL                     isQuestionnaireSurveyKeyBoardAction;//是否是问卷调查键盘事件



/**
 初始化方法

 @param frame 视图大小
 @param isSmallDocView docView的显示样式
 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame docViewType:(BOOL)isSmallDocView;
//meauView点击方法
-(void)menuViewSelected:(BOOL)selected;


#pragma mark - 直播状态相关代理
/**
 *    @brief  收到播放直播状态 0直播 1未直播
 */
- (void)getPlayStatue:(NSInteger)status;
/**
 *    @brief  主讲开始推流
 */
- (void)onLiveStatusChangeStart;
/**
 *    @brief  停止直播，endNormal表示是否停止推流
 */
- (void)onLiveStatusChangeEnd:(BOOL)endNormal;
/**
 *  @brief  加载视频失败
 */
- (void)play_loadVideoFail;
#pragma mark- 视频或者文档大窗
/**
 *  @brief  视频或者文档大窗(The new method)
 *  isMain 1为视频为主,0为文档为主"
 */
- (void)onSwitchVideoDoc:(BOOL)isMain;


/**
 *  @brief  切换线路
 *  @param  firRoadNum 线路
 *  @param  secRoadKeyArray 清晰度[@"标清",@"高清"]
 */
- (void)SelectLinesWithFirRoad:(NSInteger)firRoadNum secRoadKeyArray:(NSArray *)secRoadKeyArray;

/**
 插入弹幕消息

 @param model 弹幕消息模型
 */
- (void)insertDanmuModel:(CCPublicChatModel *)model;
/**
小窗添加
 
 */
- (void)addSmallView;
/**
 *  @dict    房间信息用来处理弹幕开关,是否显示在线人数,直播倒计时等
*/
- (void)roominfo:(NSDictionary *)dict;

/**
 *  双击PPT时进入全屏，playView 统一的全屏方法
*/
- (void)quanpingBtnClick;

/**
 *  @tag 双击PPT退出全屏，默认tag值传2 playView 统一处理退出全屏
*/
- (void)backBtnClickWithTag:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END
