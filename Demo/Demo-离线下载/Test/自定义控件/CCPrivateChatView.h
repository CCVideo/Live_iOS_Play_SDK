//
//  CCPrivateChatView.h
//  NewCCDemo
//
//  Created by cc on 2016/12/7.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateChatViewForOne.h"
#import "Dialogue.h"

typedef void(^CloseBtnClicked)();

typedef void(^IsResponseBlock)(CGFloat y);

typedef void(^IsNotResponseBlock)();

typedef void(^CheckDotBlock)(BOOL flag);

@interface CCPrivateChatView : UIView

@property(nonatomic,strong)PrivateChatViewForOne    *privateChatViewForOne;

-(void)selectByClickHead:(Dialogue *)dialogue;

-(void)createPrivateChatViewForOne:(NSMutableArray *)dataArrayForOne anteid:(NSString *)anteid anteName:(NSString *)anteName;

-(instancetype)initWithCloseBlock:(CloseBtnClicked)closeBlock isResponseBlock:(IsResponseBlock)isResponseBlock isNotResponseBlock:(IsNotResponseBlock)isNotResponseBlock dataPrivateDic:(NSMutableDictionary *)dataPrivateDic isScreenLandScape:(BOOL)isScreenLandScape;

-(void)setCheckDotBlock1:(CheckDotBlock)block;

-(void)reloadDict:(NSDictionary *)dic anteName:anteName anteid:anteid;

@end
