//
//  Parameter.h
//  CCLivePlayDemo
//
//  Created by cc on 2017/3/9.
//  Copyright © 2017年 ma yige. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PlayParameter : NSObject
/**
 *  @brief 用户ID
 */
@property(nonatomic, copy)NSString                      *userId;//用户ID
/**
 *  @brief 用户ID
 */
@property(nonatomic, copy)NSString                      *roomId;//用户ID
/**
 *  @brief 用户名称
 */
@property(nonatomic, copy)NSString                      *viewerName;//用户名称
/**
 *  @brief 房间密码
 */
@property(nonatomic, copy)NSString                      *token;//房间密码
/**
 *  @brief 直播ID，回放时才用到
 */
@property(nonatomic, copy)NSString                      *liveId;//直播ID，回放时才用到
/**
 *  @brief 回放ID
 */
@property(nonatomic, copy)NSString                      *recordId;//回放ID
/**
 *  @brief 用户自定义参数，需和后台协商，没有定制传@""
 */
@property(nonatomic, copy)NSString                      *viewerCustomua;//用户自定义参数，需和后台协商，没有定制传@""
/**
 * json格式字符串，可选，自定义用户信息，该信息会记录在用户访问记录中，用于统计分析使用（长度不能超过1000个字符，若直播间启用接口验证则该参数无效）如果不需要的话就不要传值
 * 格式如下：
 * viewercustominfo: '{"exportInfos": [ {"key": "城市", "value": "北京"}, {"key": "姓名", "value": "哈哈"}]}'
 */
@property(nonatomic, copy)NSString                      *viewercustominfo;
/**
 *  @brief 下载文件解压到的目录路径(离线下载相关)
 */
@property(nonatomic, copy)NSString                      *destination;//下载文件解压到的目录路径(离线下载相关)
/**
 *  @brief 文档父类窗口
 */
@property(nonatomic,strong)UIView                       *docParent;//文档父类窗口
/**
 *  @brief 文档区域
 */
@property(nonatomic,assign)CGRect                       docFrame;//文档区域
/**
 *  @brief 视频父类窗口
 */
@property(nonatomic,strong)UIView                       *playerParent;//视频父类窗口
/**
 *  @brief 视频区域
 */
@property(nonatomic,assign)CGRect                       playerFrame;//视频区域
/**
 *  @brief 是否使用https
 */
@property(nonatomic,assign)BOOL                         security;//是否使用https(已弃用!)
/**
 *  @brief 屏幕适配方式
 * 0:IJKMPMovieScalingModeNone
 * 1:IJKMPMovieScalingModeAspectFit
 * 2:IJKMPMovieScalingModeAspectFill
 * 3:IJKMPMovieScalingModeFill
 */
@property(assign, nonatomic)NSInteger                   scalingMode;//屏幕适配方式，含义见上面
/**
 *  @brief ppt默认底色，不写默认为白色
 */
@property(nonatomic,strong)UIColor                      *defaultColor;//ppt默认底色，不写默认为白色
/**
 *  @brief /后台是否继续播放，注意：如果开启后台播放需要打开 xcode->Capabilities->Background Modes->on->Audio,AirPlay,and Picture in Picture
 */
@property(nonatomic,assign)BOOL                         pauseInBackGround;//后台是否继续播放，注意：如果开启后台播放需要打开 xcode->Capabilities->Background Modes->on->Audio,AirPlay,and Picture in Picture
/**
 *  @brief PPT适配模式分为四种
 *    PPT适配模式分为四种，
 *    1.拉伸填充，PPT内容全部展示在显示区域，会被拉伸或压缩，不会存在黑边
 *    2.等比居中，PPT内容保持原始比例,适应窗口展示在显示区域,会存在黑边
 *    3.等比填充，PPT内容保持原始比例,以横向或纵向适应显示区域,另一方向将会超出显示区域,超出部分会被裁减,不会存在黑边
 *    4.根据直播间文档显示模式的返回值进行设置（推荐）
 */
@property(assign, nonatomic)NSInteger                   PPTScalingMode;//PPT适配方式，含义见上面
/**
 *  @brief PPT是否允许滚动(The New Method)
 */
@property(nonatomic, assign)BOOL                        pptInteractionEnabled;
/**
 *  @brief 设置当前的文档模式，
 * 1.切换至跟随模式（默认值）值为0，
 * 2.切换至自由模式；值为1，
 */
@property(assign, nonatomic)NSInteger                   DocModeType;//设置当前的文档模式
/**
 *  @brief 聊天分组id
 *         使用聊天分组功能时传入,不使用可以不传
 */
@property(copy, nonatomic)NSString                   *groupid;
/**
 *  @brief 是否禁用视频,默认为NO,禁用视频则只播放音频 (在线回放专用)
 *         只有账号开启支持音频模式设置才生效,可以在初始化SDK的时候配置,也可以在切换线路调用(changeLineWithPlayParameter)的时候配置
 */
@property(assign, nonatomic)BOOL                        disableVideo;
/**
 *  @brief 切换线路
 *         在切换线路调用(changeLineWithPlayParameter)的时候配置
*/
@property(assign, nonatomic)NSInteger                   lineNum;//线路

/**
 *  视频播放状态
 *  HDMoviePlaybackStateStopped          播放停止
 *  HDMoviePlaybackStatePlaying          开始播放
 *  HDMoviePlaybackStatePaused           暂停播放
 *  HDMoviePlaybackStateInterrupted      播放间断
 *  HDMoviePlaybackStateSeekingForward   播放快进
 *  HDMoviePlaybackStateSeekingBackward  播放后退
 */
typedef NS_ENUM(NSUInteger, HDMoviePlaybackState) {
    HDMoviePlaybackStateStopped,
    HDMoviePlaybackStatePlaying,
    HDMoviePlaybackStatePaused,
    HDMoviePlaybackStateInterrupted,
    HDMoviePlaybackStateSeekingForward,
    HDMoviePlaybackStateSeekingBackward,
};

/**
 *  视频加载状态
 *  HDMovieLoadStateUnknown         未知状态
 *  HDMovieLoadStatePlayable        视频未完成全部缓存，但已缓存的数据可以进行播放
 *  HDMovieLoadStatePlaythroughOK   完成缓存
 *  HDMovieLoadStateStalled         数据缓存已经停止，播放将暂停
 */
typedef NS_ENUM(NSUInteger, HDMovieLoadState) {
    HDMovieLoadStateUnknown,
    HDMovieLoadStatePlayable,
    HDMovieLoadStatePlaythroughOK,
    HDMovieLoadStateStalled,
};

/**
 *  视频播放完成原因
 *  HDMovieFinishReasonPlaybackEnded    自然播放结束
 *  HDMovieFinishReasonUserExited       用户人为结束
 *  HDMovieFinishReasonPlaybackError    发生错误崩溃结束
 */
typedef NS_ENUM(NSUInteger, HDMovieFinishReason) {
    HDMovieFinishReasonPlaybackEnded,
    HDMovieFinishReasonUserExited,
    HDMovieFinishReasonPlaybackError,
};



@end


@interface RemindModel :NSObject

/**
 *  用户进出通知
 *  HDUSER_IN_REMIND      进入直播间
 *  HDUSER_OUT_REMIND     退出直播间
 */
typedef NS_ENUM(NSUInteger, HDUSER_REMIND) {
    HDUSER_IN_REMIND,//进入直播间
    HDUSER_OUT_REMIND,//退出直播间
};

/** 用户id */
@property (nonatomic, copy) NSString    *userId;
/** 昵称 */
@property (nonatomic, copy) NSString    *userName;
/** 角色 */
@property (nonatomic, copy) NSString    *userRole;
/** 头像 */
@property (nonatomic, copy) NSString    *userAvatar;
/** 分组id */
@property (nonatomic, copy) NSString    *groupId;
/** 接收端   1-讲师；2-助教；3-主持人；4-观看端 */
@property (nonatomic, strong) NSArray   *clientType;
/** 用户进出通知 */
@property (nonatomic, assign) HDUSER_REMIND remindType;
/** 发送内容前缀 */
@property (nonatomic, copy) NSString    *prefixContent;
/** 发送内容后缀 */
@property (nonatomic, copy) NSString    *suffixContent;



@end


@interface BanChatModel : NSObject

/** 用户id */
@property (nonatomic, copy) NSString    *userId;
/** 昵称 */
@property (nonatomic, copy) NSString    *userName;
/** 角色 */
@property (nonatomic, copy) NSString    *userRole;
/** 头像 */
@property (nonatomic, copy) NSString    *userAvatar;
/** 分组id */
@property (nonatomic, copy) NSString    *groupId;


@end
