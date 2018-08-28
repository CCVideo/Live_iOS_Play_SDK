//
//  LianmaiView.h
//  NewCCDemo
//
//  Created by cc on 2017/1/5.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol LianMaiDelegate <NSObject>
@optional

-(void)requestLianmaiBtnClicked;

-(void)cancelLianmainBtnClicked;

-(void)hungupLianmainiBtnClicked;

@end;

@interface LianmaiView : UIView

@property(nonatomic,strong)UIButton                 *requestLianmaiBtn;
@property(nonatomic,strong)UIButton                 *cancelLianmainBtn;
@property(nonatomic,strong)UIButton                 *hungupLianmainBtn;
@property(weak,nonatomic)  id<LianMaiDelegate>      delegate;
@property(nonatomic,assign)BOOL                     needToRemoveLianMaiView;

-(void) initUIWithVideoPermission:(AVAuthorizationStatus)videoPermission AudioPermission:(AVAuthorizationStatus)audioPermission;

-(void) connectWebRTCSuccess;

-(void) hasNoNetWork;

-(void) connectingToRTC;

-(BOOL)isConnecting;

-(void)initialState;

@end
