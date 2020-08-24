//
//  HDSReportClient.h
//  CCFuncTool
//
//  Created by Chenfy on 2020/2/7.
//  Copyright © 2020 com.class.chenfy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark -- 云课堂使用
@interface HDSReportInfo : NSObject
@property(nonatomic,assign)NSTimeInterval responseTime;
//基本数据
@property(nonatomic,copy)NSString       *var_business;
@property(nonatomic,copy)NSString       *var_appVer;

@property(nonatomic,copy)NSString       *var_cdn;
@property(nonatomic,copy)NSString       *var_appid;
@property(nonatomic,copy)NSDictionary   *var_device;
@property(nonatomic,assign)int          var_serviceplatform;

@property(nonatomic,copy)NSString       *var_roomid;
@property(nonatomic,copy)NSString       *var_role;
@property(nonatomic,copy)NSString       *var_userid;
@property(nonatomic,copy)NSString       *var_username;
//事件数据
@property(nonatomic,copy)NSString       *event_event;
@property(nonatomic,assign)int          event_code;
@property(nonatomic,copy)NSString       *event_msg;
//data
@property(nonatomic,copy)NSDictionary   *event_data_requestmsg;
@property(nonatomic,copy)NSDictionary   *event_data_responsemsg;
@property(nonatomic,copy)NSDictionary   *event_data_stream;

@end

@interface HDSReportClient : NSObject
#pragma mark -- 新版API
/**
 * @param business 业务类型
 * @param sdkVer sdk版本号
 */
- (void)envInit:(NSString *)business version:(NSString *)sdkVer;

/**
 * 设置基础参数
 * @param baseInfo 基础信息
 */
- (void)setBaseInfo:(NSDictionary *)baseInfo;

/**
 * 日志上报
 * @param extraInfo 业务信息
 */
- (void)logReport:(NSDictionary *)extraInfo;


#pragma mark -- 旧版API
/** 云课堂旧版本使用 */
- (void)reportLogInfo:(HDSReportInfo *)info;

@end

NS_ASSUME_NONNULL_END
