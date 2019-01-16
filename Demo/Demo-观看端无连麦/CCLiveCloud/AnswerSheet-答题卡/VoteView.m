//
//  VoteView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/25.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "VoteView.h"

@interface VoteView()

@property(nonatomic,strong)UIImageView              *topBgView;//顶部背景视图
@property(nonatomic,strong)UILabel                  *topLabel;//顶部label
@property(nonatomic,strong)UILabel                  *titleLabel;//标题label
@property(nonatomic,strong)UIButton                 *closeBtn;//关闭按钮
@property(nonatomic,strong)UIView                   *labelBgView;//label背景视图
@property(nonatomic,strong)UILabel                  *centerLabel;

@property(nonatomic,strong)UIButton                 *aButton;//选项A按钮
@property(nonatomic,strong)UIButton                 *bButton;//选项B按钮
@property(nonatomic,strong)UIButton                 *cButton;//选项C按钮
@property(nonatomic,strong)UIButton                 *dButton;//选项D按钮
@property(nonatomic,strong)UIButton                 *eButton;//选项E按钮
@property(nonatomic,strong)UIButton                 *rightButton;//正确按钮
@property(nonatomic,strong)UIButton                 *wrongButton;//错误按钮

@property(nonatomic,copy)  VoteBtnClickedSingle     voteSingleBlock;//单选题点击回调
@property(nonatomic,copy)  VoteBtnClickedMultiple   voteMultipleBlock;//多选题点击回调
@property(nonatomic,copy)  VoteBtnClickedSingleNOSubmit     singleNOSubmit;//单选题未发布回调
@property(nonatomic,copy)  VoteBtnClickedMultipleNOSubmit   multipleNOSubmit;//多选题未发布回调
@property(nonatomic,assign)NSInteger                count;//选项数量

//@property(nonatomic,strong)UIImageView              *rightLogo;
//@property(nonatomic,strong)UIView                   *selectBorder;
@property(nonatomic,strong)UIButton                 *submitBtn;//发布按钮
@property(nonatomic,assign)NSInteger                selectIndex;//单选答案
@property(nonatomic,strong)NSMutableArray           *selectIndexArray;//多选答案
@property(nonatomic,strong)UIView                   *view;
@property(nonatomic,assign)BOOL                     single;//是否是单选
@property(nonatomic,assign)BOOL                     isScreenLandScape;//是否全屏

@end

//答题
@implementation VoteView

-(instancetype) initWithCount:(NSInteger)count singleSelection:(BOOL)single voteSingleBlock:(VoteBtnClickedSingle)voteSingleBlock voteMultipleBlock:(VoteBtnClickedMultiple)voteMultipleBlock singleNOSubmit:(VoteBtnClickedSingleNOSubmit)singleNOSubmit multipleNOSubmit:(VoteBtnClickedMultipleNOSubmit)multipleNOSubmit isScreenLandScape:(BOOL)isScreenLandScape{
    self = [super init];
    if(self) {
        self.isScreenLandScape  = isScreenLandScape;
        self.single             = single;
        self.count              = count;
        self.voteSingleBlock    = voteSingleBlock;
        self.voteMultipleBlock  = voteMultipleBlock;
        self.singleNOSubmit     = singleNOSubmit;
        self.multipleNOSubmit   = multipleNOSubmit;
        [self initUI];
    }
    return self;
}

-(void)submitBtnClicked {
    if(self.single) {
        if(self.voteSingleBlock) {
            self.voteSingleBlock(_selectIndex);
        }
    } else {
        if(self.voteMultipleBlock) {
            self.voteMultipleBlock(self.selectIndexArray);
        }
    }
    [self remove];
}

-(void)initUI {
    WS(ws)
    self.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
    
    _selectIndex = 0;
    _selectIndexArray = [[NSMutableArray alloc] init];
    //初始化背景视图
    _view = [[UIView alloc]init];
    _view.backgroundColor = [UIColor whiteColor];
    _view.layer.cornerRadius = CCGetRealFromPt(10);
    [self addSubview:_view];
    if(!self.isScreenLandScape) {//竖屏模式下约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
//            make.centerY.mas_equalTo(ws);
            make.top.mas_equalTo(ws).offset(CCGetRealFromPt(567));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(710), CCGetRealFromPt(675)));
        }];
    } else {//横屏模式下约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
            make.centerY.mas_equalTo(ws);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(710), CCGetRealFromPt(675)));
        }];
    }
    
    //顶部视图
    [self.view addSubview:self.topBgView];
    [_topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view);
        make.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(80));
    }];
    //关闭按钮
    [self.topBgView addSubview:self.closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.topBgView).offset(-CCGetRealFromPt(20));
        make.centerY.mas_equalTo(ws.topBgView);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(56),CCGetRealFromPt(56)));
    }];
    //顶部标题
    [self.topBgView addSubview:self.topLabel];
    [_topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.topBgView);
    }];
    
    //答题卡提示
    [self.view addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(120));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(710), CCGetRealFromPt(36)));
    }];
    
    //题干提示背景视图
    [self.view addSubview:self.labelBgView];
    [_labelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(180));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(390), CCGetRealFromPt(40)));
    }];
    //题干部分提示文字
    [_labelBgView addSubview:self.centerLabel];
    [_centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.labelBgView);
    }];
    
    //提交按钮
    [self.view addSubview:self.submitBtn];
    [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.view);
        make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(50));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(360), CCGetRealFromPt(90)));
    }];
    [self.submitBtn setEnabled:NO];
    
    //选择btn
    if(self.count >= 3) {
        if(self.count >= 3) {
            _aButton = [self createButtonWithStr:@"A" imageName:nil tag:0];
            [self.view addSubview:self.aButton];
            [_aButton mas_makeConstraints:^(MASConstraintMaker *make) {
                if(ws.count == 5) {
                    make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(15));
                    make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(575));
                } else if(ws.count == 4) {
                    make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(70));
                    make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(520));
                } else if(ws.count == 3) {
                    make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(125));
                    make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(465));
                }
                make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(308));
                make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(247));
            }];

            _bButton = [self createButtonWithStr:@"B" imageName:nil tag:1];
            [self.view addSubview:self.bButton];
            [_bButton mas_makeConstraints:^(MASConstraintMaker *make) {
                if(ws.count == 5) {
                    make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(155));
                    make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(435));
                } else if(ws.count == 4) {
                    make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(220));
                    make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(370));
                } else if(ws.count == 3) {
                    make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(295));
                    make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(295));
                }
                make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(308));
                make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(247));
            }];

            _cButton = [self createButtonWithStr:@"C" imageName:nil tag:2];
            [self.view addSubview:self.cButton];
            [_cButton mas_makeConstraints:^(MASConstraintMaker *make) {
                if(ws.count == 5) {
                    make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(295));
                    make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(295));
                } else if(ws.count == 4) {
                    make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(370));
                    make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(220));
                } else if(ws.count == 3) {
                    make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(465));
                    make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(125));
                }
                make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(308));
                make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(247));
            }];
        }
        if(self.count >= 4) {
            _dButton = [self createButtonWithStr:@"D" imageName:nil tag:3];
            [self.view addSubview:self.dButton];
            [_dButton mas_makeConstraints:^(MASConstraintMaker *make) {
                if(ws.count == 5) {
                    make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(435));
                    make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(155));
                } else if(ws.count == 4) {
                    make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(520));
                    make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(70));
                }
                make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(308));
                make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(247));
            }];
        }
        
        if(self.count == 5) {
            _eButton = [self createButtonWithStr:@"E" imageName:nil tag:4];
            [self.view addSubview:self.eButton];
            [_eButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(575));
                make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(15));
                make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(308));
                make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(247));
            }];
        }
    } else if(self.count == 2) {
        _rightButton = [self createButtonWithStr:nil imageName:@"option_right" tag:0];
        [self.view addSubview:self.rightButton];
        [_rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(195));
            make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(395));
            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(308));
            make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(247));
        }];
        
        _wrongButton = [self createButtonWithStr:nil imageName:@"option_wrong" tag:1];
        [self.view addSubview:self.wrongButton];
        [_wrongButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(395));
            make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(195));
            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(308));
            make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(247));
        }];
    }
    
    [self layoutIfNeeded];
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
//关闭按钮点击回调
-(void)closeBtnClicked {
    [self removeFromSuperview];
}
//移除视图
-(void)remove{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}
//顶部文字
-(UILabel *)topLabel {
    if(!_topLabel) {
        _topLabel = [UILabel new];
        _topLabel.text = @"答题卡";
        _topLabel.textColor = CCRGBColor(51,51,51);
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.font = [UIFont systemFontOfSize:FontSize_36];
    }
    return _topLabel;
}
//提示标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"请选择答案";
        _titleLabel.textColor = [UIColor colorWithHexString:@"#1e1f21" alpha:1.f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_36];
    }
    return _titleLabel;
}
//提示问题
-(UILabel *)centerLabel {
    if(!_centerLabel) {
        _centerLabel = [UILabel new];
        _centerLabel.text = ALERT_VOTE;
        _centerLabel.textColor = [UIColor colorWithHexString:@"#666666" alpha:1.f];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.font = [UIFont systemFontOfSize:FontSize_24];
    }
    return _centerLabel;
}

- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(UIView *)labelBgView {
    if(!_labelBgView) {
        _labelBgView = [UIView new];
        _labelBgView.backgroundColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.f];
        _labelBgView.layer.masksToBounds = YES;
        _labelBgView.layer.cornerRadius = CCGetRealFromPt(20);
        _labelBgView.layer.borderColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.f].CGColor;
        _labelBgView.layer.borderWidth = CCGetRealFromPt(1);
    }
    return _labelBgView;
}

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

-(UIButton *)submitBtn {
    if(_submitBtn == nil) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _submitBtn.backgroundColor = CCRGBColor(255,102,51);
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_submitBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_submitBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_submitBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_submitBtn.layer setMasksToBounds:YES];
//        [_submitBtn.layer setBorderWidth:CCGetRealFromPt(2)];
//        [_submitBtn.layer setBorderColor:[CCRGBColor(252,92,61) CGColor]];
        [_submitBtn.layer setCornerRadius:CCGetRealFromPt(45)];
        [_submitBtn addTarget:self action:@selector(submitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [_submitBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(255,102,51)] forState:UIControlStateNormal];
        [_submitBtn setBackgroundImage:[self createImageWithColor:CCRGBAColor(255,102,51,0.8)] forState:UIControlStateDisabled];
    }
    return _submitBtn;
}

-(void)buttonClicked:(UIButton *)sender {
    [self.submitBtn setEnabled:YES];
    if(self.single == YES) {
        //设置button为选中样式，其他button设置为不被选择
        if (self.count == 2) {
            _wrongButton.selected = NO;
            _rightButton.selected = NO;
        }else{
            _aButton.selected = NO;
            _bButton.selected = NO;
            _cButton.selected = NO;
            _dButton.selected = NO;
            _eButton.selected = NO;
        }
        sender.selected = YES;
        //----
        UIView *view = [self.view viewWithTag:_selectIndex + 10];
        UIImageView *imageView = [self.view viewWithTag:_selectIndex + 20];
        [imageView removeFromSuperview];
        [view removeFromSuperview];
        
        UIView *selectBorder = [[UIView alloc] init];
        selectBorder.backgroundColor = CCClearColor;
        selectBorder.layer.borderWidth = 1;
        selectBorder.layer.borderColor = [CCRGBColor(255,192,171) CGColor];
        selectBorder.layer.cornerRadius = sender.layer.cornerRadius;
        [self.view addSubview:selectBorder];
        selectBorder.tag = sender.tag + 10;
        [selectBorder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(sender);
        }];
        
        UIImageView *rightLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voteView_selected"]];
        rightLogo.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:rightLogo];
        rightLogo.tag = sender.tag + 20;
        _selectIndex = sender.tag;
        
        [rightLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(selectBorder).offset(CCGetRealFromPt(100));
            make.bottom.mas_equalTo(selectBorder).offset(-CCGetRealFromPt(100));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(32),CCGetRealFromPt(32)));
        }];
        if(self.singleNOSubmit) {
            self.singleNOSubmit(_selectIndex);
        }
    } else {
        sender.selected = !sender.selected;
        NSNumber *number = [NSNumber numberWithInteger:sender.tag];
        NSUInteger index = [self.selectIndexArray indexOfObject:number];
        if(index != NSNotFound) {
            UIView *view = [self.view viewWithTag:sender.tag + 10];
            UIImageView *imageView = [self.view viewWithTag:sender.tag + 20];
            [view removeFromSuperview];
            [imageView removeFromSuperview];
            [self.selectIndexArray removeObjectAtIndex:index];
        } else {
            UIView *selectBorder = [[UIView alloc] init];
            selectBorder.backgroundColor = CCClearColor;
            selectBorder.layer.borderWidth = 1;
            selectBorder.layer.borderColor = [CCRGBColor(255,192,171) CGColor];
            selectBorder.layer.cornerRadius = sender.layer.cornerRadius;
            [self.view addSubview:selectBorder];
            selectBorder.tag = sender.tag + 10;
            [selectBorder mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(sender);
            }];
//            selectBorder.userInteractionEnabled = YES;
            
            UIImageView *rightLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voteView_selected"]];
            rightLogo.contentMode = UIViewContentModeScaleAspectFit;
            [self.view addSubview:rightLogo];
            rightLogo.tag = sender.tag + 20;
//            rightLogo.userInteractionEnabled = YES;
            
            [rightLogo mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(selectBorder).offset(CCGetRealFromPt(100));
                make.bottom.mas_equalTo(selectBorder).offset(-CCGetRealFromPt(100));
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(32),CCGetRealFromPt(32)));
            }];
            
            [self.selectIndexArray addObject:number];
        }
        if(self.multipleNOSubmit) {
            self.multipleNOSubmit(_selectIndexArray);
        }
    }
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    CGPoint aPoint = [self convertPoint:point toView:self.aButton];
    CGPoint bPoint = [self convertPoint:point toView:self.bButton];
    CGPoint cPoint = [self convertPoint:point toView:self.cButton];
    CGPoint dPoint = [self convertPoint:point toView:self.dButton];
    CGPoint ePoint = [self convertPoint:point toView:self.eButton];
    if([self.aButton pointInside:aPoint withEvent:event]){
        return self.aButton;
    } else if ([self.bButton pointInside:bPoint withEvent:event]){
        return self.bButton;
    } else if ([self.cButton pointInside:cPoint withEvent:event]){
        return self.cButton;
    } else if ([self.dButton pointInside:dPoint withEvent:event]){
        return self.dButton;
    } else if ([self.eButton pointInside:ePoint withEvent:event]){
        return self.eButton;
    }
    return [super hitTest:point withEvent:event];
}

-(UIButton *)createButtonWithStr:(NSString *)str imageName:(NSString *)imageName tag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.contentMode = UIViewContentModeScaleAspectFit;
    [button setBackgroundImage:[self createImageWithColor:[UIColor colorWithHexString:@"#f0f1f2" alpha:1.f]] forState:UIControlStateNormal];
    [button setBackgroundImage:[self createImageWithColor:CCRGBColor(255,231,224)] forState:UIControlStateSelected];
    [button setBackgroundImage:[self createImageWithColor:CCRGBColor(255,231,224)] forState:UIControlStateHighlighted];
    [button.layer setMasksToBounds:YES];
    button.tag = tag;
    [button.layer setCornerRadius:CCGetRealFromPt(8)];
    [button.layer setBorderColor:[CCRGBColor(255,240,236) CGColor]];
    [button.layer setBorderWidth:1];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if(str) {
        UILabel *label = [UILabel new];
        label.text = str;
        label.textColor = CCRGBColor(255,100,61);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:FontSize_72];
        [button addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(button);
        }];
    } else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button addSubview:imageView];
        if([imageName isEqualToString:@"option_right"]) {
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(button);
            }];
        } else if([imageName isEqualToString:@"option_wrong"]){
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(button);
            }];
        }
    }
    
    return button;
}
@end
