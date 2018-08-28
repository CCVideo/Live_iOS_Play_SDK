//
//  ServerChildItem.m
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "ServerChildItem.h"

@interface ServerChildItem()

@property(nonatomic,strong)UIView               *upLine;
@property(nonatomic,copy)  ButtonClicked        block;

@end

@implementation ServerChildItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)settingWithLineLong:(BOOL)lineLong leftText:(NSString *)leftText rightText:(NSString *)rightText selected:(BOOL)selected block:(ButtonClicked)block {
    self.block = block;
    WS(ws);
    [self addSubview:self.upLine];
    [self addSubview:self.leftLabel];
    [self.leftLabel setText:leftText];
    [self addSubview:self.rightLabel];
    [self.rightLabel setText:rightText];
    
    [self addSubview:self.leftBtn];
    
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
    
    [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws).offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws).offset(CCGetRealFromPt(28));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(32), CCGetRealFromPt(32)));
    }];
    _leftBtn.selected = selected;
    
    [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.leftBtn.mas_right).with.offset(CCGetRealFromPt(10));
        make.top.mas_equalTo(ws).with.offset(1);
        make.bottom.mas_equalTo(ws).offset(-1);
        make.width.mas_equalTo(ws).multipliedBy(0.3);
    }];
    
    [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws).with.offset(-CCGetRealFromPt(40));
        make.top.mas_equalTo(ws).with.offset(1);
        make.bottom.mas_equalTo(ws).offset(-1);
        make.width.mas_equalTo(ws).multipliedBy(0.3);
    }];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonSelected)];
    [self addGestureRecognizer:singleTap];
}

-(UIButton *)leftBtn {
    if(!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setBackgroundImage:[UIImage imageNamed:@"set_btn_select_nor"] forState:UIControlStateNormal];
        [_leftBtn setBackgroundImage:[UIImage imageNamed:@"set_btn_select_hov"] forState:UIControlStateSelected];
        [_leftBtn.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_leftBtn addTarget:self action:@selector(buttonSelected) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

-(void)buttonSelected {
    if(self.block) {
        self.block();
    }
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

@end

