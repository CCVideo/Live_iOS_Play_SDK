//
//  SelectMenuView.m
//  NewCCDemo
//
//  Created by cc on 2016/11/26.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "SelectMenuView.h"

@interface SelectMenuView()

@property(nonatomic,strong)UIButton             *gotoLive;
@property(nonatomic,strong)UIButton             *watchLive;
@property(nonatomic,strong)UIButton             *watchReplay;
@property(nonatomic, copy)ButtonClicked         block;
@property(nonatomic, copy)PushToIndex           pushBlock;

@end

@implementation SelectMenuView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithBlock:(ButtonClicked)block pushBlock:(PushToIndex)pushBlock {
    self = [super init];
    if(self) {
        self.block = block;
        self.pushBlock = pushBlock;
        [self addBackGround];
        [self addButtons];
    }
    return self;
}

-(void)addBackGround {
    UIImage *image = [UIImage imageNamed:@"nav_bg_cbb"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    WS(ws)
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws);
    }];
}

-(void)addButtons {
//    [self addSubview:self.gotoLive];
    [self addSubview:self.watchLive];
    [self addSubview:self.watchReplay];
    WS(ws)
//    [self.gotoLive mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(ws);
//        make.top.mas_equalTo(ws).offset(CCGetRealFromPt(70));
//        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(114),CCGetRealFromPt(28)));
//    }];
    
    [self.watchLive mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws);
        make.top.mas_equalTo(ws).offset(CCGetRealFromPt(75));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(250),CCGetRealFromPt(28)));
    }];
    
    [self.watchReplay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws);
        make.top.mas_equalTo(ws.watchLive.mas_bottom).offset(CCGetRealFromPt(40));
        make.size.mas_equalTo(ws.watchLive);
    }];
}

-(UIButton *)gotoLive {
    if(_gotoLive == nil) {
        _gotoLive = [UIButton buttonWithType:UIButtonTypeCustom];
        [_gotoLive setBackgroundColor:CCClearColor];
        [_gotoLive.titleLabel setFont:[UIFont systemFontOfSize:FontSize_28]];
        [_gotoLive setTitleColor:CCRGBColor(255, 255, 255) forState:UIControlStateHighlighted];
        [_gotoLive setTitleColor:CCRGBColor(255, 255, 255) forState:UIControlStateSelected];
        [_gotoLive setTitleColor:CCRGBAColor(255, 255, 255,0.69) forState:UIControlStateNormal];
        [_gotoLive setTitle:@"我要直播" forState:UIControlStateNormal];
        [_gotoLive addTarget:self action:@selector(gotoLiveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _gotoLive;
}

-(void)gotoLiveBtnClicked {
    CCLog(@"我要直播按钮被点击");
    if(self.block) {
        self.block();
    }
    NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:CONTROLLER_INDEX] integerValue];
    if(index == 1) {
        return;
    }
    
    if(self.pushBlock) {
        self.pushBlock(1);
    }
}

-(UIButton *)watchLive {
    if(_watchLive == nil) {
        _watchLive = [UIButton buttonWithType:UIButtonTypeCustom];
        [_watchLive setBackgroundColor:CCClearColor];
        [_watchLive.titleLabel setFont:[UIFont systemFontOfSize:FontSize_28]];
        [_watchLive setTitleColor:CCRGBColor(255, 255, 255) forState:UIControlStateHighlighted];
        [_watchLive setTitleColor:CCRGBColor(255, 255, 255) forState:UIControlStateSelected];
        [_watchLive setTitleColor:CCRGBAColor(255, 255, 255,0.69) forState:UIControlStateNormal];
        [_watchLive setTitle:@"观看直播" forState:UIControlStateNormal];
        [_watchLive addTarget:self action:@selector(watchLiveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _watchLive;
}

-(void)watchLiveBtnClicked {
    CCLog(@"观看直播按钮被点击");
    if(self.block) {
        self.block();
    }
    NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:CONTROLLER_INDEX] integerValue];
    if(index == 2) {
        return;
    }
    if(self.pushBlock) {
        self.pushBlock(2);
    }
}

-(UIButton *)watchReplay {
    if(_watchReplay == nil) {
        _watchReplay = [UIButton buttonWithType:UIButtonTypeCustom];
        [_watchReplay setBackgroundColor:CCClearColor];
        [_watchReplay.titleLabel setFont:[UIFont systemFontOfSize:FontSize_28]];
        [_watchReplay setTitleColor:CCRGBColor(255, 255, 255) forState:UIControlStateHighlighted];
        [_watchReplay setTitleColor:CCRGBColor(255, 255, 255) forState:UIControlStateSelected];
        [_watchReplay setTitleColor:CCRGBAColor(255, 255, 255,0.69) forState:UIControlStateNormal];
        [_watchReplay setTitle:@"观看回放" forState:UIControlStateNormal];
        [_watchReplay addTarget:self action:@selector(watchReplayBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _watchReplay;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    return;
}

-(void)watchReplayBtnClicked {
    CCLog(@"观看回放按钮被点击");
    if(self.block) {
        self.block();
    }
    
    NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:CONTROLLER_INDEX] integerValue];
    if(index == 3) {
        return;
    }
    if(self.pushBlock) {
        self.pushBlock(3);
    }
}

-(void)showMenuWithIndex:(NSInteger) index {
    switch(index) {
        case 1:
            [_gotoLive setHighlighted:YES];
            [_watchLive setHighlighted:NO];
            [_watchReplay setHighlighted:NO];
            break;
        case 2:
            [_gotoLive setHighlighted:NO];
            [_watchLive setHighlighted:YES];
            [_watchReplay setHighlighted:NO];
            break;
        case 3:
            [_gotoLive setHighlighted:NO];
            [_watchLive setHighlighted:NO];
            [_watchReplay setHighlighted:YES];
            break;
        default:
            [_gotoLive setHighlighted:NO];
            [_watchLive setHighlighted:NO];
            [_watchReplay setHighlighted:NO];
            break;
    }
}

@end

