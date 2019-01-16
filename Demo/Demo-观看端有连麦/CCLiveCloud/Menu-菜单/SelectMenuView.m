//
//  SelectMenuView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2018/12/24.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "SelectMenuView.h"

@interface SelectMenuView ()
//@property (nonatomic, strong) UIButton         *menuBtn;//菜单按钮
    
@property (nonatomic, strong) UILabel          *announcementLabel;//公告
@property (nonatomic, strong) UILabel          *privateLabel;//私聊
@property (nonatomic, strong) UILabel          *lianmaiLabel;//连麦
    
@property (nonatomic, strong) UIImageView      *lineView;//分割线

@property (nonatomic, strong) UIButton         *privateBgBtn;//新私聊背景
@property (nonatomic, strong) UIButton         *announcementBgBtn;//新公告背景
@property (nonatomic, strong) UILabel          *informationLabel;//提示信息
@end
@implementation SelectMenuView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        [self addObserver];
    }
    return self;
}
#pragma mark - 初始化UI
-(void)initUI{
    self.layer.cornerRadius = CCGetRealFromPt(35);
    self.layer.masksToBounds = YES;
    //菜单按钮
    [self addSubview:self.menuBtn];
    self.menuBtn.frame = CGRectMake(-4, -4, CCGetRealFromPt(86), CCGetRealFromPt(86));
    
    //添加分割线
    [self addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.menuBtn.mas_top);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(50), CCGetRealFromPt(1)));
    }];
    //添加公告按钮
    self.announcementBtn = [self buttonWithNormalImage:@"announcement" andSelectedImage:@"announcement_new"];
    [self addSubview:self.announcementBtn];
    [_announcementBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.menuBtn);
        make.bottom.mas_equalTo(self.menuBtn).offset(-CCGetRealFromPt(127));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(50), CCGetRealFromPt(50)));
    }];
    [_announcementBtn addTarget:self action:@selector(announcementBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _announcementLabel = [self labelWithTitle:@"公告" andBtn:self.announcementBtn];
    
    //添加连麦按钮
    self.lianmaiBtn = [self buttonWithNormalImage:@"lianmai" andSelectedImage:@"lianmai_new"];
    [self addSubview:self.lianmaiBtn];
    [_lianmaiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-CCGetRealFromPt(227));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(50), CCGetRealFromPt(50)));
    }];
    [_lianmaiBtn addTarget:self action:@selector(lianmaiBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _lianmaiLabel = [self labelWithTitle:@"连麦" andBtn:_lianmaiBtn];
    
    //添加私聊按钮
    self.privateChatBtn = [self buttonWithNormalImage:@"private_nor" andSelectedImage:@"private_new"];
    [self addSubview:self.privateChatBtn];
    [_privateChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-CCGetRealFromPt(327));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(50), CCGetRealFromPt(50)));
    }];
    [_privateChatBtn addTarget:self action:@selector(privateChatBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _privateLabel = [self labelWithTitle:@"私聊" andBtn:_privateChatBtn];
}
#pragma mark - 点击事件
//菜单
-(void)menuBtnClicked:(UIButton *)btn{
    [self hiddenAllBtns:btn.selected];
}
//私聊
-(void)privateChatBtnClicked:(UIButton *)btn{
    [self hiddenAllBtns:YES];
    if (_privateBlock) {
        _privateBlock();
    }
}
//连麦
-(void)lianmaiBtnClicked:(UIButton *)btn{
    if (_lianmaiBlock) {
        _lianmaiBlock();
    }
}
//公告
-(void)announcementBtnClicked:(UIButton *)btn{
    [self hiddenAllBtns:YES];
    if (_announcementBlock) {
        _announcementBlock();
    }
}
#pragma mark - 隐藏或显示按钮
-(void)hiddenAllBtns:(BOOL)hidden{
    if (hidden) {//收回菜单
        [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
            self.alpha = 0.1f;
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + CCGetRealFromPt(326), CCGetRealFromPt(70), CCGetRealFromPt(70));
            self.menuBtn.frame = CGRectMake(-4, -4, CCGetRealFromPt(86), CCGetRealFromPt(86));
            [self updateInformationViewFrame];
        } completion:^(BOOL finished) {
            self.backgroundColor = [UIColor clearColor];
            self.alpha = 1.f;
        }];
    }else{//打开菜单
        [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
            self.alpha = 1.f;
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - CCGetRealFromPt(326), CCGetRealFromPt(70), CCGetRealFromPt(410) - 8);
            self.menuBtn.frame = CGRectMake(-4, CCGetRealFromPt(326)-4, CCGetRealFromPt(86), CCGetRealFromPt(86));
            [self updateInformationViewFrame];
        } completion:^(BOOL finished) {
            self.backgroundColor = [UIColor whiteColor];
        }];
    }
    _menuBtn.selected = !hidden;
    _lineView.hidden = hidden;
    _privateChatBtn.hidden = hidden;
    _privateLabel.hidden = hidden;
    _announcementBtn.hidden = hidden;
    _announcementLabel.hidden = hidden;
    _lianmaiBtn.hidden = hidden;
    _lianmaiLabel.hidden = hidden;
}
#pragma mark - 新消息提醒
-(void)showInformationViewWithTitle:(NewMessageState)messageState{
    //判断新消息是否是私聊
    BOOL privateMsg = messageState == NewPrivateMessage ? YES : NO;
    if ((privateMsg == YES && _privateBgBtn) || (privateMsg == NO && _announcementBgBtn)) {
        return;
    }
    NSString *text = ALERT_NEWMESSAGE(privateMsg);
    //如果是私聊,创建私聊视图
    if (privateMsg) {
        _privateBgBtn = [self createButtonWithBgBtnTag:1];
        [APPDelegate.window addSubview:_privateBgBtn];
        _privateBgBtn.frame = CGRectMake(SCREEN_WIDTH - CCGetRealFromPt(210),_announcementBgBtn? self.frame.origin.y - CCGetRealFromPt(133):self.frame.origin.y - CCGetRealFromPt(70), CCGetRealFromPt(243), CCGetRealFromPt(50));
        [self createItemsWithBgBtn:_privateBgBtn title:text];
    }else{//创建公告消息视图
        _announcementBgBtn = [self createButtonWithBgBtnTag:2];
        [APPDelegate.window addSubview:_announcementBgBtn];
        _announcementBgBtn.frame = CGRectMake(SCREEN_WIDTH - CCGetRealFromPt(210),_privateBgBtn? self.frame.origin.y - CCGetRealFromPt(133):self.frame.origin.y - CCGetRealFromPt(70), CCGetRealFromPt(243), CCGetRealFromPt(50));
        [self createItemsWithBgBtn:_announcementBgBtn title:text];
    }
}
-(void)alertMsg:(UIButton *)btn{
    if (btn.tag == 1) {//如果是私聊,进行私聊回调
        if (_privateBlock) {
            _privateBlock();
        }
    }else{//如果是公告，进行公告回调
        if (_announcementBlock) {
            _announcementBlock();
        }
    }
    [self removeInformationView:(UIButton *)btn];
}
//更新消息提示
-(void)updateMessageFrame{
    if (_privateBgBtn) {
        _privateBgBtn.frame = CGRectMake(SCREEN_WIDTH - CCGetRealFromPt(210),_announcementBgBtn? self.frame.origin.y - CCGetRealFromPt(133):self.frame.origin.y - CCGetRealFromPt(70), CCGetRealFromPt(243), CCGetRealFromPt(50));
    }
    if (_announcementBgBtn) {
        _announcementBgBtn.frame = CGRectMake(SCREEN_WIDTH - CCGetRealFromPt(210),self.frame.origin.y - CCGetRealFromPt(70), CCGetRealFromPt(243), CCGetRealFromPt(50));
    }
}
//移除提示信息
-(void)removeInformationView:(UIButton *)btn{
    if (btn.tag == 1) {
        [_privateBgBtn removeFromSuperview];
        _privateBgBtn = nil;
    }else{
        [_announcementBgBtn removeFromSuperview];
        _announcementBgBtn = nil;
    }
}
//更新提示信息位置
-(void)updateInformationViewFrame{
    if (_privateBgBtn) {
        _privateBgBtn.frame = CGRectMake(_privateBgBtn.frame.origin.x, _announcementBgBtn? self.frame.origin.y - CCGetRealFromPt(133):self.frame.origin.y - CCGetRealFromPt(70), _privateBgBtn.frame.size.width, _privateBgBtn.frame.size.height);
    }
    if (_announcementBgBtn) {
        _announcementBgBtn.frame = CGRectMake(_announcementBgBtn.frame.origin.x, self.frame.origin.y - CCGetRealFromPt(70), _announcementBgBtn.frame.size.width, _announcementBgBtn.frame.size.height);
    }
}
//移除提示信息
-(void)removeAllInformationView{
    if (_privateBgBtn) {
        [_privateBgBtn removeFromSuperview];
        _privateBgBtn = nil;
    }
    if (_announcementBgBtn) {
        [_announcementBgBtn removeFromSuperview];
        _announcementBgBtn = nil;
    }
}
#pragma mark - 添加通知
-(void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}
- (void)keyboardWillShow:(NSNotification *)notif {
    if (_menuBtn.selected) {
        [self hiddenAllBtns:YES];
    }
}
-(void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
#pragma mark - 懒加载
//菜单按钮
-(UIButton *)menuBtn{
    if (!_menuBtn) {
        _menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_menuBtn setImage:[UIImage imageNamed:@"menu_nor"] forState:UIControlStateNormal];
        [_menuBtn setImage:[UIImage imageNamed:@"menu_shrink"] forState:UIControlStateSelected];
        [_menuBtn addTarget:self action:@selector(menuBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuBtn;
}
//分割线
-(UIImageView *)lineView{
    if (!_lineView) {
        _lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_separator"]];
        _lineView.hidden = YES;
    }
    return _lineView;
}
#pragma mark - 自定义控件方法

/**
 创建btn

 @param norImage 正常图片样式
 @param selectedImage 选中后的图片样式
 @return 返回btn
 */
-(UIButton *)buttonWithNormalImage:(NSString *)norImage andSelectedImage:(NSString *)selectedImage{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:norImage] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    btn.hidden = YES;
    return btn;
}

/**
 自定义label方法

 @param title 文字title
 @param btn btn
 @return label
 */
-(UILabel *)labelWithTitle:(NSString *)title andBtn:(UIButton *)btn{
    //在btn下面添加文字
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:FontSize_24];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
    [self addSubview:label];
    label.hidden = YES;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(btn.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(71), CCGetRealFromPt(24)));
    }];
    return label;
}
/**
 创建新消息背景视图
 
 @return btn
 */
-(UIButton *)createButtonWithBgBtnTag:(NSInteger)tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.masksToBounds = YES;
    btn.tag = tag;
    btn.layer.cornerRadius = CCGetRealFromPt(25);
    btn.backgroundColor = [UIColor colorWithHexString:@"#1e1f21" alpha:0.6];
    btn.userInteractionEnabled = YES;
    [btn addTarget:self action:@selector(alertMsg:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
//创建新消息样式
-(void)createItemsWithBgBtn:(UIButton *)btn title:(NSString *)text{
    [btn setTitle:text forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor whiteColor];
    [btn.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(btn).offset(CCGetRealFromPt(20));
        make.centerY.mas_equalTo(btn);
        make.right.mas_equalTo(btn).offset(-CCGetRealFromPt(20));
        make.height.mas_equalTo(CCGetRealFromPt(50));
    }];
    btn.titleLabel.textAlignment = NSTextAlignmentLeft;
    btn.titleLabel.font = [UIFont systemFontOfSize:FontSize_26];
    
    //添加btn按钮
    UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeBtn setImage:[UIImage imageNamed:@"private_new_delete"] forState:UIControlStateNormal];
    [removeBtn setBackgroundColor:CCClearColor];
    removeBtn.tag = btn.tag;
    [removeBtn addTarget:self action:@selector(removeInformationView:) forControlEvents:UIControlEventTouchUpInside];
    [btn addSubview:removeBtn];
    [removeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(btn).offset(-CCGetRealFromPt(33));
        make.centerY.mas_equalTo(btn);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(50), CCGetRealFromPt(50)));
    }];
}
@end
