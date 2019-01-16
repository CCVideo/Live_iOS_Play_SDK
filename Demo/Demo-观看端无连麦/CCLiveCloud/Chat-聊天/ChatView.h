//
//  ChatView.h
//  NewCCDemo
//
//  Created by cc on 2016/12/29.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCPrivateChatView.h"
typedef void(^PublicChatBlock)(NSString *msg);

typedef void(^PrivateChatBlock)(NSString *anteid,NSString *msg);

@interface ChatView : UIView

@property(nonatomic,strong)CCPrivateChatView            *ccPrivateChatView;

//点击私聊按钮
-(void)privateChatBtnClicked;

-(instancetype)initWithPublicChatBlock:(PublicChatBlock)publicChatBlock PrivateChatBlock:(PrivateChatBlock)privateChatBlock input:(BOOL)input;

-(void)reloadPrivateChatDict:(NSMutableDictionary *)dict anteName:anteName anteid:anteid;

-(void)reloadPublicChatArray:(NSMutableArray *)array;

- (void)addPublicChatArray:(NSMutableArray *)array;

/**
 聊天审核,刷新聊天记录

 @param arr 需要被刷新的某一行数组
 @param publicArr 更新过的数组
 */
-(void)reloadStatusWithIndexPaths:(NSMutableArray *)arr
                        publicArr:(NSMutableArray *)publicArr;

@end

