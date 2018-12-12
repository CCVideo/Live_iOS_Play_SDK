//
//  ChatView.h
//  NewCCDemo
//
//  Created by cc on 2016/12/29.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PublicChatBlock)(NSString *msg);

typedef void(^PrivateChatBlock)(NSString *anteid,NSString *msg);

@interface ChatView : UIView

-(instancetype)initWithPublicChatBlock:(PublicChatBlock)publicChatBlock PrivateChatBlock:(PrivateChatBlock)privateChatBlock input:(BOOL)input;

-(void)reloadPrivateChatDict:(NSMutableDictionary *)dict anteName:anteName anteid:anteid;

-(void)reloadPublicChatArray:(NSMutableArray *)array;

- (void)addPublicChatArray:(NSMutableArray *)array;

@end

