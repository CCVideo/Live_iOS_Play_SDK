//
//  CCChatContentView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/21.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCChatContentView.h"
#import "InformationShowView.h"//提示信息视图
@interface CCChatContentView ()<UITextFieldDelegate>
@property(nonatomic,strong)UIButton                     *rightView;//右侧按钮
@property(nonatomic,strong)InformationShowView          *informationView;//提示视图
@property(nonatomic,strong)UIView                       *emojiView;//表情键盘
@property(nonatomic,assign)CGRect                       keyboardRect;//键盘尺寸
@property(nonatomic,assign)BOOL                         keyboardHidden;//是否隐藏键盘
@end

@implementation CCChatContentView
-(instancetype)init{
    self = [super init];
    if (self) {
        UIView * line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithHexString:@"#e8e8e8" alpha:1.0f];
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(1);
        }];
        
        [self addSubview:self.chatTextField];
//        self.chatTextField.backgroundColor = [UIColor blueColor];
        [_chatTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).offset(CCGetRealFromPt(10));
            make.left.mas_equalTo(self).offset(CCGetRealFromPt(24));
            make.right.mas_equalTo(self).offset(-CCGetRealFromPt(24));
            make.height.mas_equalTo(CCGetRealFromPt(90));
            
        }];
        
        UIView * line1 = [[UIView alloc] init];
        line1.backgroundColor = [UIColor colorWithHexString:@"#e8e8e8" alpha:1.0f];
        [self addSubview:line1];
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.mas_equalTo(2);
        }];
        //添加通知
        [self addObserver];
    }
    return self;
}
#pragma mark - 懒加载
//聊天输入框
-(CustomTextField *)chatTextField{
    if (!_chatTextField) {
        _chatTextField = [[CustomTextField alloc] init];
        _chatTextField.delegate = self;
        _chatTextField.layer.cornerRadius = CCGetRealFromPt(45);
        [_chatTextField addTarget:self action:@selector(chatTextFieldChange) forControlEvents:UIControlEventEditingChanged];
        _chatTextField.rightView = self.rightView;
    }
    return _chatTextField;
}
//聊天输入中
-(void)chatTextFieldChange {
    
    if(_chatTextField.text.length > 300) {
        //        [self endEditing:YES];
        _chatTextField.text = [_chatTextField.text substringToIndex:300];
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:ALERT_INPUTLIMITATION];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(informationViewRemove) userInfo:nil repeats:NO];
    }
}
//右侧表情键盘按钮
-(UIButton *)rightView {
    if(!_rightView) {
        _rightView = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightView.frame = CGRectMake(0, 0, 42, 42);
        _rightView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightView.backgroundColor = CCClearColor;
        [_rightView setImage:[UIImage imageNamed:@"face_nov"] forState:UIControlStateNormal];
        [_rightView setImage:[UIImage imageNamed:@"face_hov"] forState:UIControlStateSelected];
        [_rightView addTarget:self action:@selector(faceBoardClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightView;
}
//点击表情键盘
- (void)faceBoardClick {
    BOOL selected = !_rightView.selected;
    _rightView.selected = selected;
    
    if(selected) {
        [_chatTextField setInputView:self.emojiView];
    } else {
        [_chatTextField setInputView:nil];
    }
    
    [_chatTextField becomeFirstResponder];
    [_chatTextField reloadInputViews];
}
//表情视图
-(UIView *)emojiView {
    if(!_emojiView) {
        
        if(_keyboardRect.size.width == 0 || _keyboardRect.size.height ==0) {
            _keyboardRect = CGRectMake(0, 0, SCREEN_WIDTH, 271);
        }
        _emojiView = [[UIView alloc] initWithFrame:_keyboardRect];
        _emojiView.backgroundColor = CCRGBColor(255,255,255);
        
        UIImage *image = [UIImage imageNamed:@"01"];
        //        CGFloat faceIconSize = CCGetRealFromPt(60);
        CGFloat faceIconSize = image.size.width;
        CGFloat xspace = (_keyboardRect.size.width - FACE_COUNT_CLU * faceIconSize) / (FACE_COUNT_CLU + 1);
        CGFloat yspace = (_keyboardRect.size.height - 26 - FACE_COUNT_ROW * faceIconSize) / (FACE_COUNT_ROW + 1);
        
        for (int i = 0; i < FACE_COUNT_ALL; i++) {
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.tag = i + 1;
            
            [faceButton addTarget:self action:@selector(faceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            //            计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = (i % FACE_COUNT_CLU + 1) * xspace + (i % FACE_COUNT_CLU) * faceIconSize;
            CGFloat y = (i / FACE_COUNT_CLU + 1) * yspace + (i / FACE_COUNT_CLU) * faceIconSize;
            
            faceButton.frame = CGRectMake(x, y, faceIconSize, faceIconSize);
            faceButton.backgroundColor = CCClearColor;
            [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%02d", i+1]]
                        forState:UIControlStateNormal];
            faceButton.contentMode = UIViewContentModeScaleAspectFit;
            [_emojiView addSubview:faceButton];
        }
        //删除键
        UIButton *button14 = (UIButton *)[_emojiView viewWithTag:14];
        UIButton *button20 = (UIButton *)[_emojiView viewWithTag:20];
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        back.contentMode = UIViewContentModeScaleAspectFit;
        [back setImage:[UIImage imageNamed:@"chat_btn_facedel"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        [_emojiView addSubview:back];
        
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(button14);
            make.centerY.mas_equalTo(button20);
        }];
    }
    return _emojiView;
}

- (void) backFace {
    NSString *inputString = _chatTextField.text;
    if ( [inputString length] > 0) {
        NSString *string = nil;
        NSInteger stringLength = [inputString length];
        if (stringLength >= FACE_NAME_LEN) {
            string = [inputString substringFromIndex:stringLength - FACE_NAME_LEN];
            NSRange range = [string rangeOfString:FACE_NAME_HEAD];
            if ( range.location == 0 ) {
                string = [inputString substringToIndex:[inputString rangeOfString:FACE_NAME_HEAD options:NSBackwardsSearch].location];
            } else {
                string = [inputString substringToIndex:stringLength - 1];
            }
        }
        else {
            string = [inputString substringToIndex:stringLength - 1];
        }
        _chatTextField.text = string;
    }
}

- (void)faceButtonClicked:(id)sender {
    NSInteger i = ((UIButton*)sender).tag;
    
    NSMutableString *faceString = [[NSMutableString alloc]initWithString:_chatTextField.text];
    [faceString appendString:[NSString stringWithFormat:@"[em2_%02d]",(int)i]];
    _chatTextField.text = faceString;
    [self chatTextFieldChange];
}
#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(!StrNotEmpty([_chatTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]])) {
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:ALERT_EMPTYMESSAGE];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(informationViewRemove) userInfo:nil repeats:NO];
        return YES;
    }
    //发送消息回调
    if (_sendMessageBlock) {
        _sendMessageBlock();
    }
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
    return YES;
}
#pragma mark - 移除提示视图
-(void)informationViewRemove {
    [_informationView removeFromSuperview];
    _informationView = nil;
}
#pragma mark - 添加通知
-(void)addObserver{
    //键盘将要弹出
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //键盘将要消失
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //接收到停止弹出键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hiddenKeyBoard:)
                                                 name:@"keyBorad_hidden"
                                               object:nil];
}
#pragma mark - 键盘事件
-(void)hiddenKeyBoard:(NSNotification *)noti{
    NSDictionary *userInfo = [noti userInfo];
    self.keyboardHidden = [userInfo[@"keyBorad_hidden"] boolValue];
}
//键盘将要出现
- (void)keyboardWillShow:(NSNotification *)noti {
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
    if (self.delegate) {
        [self.delegate keyBoardWillShow:y endEditIng:self.keyboardHidden];
    }
}
//
//键盘将要消失
- (void)keyboardWillHide:(NSNotification *)notif {
    if (self.delegate) {
        [self.delegate hiddenKeyBoard];
    }
}
#pragma mark - 移除监听
-(void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"keyBorad_hidden" object:nil];
}
-(void)dealloc{
    [self removeObserver];
}
@end
