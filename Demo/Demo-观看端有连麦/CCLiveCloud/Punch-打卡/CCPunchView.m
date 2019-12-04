//
//  CCPunchView.m
//  CCLiveCloud
//
//  Created by Clark on 2019/11/1.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCPunchView.h"
#import "CCAnimationView.h"
@interface CCPunchView ()
@property(nonatomic,strong)UIView                   *bakGroundView;//背景视图
@property(nonatomic,assign)BOOL                     isScreenLandScape;//是否是全屏
@property(nonatomic,strong)NSDictionary             *punchDict;//背景视图
@property (nonatomic, strong) CCAnimationView *     AnimationView;//动画
@property(nonatomic,strong)UILabel                  *timeLabel;//倒计时
@property(nonatomic,strong)UILabel                  *punchLabel;//签到
@property(nonatomic,strong)UILabel                  *contentLabel;//各位同学开始签到
@property(nonatomic,strong)UIButton                  *punchBtn;//签到按钮
@property(nonatomic,copy)  punchBtnClicked        punchBlock;//打卡回调
@property(nonatomic,strong)NSTimer                  *timer;//打卡倒计时
//@property(nonatomic,assign)NSInteger                duration;//倒计时时间
@property(nonatomic,strong)UIImageView              *imageView;//成功失败

//数据解析
@property(nonatomic,assign)BOOL                     isExists;//是否存在进行中的打卡互动
@property(nonatomic, copy)NSString                  *punchid;//打卡ID
@property(nonatomic, copy)NSString                  *expireTime;//打卡到期时间，格式为yyyy-MM-dd HH:mm:ss。当打卡没有设置时长时，返回结果没有该项。
@property(nonatomic, assign)NSInteger                  remainDuration;//打卡剩余时长，单位：秒。-1表示没有设置打卡时长，剩余无限时长。




@end

@implementation CCPunchView

-(instancetype) initWithDict:(NSDictionary *)dict
     punchBlock:(punchBtnClicked)punchBlock
           isScreenLandScape:(BOOL)isScreenLandScape {
    self = [super init];
       if(self) {
           self.punchDict = dict;
           self.punchid = dict[@"punchId"];
           self.expireTime = dict[@"expireTime"];
           self.remainDuration = [dict[@"remainDuration"] integerValue];
           self.isScreenLandScape = isScreenLandScape;
           self.punchBlock = punchBlock;
           if (self.remainDuration != -1) {
               self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerfunc) userInfo:nil repeats:YES];//打卡倒计时
           }
           [self setupUI];
       }
       return self;
}
/**
 打卡倒计时
 */
-(void)timerfunc {
    if (self.remainDuration == 0) {
        [self stopTimer];
        self.commitSuccess(NO);
        return;
    }
    self.remainDuration -=1;// self.duration--;
    self.timeLabel.text = [NSString stringWithFormat:@"%zds",self.remainDuration];
//    NSLog(@"文本是%@",self.timeLabel.text);
}
//关闭Timer
-(void)stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
}
- (void)updateUIWithDic:(NSDictionary *)dict {
    if(!self.isScreenLandScape) {//竖屏模式下
        [_bakGroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(240, 165));
        }];
    } else {//横屏模式下
        [_bakGroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(240, 165));
        }];
    }
    NSString * str = @"恭喜您，签到成功！";
    self.imageView.image = [UIImage imageNamed:@"pop_top_icon_success"];
    if (dict[@"success"] == false) {
        str = @"抱歉，签到失败！";
        self.imageView.image = [UIImage imageNamed:@"pop_top_icon_fail"];
    }
    NSDictionary * dic = dict[@"data"];
    if (dict[@"success"] == false) {
        if (dic[@"isRepeat"] == false) {
            str = @"抱歉，签到重复！";
        }
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]}];
    self.punchLabel.attributedText = string;
    [self.punchLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.bakGroundView);
        make.left.equalTo(self.bakGroundView).offset(20);
        make.right.equalTo(self.bakGroundView).offset(-20);
        make.top.equalTo(self.bakGroundView).offset(106.5);
//        make.size.mas_equalTo(CGSizeMake(120, 20));
        make.height.mas_equalTo(20);
    }];
    self.contentLabel.hidden = YES;
    self.punchBtn.hidden = YES;
    self.timeLabel.hidden = YES;
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bakGroundView);
        make.centerY.equalTo(self.bakGroundView.mas_top).offset(20);
        make.size.mas_equalTo(CGSizeMake(140, 140));
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.commitSuccess(YES);
    });
}
- (void)setupUI {
    self.backgroundColor = CCRGBAColor(0,0,0,0.5);
       
       //背景视图
       _bakGroundView = [[UIView alloc] init];
       _bakGroundView.backgroundColor = [UIColor whiteColor];
       _bakGroundView.layer.cornerRadius = CCGetRealFromPt(10);
       [self addSubview:_bakGroundView];
       if(!self.isScreenLandScape) {//竖屏模式下
           [_bakGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.centerX.mas_equalTo(self);
               make.centerY.mas_equalTo(self);
               make.size.mas_equalTo(CGSizeMake(240, 257));
           }];
       } else {//横屏模式下
           [_bakGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.centerX.mas_equalTo(self);
               make.centerY.mas_equalTo(self);
               make.size.mas_equalTo(CGSizeMake(240, 257));
           }];
       }

//    self.AnimationView = [[CCAnimationView alloc] initWithTintColor:[UIColor redColor] minRadius:30 waveCount:4 timeInterval:1 duration:4];
//    self.AnimationView.frame = CGRectMake(50,-50, 140,140);
//    [[self bakGroundView] addSubview:[self AnimationView]];
//    [[self AnimationView] startAnimating];
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"pop_top_icon"];
    [self.bakGroundView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bakGroundView);
        make.centerY.equalTo(self.bakGroundView.mas_top).offset(20);
        make.size.mas_equalTo(CGSizeMake(140, 140));
    }];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.numberOfLines = 0;
    self.timeLabel.text = @"准备";
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont systemFontOfSize:25];
    [self.bakGroundView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.imageView);
    }];
    self.punchLabel = [[UILabel alloc] init];
//    self.punchLabel.text = @"签到";
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"签到" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]}];

    self.punchLabel.attributedText = string;
    self.punchLabel.numberOfLines = 0;
    self.punchLabel.textAlignment = NSTextAlignmentCenter;
    [self.bakGroundView addSubview:self.punchLabel];
    [self.punchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bakGroundView);
//        make.left.equalTo(self.bakGroundView).offset(20);
        make.top.equalTo(self.bakGroundView).offset(106.5);
        make.size.mas_equalTo(CGSizeMake(80, 20));
    }];
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.numberOfLines = 0;
    [self.bakGroundView addSubview:self.contentLabel];

    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:@"各位同学开始签到" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]}];

    self.contentLabel.attributedText = string1;
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerX.equalTo(self.punchLabel);
          make.top.equalTo(self.punchLabel.mas_bottom).offset(17.5);
          make.size.mas_equalTo(CGSizeMake(120, 14.5));
    }];

    self.punchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.punchBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:69/255.0 blue:75/255.0 alpha:1.0]];
    [self.punchBtn setTitle:@"签到" forState:UIControlStateNormal];
    [self.punchBtn setTintColor:[UIColor whiteColor]];
    [self.bakGroundView addSubview:self.punchBtn];
    [self.punchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bakGroundView).offset(20);
        make.right.equalTo(self.bakGroundView.mas_right).offset(-20);
        make.bottom.mas_equalTo(self.bakGroundView.mas_bottom).offset(-28);
        make.height.mas_equalTo(44);
    }];
    self.punchBtn.layer.cornerRadius = 22.0f;
    [self.punchBtn addTarget:self action:@selector(punchBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self updateUI];
//    });
}
- (void)punchBtnClick{
    NSLog(@"点击签到");
    self.punchBtn.userInteractionEnabled = NO;
    if(self.punchBlock) {
        self.punchBlock(self.punchid);//打卡回调
    }
}

@end
