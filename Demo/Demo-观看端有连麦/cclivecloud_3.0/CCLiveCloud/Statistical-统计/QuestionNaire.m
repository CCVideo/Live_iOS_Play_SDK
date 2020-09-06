//
//  QuestionNaire.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "QuestionNaire.h"

@interface QuestionNaire()

@property(nonatomic,strong)UIImageView              *topBgView;//头部背景视图
@property(nonatomic,strong)UILabel                  *titleLabel;//头部文字
@property(nonatomic,strong)UIButton                 *closeBtn;//关闭按钮
@property(nonatomic,strong)UILabel                  *centerLabel;//问卷说明

@property(nonatomic,copy) NSString                  *url;//第三方问卷地址
@property(nonatomic,copy) NSString                  *title;//标题
@property(nonatomic,strong)UIView                   *view;//背景视图
@property(nonatomic,strong)UIButton                 *submitBtn;//提交按钮
@property(nonatomic,assign)BOOL                     isScreenLandScape;//是否是全屏

@end

@implementation QuestionNaire
/**
 初始化方法
 
 @param title 问卷标题
 @param url 第三方问卷链接
 @param isScreenLandScape 是否是全屏
 @return self
 */
-(instancetype) initWithTitle:(NSString *)title url:(NSString *)url isScreenLandScape:(BOOL)isScreenLandScape{
    self = [super init];
    if(self) {
        self.isScreenLandScape  = isScreenLandScape;
        self.url                = url;//第三方问卷链接
        self.title              = title;//问卷标题
        [self initUI];
    }
    return self;
}
#pragma mark - 初始化UI布局
-(void)initUI {
    WS(ws)
    self.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
    //初始化视图
    _view = [[UIView alloc]init];
    _view.backgroundColor = [UIColor whiteColor];
    _view.layer.cornerRadius = CCGetRealFromPt(12);
    [self addSubview:_view];
    if(!self.isScreenLandScape) {//不是全屏约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(650), CCGetRealFromPt(565)));
            make.centerY.mas_equalTo(ws).offset(CCGetRealFromPt(100));
        }];
    } else {//全屏约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(650), CCGetRealFromPt(565)));
            make.top.mas_equalTo(ws).offset(CCGetRealFromPt(100));
        }];
    }
    
    //添加头部视图
    [self.view addSubview:self.topBgView];
    [_topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view);
        make.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(80));
    }];
    
    //添加关闭按钮
    [self.topBgView addSubview:self.closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.topBgView).offset(-CCGetRealFromPt(20));
        make.centerY.mas_equalTo(ws.topBgView);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(56),CCGetRealFromPt(56)));
    }];
    
    //添加标题文字
    [self.topBgView addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.topBgView);
    }];
    
    //添加问卷说明
    [self addCenterLabel];
    
    //添加提交按钮
    [self.view addSubview:self.submitBtn];
    [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(145));
        make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(145));
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(415));
        make.height.mas_equalTo(CCGetRealFromPt(90));
    }];

    [self layoutIfNeeded];
}

/**
 添加问卷说明
 */
-(void)addCenterLabel{
    float textMaxWidth = self.isScreenLandScape? CCGetRealFromPt(640) : CCGetRealFromPt(540);
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:_title];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51,51,51) range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = CCGetRealFromPt(20);
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.width = ceilf(textSize.width);
    textSize.height = ceilf(textSize.height);
    
    //添加问卷说明
    [self.view addSubview:self.centerLabel];
    [_centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(CCGetRealFromPt(50));
        make.right.mas_equalTo(self.view).offset(-CCGetRealFromPt(50));
        make.top.mas_equalTo(self.topBgView.mas_bottom).offset(CCGetRealFromPt(50));
        make.height.mas_equalTo(textSize.height);
    }];
}
#pragma mark - 懒加载
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
-(UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = QUESTIONNAIRE_TITLE;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_32];
    }
    return _titleLabel;
}
//问卷说明
-(UILabel *)centerLabel {
    if(!_centerLabel) {
        NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:_title];
        [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51,51,51) range:NSMakeRange(0, textAttri.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = CCGetRealFromPt(20);
        style.alignment = NSTextAlignmentCenter;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],NSParagraphStyleAttributeName:style};
        [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];

        _centerLabel = [[UILabel alloc] init];
        _centerLabel.attributedText = textAttri;
        _centerLabel.numberOfLines = 0;
        _centerLabel.backgroundColor = CCClearColor;
        _centerLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1.f];
        _centerLabel.userInteractionEnabled = NO;
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.font = [UIFont systemFontOfSize:FontSize_26];
    }
    return _centerLabel;
}

//顶部背景视图
-(UIImageView *)topBgView {
    if(!_topBgView) {
        _topBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bar"]];
        _topBgView.backgroundColor = CCClearColor;
        _topBgView.userInteractionEnabled = YES;
        _topBgView.layer.cornerRadius = CCGetRealFromPt(12);
        _topBgView.layer.masksToBounds = YES;
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

//提交按钮
-(UIButton *)submitBtn {
    if(_submitBtn == nil) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submitBtn setTitle:QUESTIONNAIRE_OPEN forState:UIControlStateNormal];
        [_submitBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_submitBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_submitBtn setBackgroundImage:[UIImage imageNamed:@"default_btn"] forState:UIControlStateNormal];
        [_submitBtn.layer setMasksToBounds:YES];
        [_submitBtn.layer setCornerRadius:12];
        [_submitBtn addTarget:self action:@selector(submitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}
//提交按钮点击事件
-(void)submitBtnClicked {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
}
//关闭按钮回调
-(void)closeBtnClicked {
    [self removeFromSuperview];
}
@end
