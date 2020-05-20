//
//  CCLockView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/3/12.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCLockView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <AVFoundation/AVFoundation.h>

@interface CCLockView ()
@property (nonatomic, copy) NSString *roomName;//房间名称
@property (nonatomic, assign) int duration;//播放总时长
@property (nonatomic, assign) int   currentTime;//当前的播放时间(当快进快退时需要用到此参数记录时间)
@property (nonatomic, strong) NSTimer  *timer;//计算长按时的时间
@property (nonatomic, assign) BOOL  change;//是否是长按，用来区别点击下一首/上一首时产生的结束快进/快退事件
@property (nonatomic, assign) int  repeatCount;
@end

@implementation CCLockView

-(instancetype)initWithRoomName:(NSString *)roomName duration:(int)duration{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _roomName = roomName;
        _duration = duration;
        _currentTime = 0;
        _change = NO;
        [self setLockScreenDisplay];//设置锁屏界面视图
        [self playingBackground];//后台支持播放
        [self becomeFirstResponder];
        [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
    }
    return self;
}
#pragma mark 设置锁屏信息显示
- (void)setLockScreenDisplay
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:_roomName forKey:MPMediaItemPropertyTitle];//标题
//    [info setObject:@"作者" forKey:MPMediaItemPropertyArtist];//作者
//    [info setObject:@"专辑作者" forKey:MPMediaItemPropertyAlbumArtist];//专辑作者
    [info setObject:[[MPMediaItemArtwork alloc]initWithImage:[UIImage imageNamed:@"LockIcon"]] forKey:MPMediaItemPropertyArtwork];//显示的图片
    [info setObject:[NSNumber numberWithDouble:_duration] forKey:MPMediaItemPropertyPlaybackDuration];//总时长
    [info setObject:[NSNumber numberWithDouble:0] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];//当前播放时间
    [info setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];//播放速率
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}
#pragma mark 后台播放
- (void)playingBackground
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    NSError *activationError = nil;
    [[AVAudioSession  sharedInstance] setActive:YES error: &activationError];
}



-(void)dealloc{
    [self stopTimer];
    [self resignFirstResponder];
    [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}
#pragma mark - 更新锁屏信息
-(void)updateLockView{
    [self resignFirstResponder];
    [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
    
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:_roomName forKey:MPMediaItemPropertyTitle];//标题
//    [info setObject:@"作者" forKey:MPMediaItemPropertyArtist];//作者
    //    [info setObject:@"专辑作者" forKey:MPMediaItemPropertyAlbumArtist];//专辑作者
    [info setObject:[[MPMediaItemArtwork alloc]initWithImage:[UIImage imageNamed:@"LockIcon"]] forKey:MPMediaItemPropertyArtwork];//显示的图片
    [info setObject:[NSNumber numberWithDouble:_duration] forKey:MPMediaItemPropertyPlaybackDuration];//总时长
//    [info setObject:[NSNumber numberWithDouble:0] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];//当前播放时间
    [info setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];//播放速率
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
    
    
    [self playingBackground];
    [self becomeFirstResponder];
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
}
#pragma mark - 更新当前播放进度
-(void)updateCurrentDurtion:(int)currentDurtion{
    NSMutableDictionary *info = [[[MPNowPlayingInfoCenter defaultCenter]nowPlayingInfo] mutableCopy];
    [info setObject:[NSNumber numberWithDouble:currentDurtion] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
//    NSLog(@"当前播放进度:%lf", currentDurtion);
}
#pragma mark - 更新当前回放速率
-(void)updatePlayBackRate:(float)rate{
    NSMutableDictionary *info = [[[MPNowPlayingInfoCenter defaultCenter]nowPlayingInfo] mutableCopy];
    [info setObject:[NSNumber numberWithFloat:rate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}
#pragma mark - 更新歌词信息
-(void)updateCurrentChat:(NSString *)str{
//    NSLog(@"currentChat:%@", str);
    NSMutableDictionary *info = [[[MPNowPlayingInfoCenter defaultCenter]nowPlayingInfo] mutableCopy];
    [info setObject:str forKey:MPMediaItemPropertyArtist];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}
#pragma mark 播放暂停方法
- (void)resumeAndPauseWhtherPause:(BOOL)pause
{
    
    NSMutableDictionary *info = [[[MPNowPlayingInfoCenter defaultCenter]nowPlayingInfo] mutableCopy];
    if (pause) {
        [info setObject:[NSNumber numberWithFloat:0.00001] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    }else
    {
        [info setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    }
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}
#pragma mark 锁屏控制
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay://播放
//                NSLog(@"开始播放");
                if (self.pauseCallBack) {
                    self.pauseCallBack(NO);
                    [self resumeAndPauseWhtherPause:NO];
                }
                break;
            case UIEventSubtypeRemoteControlPause://暂停
//                NSLog(@"暂停播放");
                if (self.pauseCallBack) {
                    self.pauseCallBack(YES);
                    [self resumeAndPauseWhtherPause:YES];
                }
                break;
            case UIEventSubtypeRemoteControlStop://停止
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause://切换播放暂停（耳机线控）
                break;
            case UIEventSubtypeRemoteControlNextTrack://下一首
                NSLog(@"下一首");
                int time = [[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo][@"MPNowPlayingInfoPropertyElapsedPlaybackTime"] intValue];
                if (self.progressBlock) {
                    self.progressBlock(time + 15);
//                    NSLog(@"更新后的时间%d", time + 15);
                    [self updateCurrentDurtion:time + 15];
                }
                break;
            case UIEventSubtypeRemoteControlPreviousTrack://上一首
                NSLog(@"上一首");
                int currentTime = [[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo][@"MPNowPlayingInfoPropertyElapsedPlaybackTime"] intValue];
                if (self.progressBlock) {
                    self.progressBlock(currentTime - 15);
//                    NSLog(@"更新后的时间%d", currentTime - 15);
                    [self updateCurrentDurtion:currentTime - 15];
                }
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward://开始快退
//                NSLog(@"开始快退");
                _change = YES;
                _currentTime = [[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo][@"MPNowPlayingInfoPropertyElapsedPlaybackTime"] intValue];
                [self stopTimer];
                [self startChange:NO];
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward://结束快退
//                NSLog(@"结束快退");
                if (_change) {
                    [self stopTimer];
                    if (self.progressBlock) {
                        self.progressBlock(self.currentTime);
//                        NSLog(@"更新后的时间%d", self.currentTime);
                        [self updateCurrentDurtion:self.currentTime];
                    }
                    _change = NO;
                }
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward://开始快进
//                NSLog(@"开始快进");
                _change = YES;
                _currentTime = [[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo][@"MPNowPlayingInfoPropertyElapsedPlaybackTime"] intValue];
                [self stopTimer];
                [self startChange:YES];
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward://结束快进
//                NSLog(@"结束快进");
                if (_change) {
                    [self stopTimer];
                    if (self.progressBlock) {
                        self.progressBlock(self.currentTime);
//                        NSLog(@"更新后的时间%d", self.currentTime);
                        [self updateCurrentDurtion:self.currentTime];
                    }
                    _change = NO;
                }
                break;
            default:
                break;
        }
        
    }
}

/**
 开始计算将要进行的进度(每秒钟加8s进度）

 @param change <#change description#>
 */
-(void)startChange:(BOOL)change{
    WS(weakSelf)
    __block typeof(int)repeatCount = 0;
    if (@available(iOS 10.0, *)) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            repeatCount ++;
            if (change) {
                weakSelf.currentTime += 8 * repeatCount;
            }else{
                weakSelf.currentTime -= 8 * repeatCount;
            }
        }];
    } else {
        NSString * str = [NSString stringWithFormat:@"%d",change];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeCurrentTime:) userInfo:str repeats:YES];

    }
    
}
- (void)changeCurrentTime:(NSTimer *)timer {
    BOOL change = (BOOL)[timer userInfo];
    if (change) {
        self.currentTime += 8 * self.repeatCount;
    }else{
        self.currentTime -= 8 * self.repeatCount;
    }
}
-(void)stopTimer{
    [_timer invalidate];
    _timer = nil;
}
@end
