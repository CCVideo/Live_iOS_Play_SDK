//
//  CCChatBaseCell.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/21.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCImageView.h"
#import "CCPublicChatModel.h"//公聊数据模型

NS_ASSUME_NONNULL_BEGIN

typedef void(^HeadBtnClickBlock)(UIButton *btn);//头像点击回调

@interface CCChatBaseCell : UITableViewCell

@property (nonatomic, copy) HeadBtnClickBlock headBtnClick;
#pragma mark - 图片消息
@property (nonatomic, strong) CCImageView *smallImageView;//图片视图

/**
 加载广播cell

 @param model 公聊数据模型
 */
-(void)setRadioModel:(CCPublicChatModel *)model;

/**
 加载文本cell

 @param model 公聊数据模型
 @param input 是否有输入框
 @param indexPath 位置下标
 */
-(void)setTextModel:(CCPublicChatModel *)model
            isInput:(BOOL)input
          indexPath:(NSIndexPath *)indexPath;

/**
 加载图片cell

 @param model 公聊数据模型
 @param input 是否有输入框
 @param indexPath 位置下标
 */
-(void)setImageModel:(CCPublicChatModel *)model
             isInput:(BOOL)input
           indexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
