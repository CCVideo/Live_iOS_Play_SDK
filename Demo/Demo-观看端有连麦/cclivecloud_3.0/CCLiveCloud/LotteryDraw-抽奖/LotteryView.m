//
//  LotteryView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/22.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "LotteryView.h"
#import "UIImage+animatedGIF.h"

//抽奖
@interface LotteryView()

@property(nonatomic,strong)UIImageView              *giftView;//加载动画视图
@property(nonatomic,strong)UIImageView              *topBgView;//头部视图
@property(nonatomic,strong)UILabel                  *titleLabel;//头部的文字
@property(nonatomic,strong)UIButton                 *closeBtn;//关闭按钮
@property(nonatomic,strong)UIView                   *view;//总视图
@property(nonatomic,assign)BOOL                     isScreenLandScape;//是否是全屏
@property(nonatomic,assign)BOOL                     clearColor;
@property(nonatomic,assign)BOOL                     myself;//自己中奖
@property(nonatomic,assign)NSInteger                remainNum;//剩余奖品数
@end

@implementation LotteryView
#pragma mark - 初始化方法
/**
 初始化方法
 
 @param isScreenLandScape 是否是全屏
 @param clearColor clearColor
 @return self
 */
-(instancetype)initIsScreenLandScape:(BOOL)isScreenLandScape clearColor:(BOOL)clearColor{
    self = [super init];
    if(self) {
        self.isScreenLandScape = isScreenLandScape;
        self.clearColor = clearColor;
        self.myself = NO;
        [self initUI];
    }
    return self;
}
/**
 *  @brief  抽奖结果
 *  remainNum   剩余奖品数
 */
- (void)lottery_resultWithCode:(NSString *)code myself:(BOOL)myself winnerName:(NSString *)winnerName remainNum:(NSInteger)remainNum IsScreenLandScape:(BOOL)isScreenLandScape{
    self.frame = [UIScreen mainScreen].bounds;
    self.hidden = NO;
    self.remainNum = remainNum;
    if (myself) {
        _myself = myself;
    }
    _isScreenLandScape = isScreenLandScape;
    //更新_view的约束
    //判断是否是全屏，加载不同的样式
    if(!self.isScreenLandScape) {//竖屏约束
        [_view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(CCGetRealFromPt(50));
            make.right.mas_equalTo(self).offset(-CCGetRealFromPt(50));
            make.top.mas_equalTo(self).offset(CCGetRealFromPt(567));
            make.bottom.mas_equalTo(self).offset(IS_IPHONE_X ? - 120 - CCGetRealFromPt(202) :-CCGetRealFromPt(202));
        }];
    } else {//横屏约束
        [_view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(650), CCGetRealFromPt(565)));
            make.top.mas_equalTo(self).offset(CCGetRealFromPt(100));
        }];
    }
    if(myself) {
        [self myselfWin:[NSString stringWithFormat:@"%@", code]];
    } else {
        [self otherWin:winnerName];
    }
}
#pragma mark - 公有方法

/**
 自己中奖

 @param code 中奖码
 */
-(void)myselfWin:(NSString *)code {
    
    [self setLotteryResultUIWithWinner:YES result:code];
}

/**
 其他人中奖

 @param winnerName 获奖人名称
 */
-(void)otherWin:(NSString *)winnerName {
    if (!_myself) {//如果自己没有中过奖,显示其他人中奖
        [self setLotteryResultUIWithWinner:NO result:winnerName];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.remainNum == 0) {
                [self remove];
            }else{
                //初始化页面
                [self initGiftView];
            }
        });
    }else{
        self.hidden = YES;//如果自己已经中过奖，将不会再出现这一波其他人中间的视图
    }
}

/**
 设置抽奖结果UI

 @param myself 是否是自己
 @param result 抽奖结果。   Ps:如果自己中奖，传入中奖码;其他人中奖，传入中奖者昵称
 */
-(void)setLotteryResultUIWithWinner:(BOOL)myself
                   result:(NSString *)result{
    self.type = 2;
    self.titleLabel.text = LOTTERY_RESULT;
    [self.giftView removeFromSuperview];
    _giftView = nil;
    
    WS(ws)
    //设置提示
    UILabel *alertLabel = [[UILabel alloc] init];
    alertLabel.text = LOTTERY_WINNER(myself);
    alertLabel.font = [UIFont systemFontOfSize:FontSize_34];
    alertLabel.textColor = [UIColor colorWithHexString:@"#ff412e" alpha:1.f];
    alertLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:alertLabel];
    [alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(100));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(650), 34));
    }];
    
    //设置图片样式
    NSString *imageName = myself ? @"lottery_win" : @"lottery_losing";
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    image.backgroundColor = CCClearColor;
    image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:image];
    [image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(88));
        make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(87));
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(202));
        make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(128));
    }];
    
    
    //设置结果的label
    UILabel *resultLabel = [[UILabel alloc] init];
    resultLabel.text = result;
    resultLabel.textColor = [UIColor colorWithHexString:myself ? @"#ff412e" : @"#38404b" alpha:1.f];
    resultLabel.textAlignment = NSTextAlignmentCenter;
    resultLabel.font = [UIFont systemFontOfSize:myself?FontSize_72:FontSize_36];
    [image addSubview:resultLabel];
    [resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.mas_equalTo(image);
        make.right.mas_equalTo(image).offset( myself ? -CCGetRealFromPt(100) : 0);
    }];
    
    //底部提示文字
    UILabel *bottomLabel = [[UILabel alloc] init];
    bottomLabel.text = LOTTERY_ALERT(myself);
    bottomLabel.textColor = [UIColor colorWithHexString:@"#79808b" alpha:1.f];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.font = [UIFont systemFontOfSize:FontSize_28];
    [self addSubview:bottomLabel];
    [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(image.mas_bottom);
        make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(6));
    }];
    
    [self layoutIfNeeded];
}
#pragma mark - 初始化视图

/**
 初始化抽奖视图
 */
-(void)initGiftView{
    [_view removeFromSuperview];
    _view = nil;
//    self.hidden = self.hidden;
    [self initUI];
}

/**
 移除抽奖视图
 */
-(void)remove{
    WS(ws)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!_myself || (_myself && self.hidden == YES)) {
            [ws removeFromSuperview];
        }
    });
}
#pragma mark - 懒加载
//提示文本
-(UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"抽奖啦";
        _titleLabel.textColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_32];
    }
    return _titleLabel;
}
//关闭按钮
-(UIButton *)closeBtn {
    if(!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.backgroundColor = CCClearColor;
        _closeBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}
//关闭按钮
-(void)closeBtnClicked {
    self.hidden = YES;
}
//礼物视图
-(UIImageView *)giftView {
    if(!_giftView) {
        _giftView = [[UIImageView alloc] initWithImage:[UIImage sd_animatedGIFNamed:@"gift_loading_gif"]];
        _giftView.backgroundColor = CCClearColor;
        _giftView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _giftView;
}
//头部背景视图
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
#pragma mark - 初始化UI

/**
 初始化UI布局
 */
-(void)initUI {
    self.type = 1;
    if(self.clearColor) {
        self.backgroundColor = CCClearColor;
    } else {
        self.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
    }
    _view = [[UIView alloc]init];
    _view.backgroundColor = [UIColor whiteColor];
    _view.layer.cornerRadius = CCGetRealFromPt(6);
    [self addSubview:_view];
    //判断是否是全屏，加载不同的样式
    if(!self.isScreenLandScape) {//竖屏约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(self).offset(CCGetRealFromPt(50));
                        make.right.mas_equalTo(self).offset(-CCGetRealFromPt(50));
                        make.top.mas_equalTo(self).offset(CCGetRealFromPt(567));
                        make.bottom.mas_equalTo(self).offset(IS_IPHONE_X ? - 120 - CCGetRealFromPt(202) :-CCGetRealFromPt(202));
        }];
    } else {//横屏约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(650), CCGetRealFromPt(565)));
            make.top.mas_equalTo(self).offset(CCGetRealFromPt(100));
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
    //顶部关闭按钮
    [self.view addSubview:self.closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topBgView).offset(-CCGetRealFromPt(20));
        make.centerY.mas_equalTo(self.topBgView);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(56),CCGetRealFromPt(56)));
    }];
    //添加礼物视图
    [self.view addSubview:self.giftView];
    [_giftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
//    [self layoutIfNeeded];
}
@end



