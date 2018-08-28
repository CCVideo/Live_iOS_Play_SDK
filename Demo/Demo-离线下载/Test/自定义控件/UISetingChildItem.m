//
//  UISetingChildItem.m
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "UISetingChildItem.h"

@interface UISetingChildItem()

@property(nonatomic,strong)UIView               *upLine;
@property(nonatomic,strong)UILabel              *leftLabel;
@property(nonatomic,copy)  ButtonClicked        block;

@end

@implementation UISetingChildItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)settingWithLineLong:(BOOL)lineLong leftText:(NSString *)leftText selected:(BOOL)selected block:(ButtonClicked)block {
    WS(ws);
    self.block = block;
    [self addSubview:self.upLine];
    [self addSubview:self.leftLabel];
    [self.leftLabel setText:leftText];
    [self addSubview:self.rightBtn];
    
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
    
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(40));
        make.top.mas_equalTo(ws).offset(CCGetRealFromPt(28));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(32), CCGetRealFromPt(32)));
    }];
    _rightBtn.selected = selected;
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClicked)];
    [self addGestureRecognizer:singleTap];
}

-(UIButton *)rightBtn {
    if(!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setBackgroundImage:[UIImage imageNamed:@"set_btn_select_nor"] forState:UIControlStateNormal];
        [_rightBtn setBackgroundImage:[UIImage imageNamed:@"set_btn_select_hov"] forState:UIControlStateSelected];
        [_rightBtn.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_rightBtn addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

-(void)buttonClicked {
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

@end
