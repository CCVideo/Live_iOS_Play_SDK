//
//  LabelUserInfo.m
//  NewCCDemo
//
//  Created by cc on 2016/11/23.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "TextFieldUserInfo.h"

@interface TextFieldUserInfo()

@property(nonatomic,strong)UIView               *upLine;
@property(nonatomic,strong)UILabel              *leftLabel;
@property(nonatomic,strong)UIView               *leftLabelView;

@end

@implementation TextFieldUserInfo

- (void)textFieldWithLeftText:(NSString *)leftText placeholder:(NSString *)placeholder lineLong:(BOOL)lineLong text:(NSString *)text {
    WS(ws);
    
    self.borderStyle = UITextBorderStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.placeholder = placeholder;
    self.font = [UIFont systemFontOfSize:FontSize_28];
    self.placeholder = placeholder;
    self.text = text;
    self.textColor = CCRGBColor(51, 51, 51);
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.clearsOnBeginEditing = NO;
    self.textAlignment = NSTextAlignmentLeft;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.keyboardType = UIKeyboardTypeDefault;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.returnKeyType =UIReturnKeyDone;
    self.keyboardAppearance=UIKeyboardAppearanceDefault;
    self.leftViewMode = UITextFieldViewModeAlways;

    [self addSubview:self.upLine];
    self.leftView = self.leftLabelView;
    [_leftLabelView addSubview:self.leftLabel];
    [self.leftLabel setText:leftText];
    
    if(lineLong) {
        [_upLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(ws);
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
        make.left.mas_equalTo(ws.leftLabelView).with.offset(CCGetRealFromPt(40));
        make.right.top.mas_equalTo(ws.leftLabelView);
        make.bottom.mas_equalTo(ws.leftLabelView).offset(-1);
    }];
}

-(UIView *)upLine {
    if(_upLine == nil) {
        _upLine = [[UIView alloc] init];
        [_upLine setBackgroundColor:CCRGBColor(238,238,238)];
    }
    return _upLine;
}

-(UIView *)leftLabelView {
    if(_leftLabelView == nil) {
        _leftLabelView = [[UIView alloc] init];
        [_leftLabelView setBackgroundColor:[UIColor whiteColor]];
        [_leftLabelView setFrame:CGRectMake(0, 2, CCGetRealFromPt(190), CCGetRealFromPt(92) - 2)];
    }
    return _leftLabelView;
}

-(UILabel *)leftLabel {
    if(_leftLabel == nil) {
        _leftLabel = [[UILabel alloc] init];
        [_leftLabel setBackgroundColor:[UIColor whiteColor]];
        [_leftLabel setTextColor:[UIColor blackColor]];
        [_leftLabel setFont:[UIFont systemFontOfSize:FontSize_28]];
        _leftLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _leftLabel;
}

@end
