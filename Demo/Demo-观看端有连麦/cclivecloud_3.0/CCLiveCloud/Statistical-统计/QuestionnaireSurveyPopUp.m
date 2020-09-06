//
//  LotteryView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "QuestionnaireSurveyPopUp.h"
#import "UIImage+GIF.h"

//问卷弹窗
@interface QuestionnaireSurveyPopUp()

@property(nonatomic,strong)UIButton                 *sureBtn;//确定按钮
@property(nonatomic,strong)UIView                   *view;//背景视图
@property(nonatomic,strong)UILabel                  *label;//提示信息
@property(nonatomic,assign)BOOL                     isScreenLandScape;//是否是全屏
@property(nonatomic,copy)  SureBtnBlock             sureBtnBlock;//确认按钮回调

@end

@implementation QuestionnaireSurveyPopUp
/**
 初始化方法
 
 @param isScreenLandScape 是否是全屏
 @param sureBtnBlock 点击确定回调
 @return self
 */
-(instancetype)initIsScreenLandScape:(BOOL)isScreenLandScape SureBtnBlock:(SureBtnBlock)sureBtnBlock {
    self = [super init];
    if(self) {
        self.isScreenLandScape  = isScreenLandScape;
        self.sureBtnBlock       = sureBtnBlock;
        [self initUI];
    }
    return self;
}
#pragma mark - UI布局

/**
 初始化UI
 */
-(void)initUI {
    WS(ws)
    self.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
    _view = [[UIView alloc]init];
    _view.backgroundColor = [UIColor whiteColor];
    _view.layer.cornerRadius = CCGetRealFromPt(16);
    [self addSubview:_view];
    
    if(!self.isScreenLandScape) {//竖屏约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
            make.centerY.mas_equalTo(ws);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(610), CCGetRealFromPt(310)));
        }];
    } else {//横屏约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
            make.centerY.mas_equalTo(ws);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(610), CCGetRealFromPt(310)));
        }];
    }
    
    //添加提示文字
    [_view addSubview:self.label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view);
        make.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view);
        make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(122));
    }];
    
    //添加确认按钮
    [_view addSubview:self.sureBtn];
    [_sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(165));
//        make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(165));
//        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(200));
        make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(50));
        make.centerX.mas_equalTo(ws.view);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(280), CCGetRealFromPt(80)));
    }];
}
#pragma mark - 懒加载
//提示文字
-(UILabel *)label {
    if(!_label) {
        _label = [[UILabel alloc] init];
        _label.text = QUESTION_CLOSE;
        _label.numberOfLines = 0;
        _label.textColor = [UIColor colorWithHexString:@"#333333" alpha:1.f];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:FontSize_30];
    }
    return _label;
}
//确认按钮
-(UIButton *)sureBtn {
    if(_sureBtn == nil) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.backgroundColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
        [_sureBtn setTitle:SURE forState:UIControlStateNormal];
        [_sureBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_sureBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_sureBtn.layer setMasksToBounds:YES];
        [_sureBtn.layer setCornerRadius:CCGetRealFromPt(12)];
        [_sureBtn addTarget:self action:@selector(sureBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

//确认按钮回调
-(void)sureBtnClicked {
    if(self.sureBtnBlock) {
        self.sureBtnBlock();
    }
}

@end



