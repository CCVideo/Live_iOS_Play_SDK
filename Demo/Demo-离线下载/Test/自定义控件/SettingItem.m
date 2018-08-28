//
//  SettingItem.m
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "SettingItem.h"

@interface SettingItem()

@property(nonatomic,strong)UIView               *upLine;
@property(nonatomic,strong)UILabel              *leftLabel;
@property(nonatomic,strong)UIImageView          *rightView;
@property(nonatomic,strong)UIButton             *switchButton;
@property(nonatomic,copy)  ActionBlock          block;
@property(nonatomic,assign)BOOL                 screenDirection;
@property(nonatomic,assign)BOOL                 beautiful;
@property(nonatomic,copy)SwitchBtnClickedBlock  switchBtnClickedBlock;

@end

@implementation SettingItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)settingWithLineLong:(BOOL)lineLong leftText:(NSString *)leftText rightText:(NSString *)rightText rightArrow:(BOOL)rightArrow screenDirection:(BOOL)screenDirection beautiful:(BOOL)beautiful block:(ActionBlock)block {
    
    WS(ws);
    [self addSubview:self.upLine];
    [self addSubview:self.leftLabel];
    [self.leftLabel setText:leftText];
    _block = block;
    _screenDirection = screenDirection;
    _beautiful = beautiful;
    
    if(rightArrow) {
        [self addSubview:self.rightView];
        [self addSubview:self.rightLabel];
        [self.rightLabel setText:rightText];
        
        [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws).with.offset(-CCGetRealFromPt(68));
            make.top.mas_equalTo(ws).with.offset(1);
            make.bottom.mas_equalTo(ws).offset(-1);
            make.width.mas_equalTo(ws).multipliedBy(0.3);
        }];
        
        [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(38));
            make.top.mas_equalTo(ws).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(18), CCGetRealFromPt(30)));
        }];
    } else {
        [self addSubview:self.switchButton];
        [_switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(40));
            make.top.mas_equalTo(ws).offset(CCGetRealFromPt(24));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(40)));
        }];
    }
    
    if(lineLong) {
        [_upLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws);
            make.top.mas_equalTo(ws.mas_top);
            make.height.mas_equalTo(1);
        }];
    } else {
        [_upLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws).offset(CCGetRealFromPt(40));
            make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(40));
            make.top.mas_equalTo(ws.mas_top);
            make.height.mas_equalTo(1);
        }];
    }
    
    [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws).with.offset(1);
        make.bottom.mas_equalTo(ws).offset(-1);
        make.width.mas_equalTo(ws).multipliedBy(0.3);
    }];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    [self addGestureRecognizer:singleTap];
}

-(void)handleSingleTap
{
    if(self.block) {
        self.block();
    }
}

-(UIButton *)switchButton {
    if(!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchButton setBackgroundImage:[UIImage imageNamed:@"set_btn_off"] forState:UIControlStateNormal];
        [_switchButton setBackgroundImage:[UIImage imageNamed:@"set_btn_on"] forState:UIControlStateSelected];
        [_switchButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_switchButton addTarget:self action:@selector(switchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}

-(void)switchButtonClicked {
    [_switchButton setSelected:(![_switchButton isSelected])];
    if(self.screenDirection) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[_switchButton isSelected]] forKey:SET_SCREEN_LANDSCAPE];
        if(self.switchBtnClickedBlock) {
            self.switchBtnClickedBlock();
        }
    } else if(self.beautiful) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[_switchButton isSelected]] forKey:SET_BEAUTIFUL];
    }
}

-(UIImageView *)rightView {
    if(!_rightView) {
        _rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"set_ic_go_nor"]];
        [_rightView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _rightView;
}

-(UIView *)upLine {
    if(_upLine == nil) {
        _upLine = [UIView new];
        [_upLine setBackgroundColor:CCRGBColor(238,238,238)];
    }
    return _upLine;
}

-(UILabel *)leftLabel {
    if(_leftLabel == nil) {
        _leftLabel = [UILabel new];
        [_leftLabel setBackgroundColor:CCClearColor];
        [_leftLabel setTextColor:CCRGBColor(51, 51, 51)];
        [_leftLabel setFont:[UIFont systemFontOfSize:FontSize_28]];
        _leftLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _leftLabel;
}

-(UILabel *)rightLabel {
    if(_rightLabel == nil) {
        _rightLabel = [UILabel new];
        [_rightLabel setBackgroundColor:CCClearColor];
        [_rightLabel setTextColor:CCRGBColor(102,102,102)];
        [_rightLabel setFont:[UIFont systemFontOfSize:FontSize_26]];
        _rightLabel.textAlignment = NSTextAlignmentRight;
    }
    return _rightLabel;
}

-(void)setSwitchOn:(BOOL)on {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.switchButton.selected = on;
    });
}

-(void)setSwitchBtnClickedBlock:(SwitchBtnClickedBlock)switchBtnClickedBlock {
    _switchBtnClickedBlock = switchBtnClickedBlock;
}

-(BOOL)isSwitchOn {
    return _switchButton.selected;
}

@end
