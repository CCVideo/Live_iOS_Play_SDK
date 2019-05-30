//
//  RollcallView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/22.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "RollcallView.h"
#import "UIImage+GIF.h"

@interface RollcallView()

@property(nonatomic,copy)  LotteryBtnClicked        lotteryblock;//签到回调
@property(nonatomic,strong)UIImageView              *topBgView;//顶部背景
@property(nonatomic,strong)UIView                   *view;//背景视图
@property(nonatomic,strong)UILabel                  *label;//提示文字
@property(nonatomic,strong)UILabel                  *titleLabel;//titleLabel
@property(nonatomic,assign)NSInteger                duration;//签到时间
@property(nonatomic,strong)UIButton                 *lotteryBtn;//签到按钮
@property(nonatomic,strong)NSTimer                  *timer;//签到倒计时
@property(nonatomic,assign)BOOL                     isScreenLandScape;//是否是全屏

@end

//签到
@implementation RollcallView

//初始化方法
-(instancetype) initWithDuration:(NSInteger)duration
                    lotteryblock:(LotteryBtnClicked)lotteryblock
               isScreenLandScape:(BOOL)isScreenLandScape{
    self = [super init];
    if(self) {
        _duration = duration + 2;
        self.isScreenLandScape = isScreenLandScape;
        self.lotteryblock = lotteryblock;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerfunc) userInfo:nil repeats:YES];//签到倒计时
        [self initUI];
    }
    return self;
}

/**
 签到倒计时
 */
-(void)timerfunc {
    WS(ws)
    _duration = _duration - 1;
//    NSLog(@"_duration = %d",(int)_duration);
    if(_duration == 0) {//签到时间为零时,设置视图样式
        self.lotteryBtn.enabled = YES;//设置签到按钮不可点击
        self.lotteryBtn.hidden = YES;//隐藏签到按钮
        [self stopTimer];//关闭timer
        
        //设置label样式和约束
        self.label.text = ROLLCALL_OVER;
        self.label.textColor = [UIColor colorWithHexString:@"#ff412e" alpha:1.f];
        [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(190));
            make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(180));
        }];
        [ws layoutIfNeeded];
        
        //1.5秒后移除视图
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    } else {
        self.label.text = [NSString stringWithFormat:@"%@%@", ROLLCALL_TIMER,[self timeFormat:self.duration]];
    }
}
//关闭Timer
-(void)stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
}

/**
 秒数转固定格式的时间字符串

 @param time 秒数
 @return 时间字符串
 */
-(NSString *)timeFormat:(NSInteger)time {
    NSInteger minutes = time / 60;
    NSInteger seconds = time % 60;
    NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d",(int)minutes,(int)seconds];
    return timeStr;
}
#pragma mark - setUI

/**
 初始化UI
 */
-(void)initUI {
    self.backgroundColor = CCRGBAColor(0,0,0,0.5);
    
    //背景视图
    _view = [[UIView alloc] init];
    _view.backgroundColor = [UIColor whiteColor];
    _view.layer.cornerRadius = CCGetRealFromPt(10);
    [self addSubview:_view];
    if(!self.isScreenLandScape) {//竖屏模式下
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(650), CCGetRealFromPt(565)));
        }];
    } else {//横屏模式下
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(650), CCGetRealFromPt(565)));
        }];
    }
    
    //顶部背景视图
    [self.view addSubview:self.topBgView];
    [_topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.height.mas_equalTo(CCGetRealFromPt(80));
    }];
    
    //顶部标题
    [self.view addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.topBgView);
    }];
    
    //提示文字
    [self.view addSubview:self.label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(CCGetRealFromPt(215));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(650), CCGetRealFromPt(40)));
    }];
    
    //签到按钮
    [self.view addSubview:self.lotteryBtn];
    [_lotteryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-CCGetRealFromPt(140));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(360), CCGetRealFromPt(90)));
    }];
}
#pragma mark - 懒加载
//签到提示
-(UILabel *)label {
    if(!_label) {
        _label = [[UILabel alloc] init];
        _label.text = [NSString stringWithFormat:@"%@%@", ROLLCALL_TIMER,[self timeFormat:self.duration]];
        _label.textColor = [UIColor colorWithHexString:@"#1e1f21" alpha:1.f];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:FontSize_40];
    }
    return _label;
}
//签到按钮
-(UIButton *)lotteryBtn {
    if(_lotteryBtn == nil) {
        _lotteryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lotteryBtn setTitle:ROLLCALL_SIGN forState:UIControlStateNormal];
        [_lotteryBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_lotteryBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_lotteryBtn setBackgroundImage:[UIImage imageNamed:@"default_btn"] forState:UIControlStateNormal];
        [_lotteryBtn.layer setMasksToBounds:YES];
        [_lotteryBtn.layer setCornerRadius:12];
        [_lotteryBtn addTarget:self action:@selector(lotteryBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lotteryBtn;
}
//点击签到
-(void)lotteryBtnClicked {
    self.lotteryBtn.hidden = YES;
    [self stopTimer];
    self.label.text = ROLLCALL_SUCCESS;
    self.label.textColor = [UIColor colorWithHexString:@"#ff412e" alpha:1.f];
    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(CCGetRealFromPt(190));
        make.bottom.mas_equalTo(self.view).offset(-CCGetRealFromPt(180));
    }];
    [self layoutIfNeeded];
    
    if(self.lotteryblock) {
        self.lotteryblock();//签到回调
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

//顶部背景视图
-(UIImageView *)topBgView {
    if(!_topBgView) {
        _topBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bar"]];
        _topBgView.backgroundColor = CCClearColor;
        _topBgView.userInteractionEnabled = YES;
        // 阴影颜色
        _topBgView.layer.shadowColor = [UIColor grayColor].CGColor;
        // 阴影偏移，默认(0, -3)
        _topBgView.layer.shadowOffset = CGSizeMake(0, 3);
        // 阴影透明度，默认0.7
        _topBgView.layer.shadowOpacity = 0.2f;
        // 阴影半径，默认3
        _topBgView.layer.shadowRadius = 3;
        _topBgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _topBgView;
}
//顶部提示文字
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = ROLLCALL;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_32];
    }
    return _titleLabel;
}
@end
