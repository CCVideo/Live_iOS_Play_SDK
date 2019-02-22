//
//  CCPublicChatModel.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/21.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, CCPublicMsgState) {
    RadioState,//广播消息
    TextState,//纯文本消息
    ImageState,//图片消息
};
@interface CCPublicChatModel : NSObject
@property (copy, nonatomic) NSString                        * userid;//用户id
@property (copy, nonatomic) NSString                        * fromuserid;//来自userid
@property (copy, nonatomic) NSString                        * username;//用户名
@property (copy, nonatomic) NSString                        * fromusername;//消息来源用户名
@property (copy, nonatomic) NSString                        * userrole;//用户角色
@property (copy, nonatomic) NSString                        * fromuserrole;//消息方用户角色
@property (copy, nonatomic) NSString                        * msg;//具体消息
@property (copy, nonatomic) NSString                        * useravatar;//用户头像
@property (copy, nonatomic) NSString                        * time;//时间
@property (copy, nonatomic) NSString                        * myViwerId;//自己的id
@property (copy, nonatomic) NSString                        * chatId;//聊天id
@property (copy, nonatomic) NSString                        * status;//聊天状态
@property (copy, nonatomic) NSString                        * headImgName;//头像图片名称
@property (copy, nonatomic) NSString                        * headTag;//头像标签名称
@property (copy, nonatomic) NSString                        * textColorHexing;//文本颜色
@property (nonatomic, assign) CGFloat                       cellHeight;//行高
@property (nonatomic, assign) CCPublicMsgState              typeState;//消息状态
@property (nonatomic, assign) CGSize                        textSize;//字体尺寸
@property (nonatomic, assign) CGSize                        imageSize;//图片大小
@end

NS_ASSUME_NONNULL_END
