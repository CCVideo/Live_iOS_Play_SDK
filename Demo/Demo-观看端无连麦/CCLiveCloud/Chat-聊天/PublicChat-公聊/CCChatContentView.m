//
//  CCChatContentView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/21.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCChatContentView.h"
#import "InformationShowView.h"//提示信息视图
#import "PPUtil.h"
#import "PPStickerKeyboard.h"
#import "PPStickerDataManager.h"

#define maxInputLength 300

@interface CCChatContentView ()<UITextFieldDelegate,PPStickerKeyboardDelegate,UITextViewDelegate>
@property(nonatomic,strong)UIButton                     *rightView;//右侧按钮
@property(nonatomic,strong)InformationShowView          *informationView;//提示视图
@property(nonatomic,strong)UIView                       *emojiView;//表情键盘
@property(nonatomic,assign)CGRect                       keyboardRect;//键盘尺寸
@property(nonatomic,assign)BOOL                         keyboardHidden;//是否隐藏键盘
//新聊天
@property (nonatomic, strong) PPStickerKeyboard *stickerKeyboard;
@end

@implementation CCChatContentView
-(instancetype)init{
    self = [super init];
    if (self) {
        [self addSubview:self.textView];
//        self.chatTextField.backgroundColor = [UIColor blueColor];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).offset(CCGetRealFromPt(20));
            make.left.mas_equalTo(self).offset(CCGetRealFromPt(24));
            make.right.mas_equalTo(self).offset(-CCGetRealFromPt(84));
            make.height.mas_equalTo(CCGetRealFromPt(70));
        }];
        [self addSubview:self.rightView];
        [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).offset(CCGetRealFromPt(20));
            make.left.equalTo(self.textView.mas_right);
            make.right.mas_equalTo(self).offset(-CCGetRealFromPt(10));
            make.height.mas_equalTo(CCGetRealFromPt(70));
        }];
       
        //添加通知
        [self addObserver];
    }
    return self;
}

- (void)setIsFullScroll:(BOOL)isFullScroll
{
    _isFullScroll = isFullScroll;
    
    if (_isFullScroll != YES) {
        
        UIView * line = [[UIView alloc] init];
        [self addSubview:line];
        line.hidden = YES;
        line.backgroundColor = [UIColor colorWithHexString:@"#e8e8e8" alpha:1.0f];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(1);
        }];
        
        
        UIView * line1 = [[UIView alloc] init];
        line1.backgroundColor = [UIColor colorWithHexString:@"#e8e8e8" alpha:1.0f];
        [self addSubview:line1];
        line1.hidden = YES;
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.mas_equalTo(2);
        }];
    }else {
        self.textView.placeholderColor = [UIColor whiteColor];
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
    
    [self.textView resignFirstResponder];
    if(selected) {
//        [_chatTextField setInputView:self.emojiView];
        self.textView.inputView = self.stickerKeyboard;         // 切换到自定义的表情键盘
        [self.textView reloadInputViews];
    } else {
//        [_chatTextField setInputView:nil];
        //收表情键盘
          self.textView.inputView = nil;                          // 切换到系统键盘
          [self.textView reloadInputViews];
    }
    [self.textView becomeFirstResponder];
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
- (void)sendAction{
    self.sendMessageBlock();
//    [self sendBtnEnable:NO];
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.plainText.length > maxInputLength) {
        [_informationView removeFromSuperview];
       _informationView = [[InformationShowView alloc] initWithLabel:ALERT_INPUTLIMITATION];
       [APPDelegate.window addSubview:_informationView];
       [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
       }];
        
       [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(informationViewRemove) userInfo:nil repeats:NO];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([@"\n" isEqualToString:text]) {
        [self sendAction];
        _textView.text = nil;
        [_textView resignFirstResponder];
        
        return NO;
    }
    //超过300文字
    if (range.length == 0) {
        if(textView.text.length > maxInputLength) {
            return NO;
        }
    }

    return YES;
}

- (NSString *)plainText
{
    return [self.textView.attributedText pp_plainTextForRange:NSMakeRange(0, self.textView.attributedText.length)];
}

- (void)refreshTextUI
{
    if (!self.textView.text.length) {
        return;
    }

    UITextRange *markedTextRange = [self.textView markedTextRange];
    UITextPosition *position = [self.textView positionFromPosition:markedTextRange.start offset:0];
    if (position) {
        return;     // 正处于输入拼音还未点确定的中间状态
    }

    NSRange selectedRange = self.textView.selectedRange;

    NSMutableAttributedString *attributedComment = [[NSMutableAttributedString alloc] initWithString:self.plainText attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333" alpha:1.0f]}];

    // 匹配表情
    [PPStickerDataManager.sharedInstance replaceEmojiForAttributedString:attributedComment font:[UIFont systemFontOfSize:16.0]];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5.0;
    [attributedComment addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:attributedComment.pp_rangeOfAll];

    NSUInteger offset = self.textView.attributedText.length - attributedComment.length;
    self.textView.attributedText = attributedComment;
    self.textView.selectedRange = NSMakeRange(selectedRange.location - offset, 0);
}
- (void)textViewDidChange:(UITextView *)textView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshTextUI];
    });
}


//聊天输入框

- (PPStickerTextView *)textView
{
    if (!_textView) {
        _textView = [[PPStickerTextView alloc] init];//WithFrame:CGRectMake(0, 80, 300, 60)];
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.font = [UIFont systemFontOfSize:18.0f];
        _textView.scrollsToTop = NO;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.placeholder = @"在这里和老师互动哦";
        _textView.placeholderColor = [UIColor colorWithHexString:@"999999" alpha:0.8f];
        _textView.textContainerInset = UIEdgeInsetsMake(7, 0, 0, 0);
        _textView.layer.cornerRadius = 35 / 2.0;
        _textView.layer.masksToBounds = YES;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1].CGColor;
//        _textView.inputAccessoryView = self.rightView;
        if (@available(iOS 11.0, *)) {
            _textView.textDragInteraction.enabled = NO;
        }
    }
    return _textView;
}
#pragma mark - PPStickerKeyboardDelegate

- (void)stickerKeyboard:(PPStickerKeyboard *)stickerKeyboard didClickEmoji:(PPEmoji *)emoji
{
    if (!emoji) {
        return;
    }

    UIImage *emojiImage = [UIImage imageNamed:[@"Emotion.bundle" stringByAppendingPathComponent:emoji.imageName]];
    if (!emojiImage) {
        return;
    }

    NSRange selectedRange = self.textView.selectedRange;
    NSString *emojiString = [NSString stringWithFormat:@"[%@]", emoji.imageTag];
    NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc] initWithString:emojiString];
    [emojiAttributedString pp_setTextBackedString:[PPTextBackedString stringWithString:emojiString] range:emojiAttributedString.pp_rangeOfAll];

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [attributedText replaceCharactersInRange:selectedRange withAttributedString:emojiAttributedString];
    self.textView.attributedText = attributedText;
    self.textView.selectedRange = NSMakeRange(selectedRange.location + emojiAttributedString.length, 0);

    [self textViewDidChange:self.textView];
}

- (void)stickerKeyboardDidClickDeleteButton:(PPStickerKeyboard *)stickerKeyboard
{
    NSRange selectedRange = self.textView.selectedRange;
    if (selectedRange.location == 0 && selectedRange.length == 0) {
        return;
    }

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    if (selectedRange.length > 0) {
        [attributedText deleteCharactersInRange:selectedRange];
        self.textView.attributedText = attributedText;
        self.textView.selectedRange = NSMakeRange(selectedRange.location, 0);
    } else {
        NSUInteger deleteCharactersCount = 1;

        // 下面这段正则匹配是用来匹配文本中的所有系统自带的 emoji 表情，以确认删除按钮将要删除的是否是 emoji。这个正则匹配可以匹配绝大部分的 emoji，得到该 emoji 的正确的 length 值；不过会将某些 combined emoji（如 👨‍👩‍👧‍👦 👨‍👩‍👧‍👦 👨‍👨‍👧‍👧），这种几个 emoji 拼在一起的 combined emoji 则会被匹配成几个个体，删除时会把 combine emoji 拆成个体。瑕不掩瑜，大部分情况下表现正确，至少也不会出现删除 emoji 时崩溃的问题了。
        NSString *emojiPattern1 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900-\\U0001F9FF]";
        NSString *emojiPattern2 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900–\\U0001F9FF]\\uFE0F";
        NSString *emojiPattern3 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900–\\U0001F9FF][\\U0001F3FB-\\U0001F3FF]";
        NSString *emojiPattern4 = @"[\\rU0001F1E6-\\U0001F1FF][\\U0001F1E6-\\U0001F1FF]";
        NSString *pattern = [[NSString alloc] initWithFormat:@"%@|%@|%@|%@", emojiPattern4, emojiPattern3, emojiPattern2, emojiPattern1];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:NULL];
        NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:attributedText.string options:kNilOptions range:NSMakeRange(0, attributedText.string.length)];
        for (NSTextCheckingResult *match in matches) {
            if (match.range.location + match.range.length == selectedRange.location) {
                deleteCharactersCount = match.range.length;
                break;
            }
        }

        [attributedText deleteCharactersInRange:NSMakeRange(selectedRange.location - deleteCharactersCount, deleteCharactersCount)];
        self.textView.attributedText = attributedText;
        self.textView.selectedRange = NSMakeRange(selectedRange.location - deleteCharactersCount, 0);
    }

    [self textViewDidChange:self.textView];
}

- (void)stickerKeyboardDidClickSendButton:(PPStickerKeyboard *)stickerKeyboard
{
//发送按钮
    [self sendAction];
    _textView.text = nil;
    [_textView resignFirstResponder];
}
- (PPStickerKeyboard *)stickerKeyboard
{
    if (!_stickerKeyboard) {
        _stickerKeyboard = [[PPStickerKeyboard alloc] init];
        _stickerKeyboard.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), [self.stickerKeyboard heightThatFits]);
        _stickerKeyboard.delegate = self;
    }
    return _stickerKeyboard;
}
@end
