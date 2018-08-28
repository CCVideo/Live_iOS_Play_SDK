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
 *  @brief 是否使用https，静态库暂时只能使用http协议
 */
@property(nonatomic,assign)BOOL                         security;//是否使用https，静态库暂时只能使用http协议
/**
 *  @brief
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
 *  @brief PPT适配模式分为三种，
 * 1.一种是全部填充屏幕，可拉伸变形，
 * 2.第二种是等比缩放，横向或竖向贴住边缘，另一方向可以留黑边，
 * 3.第三种是等比缩放，横向或竖向贴住边缘，另一方向出边界，裁剪PPT，不可以留黑边
 */
@property(assign, nonatomic)NSInteger                   PPTScalingMode;//PPT适配方式，含义见上面

@end





