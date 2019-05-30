//
//  TopView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/26.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "TopView.h"

@interface TopView ()
@property (nonatomic, strong) UILabel *titleLabel;//顶部标题
@property (nonatomic, strong) UIButton *closeBtn;//关闭按钮
@property (nonatomic, copy) CloseBlock closeCallBack;//关闭回调
@end

@implementation TopView

-(instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title closeBlock:(CloseBlock)closeBlock{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
        _titleLabel.text = title;
        _closeCallBack = closeBlock;
    }
    return self;
}
#pragma mark - 设置UI
-(void)setUpUI{
    //设置背景
    self.backgroundColor = [UIColor whiteColor];
    // 阴影颜色
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    // 阴影偏移，默认(0, -3)
    self.layer.shadowOffset = CGSizeMake(0, 3);
    // 阴影透明度，默认0.7
    self.layer.shadowOpacity = 0.2f;
    // 阴影半径，默认3
    self.layer.shadowRadius = 3;
    //添加titleLabel
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = CCRGBColor(51,51,51);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    [self addSubview:_titleLabel];
    _titleLabel.frame = CGRectMake((self.frame.size.width - 50) / 2, (self.frame.size.height - 16) / 2, 50, 16);
    
    
    
    //添加closeBtn
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.backgroundColor = CCClearColor;
    _closeBtn.contentMode = UIViewContentModeScaleAspectFit;
    [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setBackgroundImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
    [self addSubview:_closeBtn];
    _closeBtn.frame = CGRectMake(self.frame.size.width - 38, 6, 28, 28);
}
#pragma mark - 关闭按钮
-(void)closeBtnClicked{
    if (_closeCallBack) {
        _closeCallBack();
    }
}
-(void)hiddenCloseBtn:(BOOL)hidden{
    _closeBtn.hidden = hidden;
}
@end
