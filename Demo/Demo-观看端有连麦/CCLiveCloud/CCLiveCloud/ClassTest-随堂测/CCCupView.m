//
//  CCCupView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/3/7.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCCupView.h"

@interface CCCupView ()
@property (nonatomic, assign) BOOL            isScreen;//是否是全屏
@property (nonatomic, strong) UIImageView     * cupImageView;//奖杯图片
@property (nonatomic, strong) UILabel         * alertLabel;//提示label
@property (nonatomic, assign) BOOL            myselfWin;//自己胜利
@property (nonatomic, copy) NSString          * alertText;//提示文本信息
@end

#define SELF_WIN @"太棒了，恭喜你获得奖杯"
@implementation CCCupView

-(instancetype)initWithWinnerName:(NSString *)winnerName isScreen:(BOOL)isScreen{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = CCRGBAColor(0, 0, 0, 0.7);
        _isScreen = isScreen;
        [self dealWithWinnerName:winnerName];
        [self setUpUI];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }
    return self;
}
-(void)dealloc{
//    NSLog(@"移除奖杯视图");
}
#pragma mark - 处理winnerName

/**
 处理winnerName

 @param winnerName 获胜者名称
 */
-(void)dealWithWinnerName:(NSString *)winnerName{
    if ([winnerName isEqualToString:@""]) {
        _alertText = SELF_WIN;
        _myselfWin = YES;
    }else{
        _myselfWin = NO;
        //判断获奖者名称长度是否大于8
        NSUInteger len = [winnerName length];
        if (len > 8) {
            winnerName = [winnerName substringToIndex:8];
            _alertText = [NSString stringWithFormat:@"恭喜%@...获得奖杯", winnerName];
        }else{
            _alertText = [NSString stringWithFormat:@"恭喜%@获得奖杯", winnerName];
        }
    }
}
#pragma mark - 设置布局
-(void)setUpUI{
    _cupImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"classTest_cup"]];
    [self addSubview:_cupImageView];
    
    _alertLabel = [UILabel labelWithText:_alertText fontSize:[UIFont systemFontOfSize:14] textColor:CCRGBColor(255, 255, 255) textAlignment:NSTextAlignmentCenter];
    _alertLabel.backgroundColor = CCRGBAColor(0, 0, 0, 0.3);
    _alertLabel.layer.cornerRadius = 15;
    _alertLabel.layer.masksToBounds = YES;
    [self addSubview:_alertLabel];
    
    if (_myselfWin == NO) {//修改特定字符串的颜色
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_alertLabel.text]; // 改变特定范围颜色大小要用的
        NSRange r = NSMakeRange(2, _alertText.length - 6);
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:CCRGBColor(245, 136, 51) range:r];
        [_alertLabel setAttributedText:attributedString];
    }
    CGSize size =[_alertText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    if (!_isScreen) {//竖屏约束
        [_cupImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self).offset(76);
            make.size.mas_equalTo(CGSizeMake(250, 227));
        }];
        
        [_alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.cupImageView.mas_bottom).offset(12);
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(size.width + 26, size.height + 10));
        }];
    }else{//横屏约束
        [_cupImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self).offset(-20);
            make.size.mas_equalTo(CGSizeMake(250, 227));
        }];
        
        [_alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.cupImageView.mas_bottom).offset(17);
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(size.width + 26, size.height + 10));
        }];
    }
}
@end
