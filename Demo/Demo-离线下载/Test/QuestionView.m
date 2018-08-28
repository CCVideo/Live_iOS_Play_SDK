//
//  QuestionView.m
//  NewCCDemo
//
//  Created by cc on 2016/12/29.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "QuestionView.h"
#import "QuestionTextField.h"
#import "Dialogue.h"
#import "UIImage+Extension.h"
#import "InformationShowView.h"

@interface QuestionView()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,strong)UITableView                  *questionTableView;
//@property(nonatomic,strong)NSMutableArray               *tableArray;
@property(nonatomic,copy)  NSString                     *antename;
@property(nonatomic,copy)  NSString                     *anteid;
@property(nonatomic,strong)QuestionTextField            *questionTextField;
@property(nonatomic,strong)UIButton                     *sendButton;
@property(nonatomic,strong)UIView                       *contentView;
@property(nonatomic,strong)UIButton                     *leftView;
@property(nonatomic,strong)UIView                       *emojiView;
@property(nonatomic,assign)CGRect                       keyboardRect;

@property(nonatomic,strong)NSMutableDictionary          *QADic;
@property(nonatomic,strong)NSMutableArray               *keysArr;
@property(nonatomic,strong)NSMutableArray               *keysArrAll;
@property(nonatomic,copy)  QuestionBlock                block;
@property(nonatomic,assign)BOOL                         input;

@end

@implementation QuestionView

-(instancetype)initWithQuestionBlock:(QuestionBlock)questionBlock input:(BOOL)input{
    self = [super init];
    if(self) {
        self.block      = questionBlock;
        self.input      = input;
        [self initUI];
        if(self.input) {
            [self addObserver];
        }
    }
    return self;
}

-(void)reloadQADic:(NSMutableDictionary *)QADic keysArrAll:(NSMutableArray *)keysArrAll {
    self.QADic = [QADic mutableCopy];
    self.keysArrAll = [keysArrAll mutableCopy];
    if(self.leftView.selected) {
        [self.keysArr removeAllObjects];
        for(NSString *encryptId in self.keysArrAll) {
            NSMutableArray *arr = [self.QADic objectForKey:encryptId];
            Dialogue *dialogue = [arr objectAtIndex:0];
            if([dialogue.fromuserid isEqualToString:dialogue.myViwerId]) {
                [self.keysArr addObject:encryptId];
            }
        }
    } else {
//        self.keysArr = [self.keysArrAll mutableCopy];
        [self.keysArr removeAllObjects];
        for(NSString *encryptId in self.keysArrAll) {
            NSMutableArray *arr = [self.QADic objectForKey:encryptId];
            Dialogue *dialogue = [arr objectAtIndex:0];
            if([dialogue.fromuserid isEqualToString:dialogue.myViwerId] || [arr count] > 1) {
                [self.keysArr addObject:encryptId];
            }
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.questionTableView reloadData];
        if (self.keysArr != nil && [self.keysArr count] != 0 ) {
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.keysArr.count-1) inSection:0];
            [self.questionTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

-(void)dealloc {
    [self removeObserver];
}

-(void)initUI {
    WS(ws)
    if(self.input) {
        [self addSubview:self.contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.right.and.left.mas_equalTo(ws);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        
        [self addSubview:self.questionTableView];
        [_questionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.left.mas_equalTo(ws);
            make.bottom.mas_equalTo(ws.contentView.mas_top);
        }];
        
        [self.contentView addSubview:self.questionTextField];
        [_questionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(24));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(556), CCGetRealFromPt(84)));
        }];
        
        [self.contentView addSubview:self.sendButton];
        [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.right.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(24));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(120), CCGetRealFromPt(84)));
        }];
    } else {
        [self addSubview:self.questionTableView];
        [_questionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws);
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self chatSendMessage];
    return YES;
}

-(void)chatSendMessage {
    NSString *str = _questionTextField.text;
    if(str == nil || str.length == 0) {
        return;
    }
    
    if(self.block) {
        self.block(str);
    }
    
    _questionTextField.text = nil;
    [_questionTextField resignFirstResponder];
}

-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.questionTextField isFirstResponder]) {
        return;
    }
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
    CGFloat x = _keyboardRect.size.width;
    NSLog(@"键盘高度是  %d",(int)y);
    NSLog(@"键盘宽度是  %d",(int)x);
    if ([self.questionTextField isFirstResponder]) {
        WS(ws)
        [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.and.left.mas_equalTo(ws);
            make.bottom.mas_equalTo(ws).offset(-y);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        
        [_questionTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.left.mas_equalTo(ws);
            make.bottom.mas_equalTo(ws.contentView.mas_top);
        }];
        
        [UIView animateWithDuration:0.25f animations:^{
            [ws layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (self.keysArr != nil && [self.keysArr count] != 0 ) {
                NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.keysArr.count - 1) inSection:0];
                [_questionTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self hideKeyboard];
}

- (void)hideKeyboard {
    WS(ws)
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.and.left.and.bottom.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(110));
    }];
    
    [_questionTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.and.left.mas_equalTo(ws);
        make.bottom.mas_equalTo(ws.contentView.mas_top);
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [ws layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = CCRGBColor(240,240,240);
    }
    return _contentView;
}

-(QuestionTextField *)questionTextField {
    if(!_questionTextField) {
        _questionTextField = [QuestionTextField new];
        _questionTextField.delegate = self;
        _questionTextField.leftView = self.leftView;
        [_questionTextField addTarget:self action:@selector(questionTextFieldChange) forControlEvents:UIControlEventEditingChanged];
        
        UIView *view = [UIView new];
        view.backgroundColor = CCRGBColor(187,187,187);
        [self.leftView addSubview:view];
        WS(ws)
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.bottom.mas_equalTo(ws.leftView);
            make.width.mas_equalTo(1);
        }];
    }
    return _questionTextField;
}

-(void)questionTextFieldChange {
    if(_questionTextField.text.length > 300) {
//        [self endEditing:YES];
        _questionTextField.text = [_questionTextField.text substringToIndex:300];
        
        InformationShowView *informationView = [[InformationShowView alloc] initWithLabel:@"输入限制在300个字符以内"];
        [APPDelegate.window addSubview:informationView];
        [informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f repeats:NO block:^(NSTimer * _Nonnull timer) {
            [informationView removeFromSuperview];
        }];
    }
}

-(UIButton *)leftView {
    if(!_leftView) {
        _leftView = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftView.frame = CGRectMake(0, 0, CCGetRealFromPt(90), CCGetRealFromPt(84));
        _leftView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _leftView.backgroundColor = CCClearColor;
        [_leftView setImage:[UIImage imageNamed:@"question_ic_lookon"] forState:UIControlStateNormal];
        [_leftView setImage:[UIImage imageNamed:@"question_ic_lookoff"] forState:UIControlStateSelected];
        [_leftView addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftView;
}

-(void)leftButtonClicked {
    BOOL selected = !_leftView.selected;
    _leftView.selected = selected;
    
    [self bringSubviewToFront:self.contentView];
    WS(ws)
    
    UIImageView *imageView = [UIImageView new];
    imageView.image = [UIImage imageNamed:@"question_bg_prompt"];
    self.contentView.clipsToBounds = NO;
    [self.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.contentView).mas_equalTo(CCGetRealFromPt(40));
        make.bottom.mas_equalTo(ws.contentView.mas_top).mas_equalTo(-CCGetRealFromPt(6));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(234), CCGetRealFromPt(84)));
    }];
    
    UILabel *label = [UILabel new];
    if(selected) {
        label.text = @"只看我的问答";
    } else {
        label.text = @"显示所有回答";
    }
    label.backgroundColor = CCClearColor;
    label.font = [UIFont systemFontOfSize:FontSize_26];
    label.textColor = [UIColor whiteColor];
    label.userInteractionEnabled = NO;
    label.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(imageView);
        make.top.mas_equalTo(imageView).offset(CCGetRealFromPt(22));
        make.bottom.mas_equalTo(imageView).offset(-CCGetRealFromPt(36));
    }];
    
    if(self.leftView.selected) {
        [self.keysArr removeAllObjects];
        for(NSString *encryptId in self.keysArrAll) {
            NSMutableArray *arr = [self.QADic objectForKey:encryptId];
            Dialogue *dialogue = [arr objectAtIndex:0];
            if([dialogue.fromuserid isEqualToString:dialogue.myViwerId]) {
                [self.keysArr addObject:encryptId];
            }
        }
    } else {
        self.keysArr = [self.keysArrAll mutableCopy];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.questionTableView reloadData];
        
        if (self.keysArr != nil && [self.keysArr count] != 0 ) {
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.keysArr.count-1) inSection:0];
            [self.questionTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
    [UIView animateWithDuration:3.0 delay:2.0 options:UIViewAnimationOptionCurveLinear animations:^{
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}

-(UIButton *)sendButton {
    if(!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.backgroundColor = CCRGBColor(255,102,51);
        _sendButton.layer.cornerRadius = CCGetRealFromPt(4);
        _sendButton.layer.masksToBounds = YES;
        _sendButton.layer.borderColor = [CCRGBColor(255,71,0) CGColor];
        _sendButton.layer.borderWidth = 1;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:CCRGBColor(255,255,255) forState:UIControlStateNormal];
        [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_sendButton addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

-(void)sendBtnClicked {
    if(!StrNotEmpty([_questionTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]])) {
        InformationShowView *informationView = [[InformationShowView alloc] initWithLabel:@"发送内容为空"];
        [APPDelegate.window addSubview:informationView];
        [informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f repeats:NO block:^(NSTimer * _Nonnull timer) {
            [informationView removeFromSuperview];
        }];
        return;
    }
    [self chatSendMessage];
    _questionTextField.text = nil;
    [_questionTextField resignFirstResponder];
}

-(UITableView *)questionTableView {
    if(!_questionTableView) {
        _questionTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _questionTableView.backgroundColor = [UIColor whiteColor];
        _questionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _questionTableView.delegate = self;
        _questionTableView.dataSource = self;
        _questionTableView.showsVerticalScrollIndicator = NO;
    }
    return _questionTableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.keysArr count];
}

-(NSMutableArray *)keysArr {
    if(!_keysArr) {
        _keysArr = [[NSMutableArray alloc] init];
    }
    return _keysArr;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CCGetRealFromPt(26);
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, CCGetRealFromPt(26))];
    view.backgroundColor = CCClearColor;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *encryptId = [self.keysArr objectAtIndex:indexPath.row];
    NSMutableArray *arr = [self.QADic objectForKey:encryptId];
    CGFloat height = [self heightForCellOfQuestion:arr] + 2;
    if(indexPath.row == 0) {
        height += 2;
    }
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellQuestionView";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    } else {
        for(UIView *cellView in cell.subviews){
            [cellView removeFromSuperview];
        }
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *encryptId = [self.keysArr objectAtIndex:indexPath.row];
    NSMutableArray *arr = [self.QADic objectForKey:encryptId];
    Dialogue *dialogue = [arr objectAtIndex:0];
    
    UIImageView *head = nil;
    if(StrNotEmpty(dialogue.useravatar)) {
        head = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bg_photo_nor"]];
    } else {
        head = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_img_photo_nor"]];
    }
    head.backgroundColor = CCClearColor;
    head.contentMode = UIViewContentModeScaleAspectFit;
    head.userInteractionEnabled = NO;
    [cell addSubview:head];
    if(indexPath.row == 0) {
        [head mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(cell).offset(CCGetRealFromPt(30));
//            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(30) + 2);
            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
        }];
    } else {
        [head mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(cell).offset(CCGetRealFromPt(30));
            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
        }];
    }
    
    NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] initWithString:dialogue.username];
    [textAttr addAttribute:NSForegroundColorAttributeName value:CCRGBColor(102,102,102) range:NSMakeRange(0, textAttr.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_24],NSParagraphStyleAttributeName:style};
    [textAttr addAttributes:dict range:NSMakeRange(0, textAttr.length)];
    
    CGSize textSize = [textAttr boundingRectWithSize:CGSizeMake(CCGetRealFromPt(500), CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.width = ceilf(textSize.width);
    textSize.height = ceilf(textSize.height);
    if(textSize.width > CCGetRealFromPt(500)) {
        textSize.width = CCGetRealFromPt(500);
    }
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = dialogue.username;
    titleLabel.backgroundColor = CCClearColor;
    titleLabel.numberOfLines = 1;
    titleLabel.font = [UIFont systemFontOfSize:FontSize_24];
    titleLabel.textColor = CCRGBColor(102,102,102);
    titleLabel.userInteractionEnabled = NO;
    [cell addSubview:titleLabel];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(head.mas_right).offset(CCGetRealFromPt(20));
        make.top.mas_equalTo(head);
//        make.top.mas_equalTo(cell).offset(CCGetRealFromPt(36));
        make.size.mas_equalTo(CGSizeMake(textSize.width * 1.2, CCGetRealFromPt(24) + 6));
    }];
    
    if(self.input) {
        UILabel *timeLabel = [UILabel new];
        NSString *timeStr = dialogue.time;
        NSInteger time = [timeStr integerValue];
        time = time < 0?0:time;
        NSInteger minute = time / 60;
        NSInteger second = time % 60;
        timeLabel.numberOfLines = 1;
        timeLabel.text = [NSString stringWithFormat:@"%d:%d",(int)minute,(int)second];
        timeLabel.backgroundColor = CCClearColor;
        timeLabel.font = [UIFont systemFontOfSize:FontSize_20];
        timeLabel.textColor = CCRGBColor(153,153,153);
        timeLabel.userInteractionEnabled = NO;
        [cell addSubview:timeLabel];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(titleLabel.mas_right).offset(CCGetRealFromPt(5));
            make.bottom.mas_equalTo(titleLabel).offset(-2);
            make.size.mas_equalTo(CGSizeMake(100, CCGetRealFromPt(20)));
        }];
    }
    
    float textMaxWidth = CCGetRealFromPt(590);
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:dialogue.msg];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style1 = [[NSMutableParagraphStyle alloc] init];
    style1.minimumLineHeight = CCGetRealFromPt(40);
    style1.maximumLineHeight = CCGetRealFromPt(40);
    style1.alignment = NSTextAlignmentLeft;
    style1.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict1 = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_28],NSParagraphStyleAttributeName:style1};
    [textAttri addAttributes:dict1 range:NSMakeRange(0, textAttri.length)];
    
    CGSize textSize1 = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize1.width = ceilf(textSize1.width);
    textSize1.height = ceilf(textSize1.height);
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = CCClearColor;
    contentLabel.textColor = CCRGBColor(51,51,51);
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.userInteractionEnabled = NO;
    contentLabel.attributedText = textAttri;
    [cell addSubview:contentLabel];
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(head.mas_right).offset(CCGetRealFromPt(20));
        make.top.mas_equalTo(head.mas_centerY).offset(-1);
        make.size.mas_equalTo(textSize1);
    }];
    
    UIView *viewBase = nil;
    for(int i = 1;i < [arr count];i++) {
        Dialogue *dialogue = [arr objectAtIndex:i];
        UIView *viewTop = [UIView new];
        viewTop.backgroundColor = CCRGBColor(232,232,232);
        [cell addSubview:viewTop];
        if(viewBase == nil) {
            [viewTop mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(cell).offset(CCGetRealFromPt(130));
                make.top.mas_equalTo(contentLabel.mas_bottom).offset(CCGetRealFromPt(16));
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(590), 1));
            }];
        } else {
            viewTop = viewBase;
        }
        
        float textMaxWidth = CCGetRealFromPt(550);
        NSString *text = [[dialogue.username stringByAppendingString:@": "] stringByAppendingString:dialogue.msg];
        NSMutableAttributedString *textAttri1 = [[NSMutableAttributedString alloc] initWithString:text];
        [textAttri1 addAttribute:NSForegroundColorAttributeName value:CCRGBColor(102,102,102) range:NSMakeRange(0, [dialogue.username stringByAppendingString:@": "].length)];
        NSInteger fromIndex = [dialogue.username stringByAppendingString:@": "].length;
        [textAttri1 addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51,51,51) range:NSMakeRange(fromIndex,text.length - fromIndex)];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = CCGetRealFromPt(36);
        style.maximumLineHeight = CCGetRealFromPt(36);
        style.lineBreakMode = NSLineBreakByCharWrapping;
        style.alignment = NSTextAlignmentLeft;
        NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],NSParagraphStyleAttributeName:style};
        [textAttri1 addAttributes:dict range:NSMakeRange(0, textAttri1.length)];
        
        CGSize textSize = [textAttri1 boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                   context:nil].size;
        textSize.width = ceilf(textSize.width);
        textSize.height = ceilf(textSize.height);// + 1;
//        textSize.height = textSize.height + 1;
        UIView *viewBg = [UIView new];
        viewBg.backgroundColor = CCRGBColor(250,250,250);
        [cell addSubview:viewBg];
        [viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(viewTop);
            make.top.mas_equalTo(viewTop.mas_bottom);
            make.height.mas_equalTo(textSize.height + CCGetRealFromPt(10) + CCGetRealFromPt(20));
        }];
        
        UILabel *contentLabel = [UILabel new];
        contentLabel.numberOfLines = 0;
        contentLabel.font = [UIFont systemFontOfSize:FontSize_24];
        contentLabel.backgroundColor = CCClearColor;
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.userInteractionEnabled = NO;
        contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        contentLabel.attributedText = textAttri1;
        [viewBg addSubview:contentLabel];
        
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(viewBg).offset(CCGetRealFromPt(20));
            make.centerY.mas_equalTo(viewBg).offset(-1);//.offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(textSize);
        }];
        
        UIView *viewBottom = [UIView new];
        viewBottom.backgroundColor = CCRGBColor(232,232,232);
        [cell addSubview:viewBottom];
        [viewBottom mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(viewTop);
            make.top.mas_equalTo(viewBg.mas_bottom);
            make.height.mas_equalTo(1);
        }];
        
        viewBase = viewBottom;
    }
    
    UIView *cellBottomLine = [UIView new];
    cellBottomLine.backgroundColor = CCRGBColor(232,232,232);
    [cell addSubview:cellBottomLine];
    [cellBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(cell);
        make.height.mas_equalTo(1);
    }];
    
    return cell;
}

-(CGFloat)heightForCellOfQuestion:(NSMutableArray *)array {
    CGFloat height = CCGetRealFromPt(130);
    
    Dialogue *dialogue = [array objectAtIndex:0];
    float textMaxWidth = CCGetRealFromPt(590);
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:dialogue.msg];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = CCGetRealFromPt(40);
    style.maximumLineHeight = CCGetRealFromPt(40);
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_28],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.width = ceilf(textSize.width);
    textSize.height = ceilf(textSize.height);
    if([array count] == 1) {
        if(textSize.height < CCGetRealFromPt(40)) {
            height = CCGetRealFromPt(130);
        } else {
            height = CCGetRealFromPt(70) + textSize.height + CCGetRealFromPt(20);
        };
    } else {
        height = CCGetRealFromPt(70) + CCGetRealFromPt(20) + textSize.height + CCGetRealFromPt(16);
        NSInteger baseHeight = -1;
        for(int i = 1;i < [array count];i++) {
            Dialogue *dialogue = [array objectAtIndex:i];
            if(baseHeight == -1) {
                height += 2;
            }
            
            float textMaxWidth = CCGetRealFromPt(550);
            NSString *text = [[dialogue.username stringByAppendingString:@": "] stringByAppendingString:dialogue.msg];
            NSMutableAttributedString *textAttri1 = [[NSMutableAttributedString alloc] initWithString:text];
            [textAttri1 addAttribute:NSForegroundColorAttributeName value:CCRGBColor(102,102,102) range:NSMakeRange(0, [dialogue.username stringByAppendingString:@": "].length)];
            NSInteger fromIndex = [dialogue.username stringByAppendingString:@": "].length + 1;
            [textAttri1 addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51,51,51) range:NSMakeRange(fromIndex,text.length - fromIndex)];
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.minimumLineHeight = CCGetRealFromPt(36);
            style.maximumLineHeight = CCGetRealFromPt(36);
            style.alignment = NSTextAlignmentLeft;
            style.lineBreakMode = NSLineBreakByCharWrapping;
            NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],NSParagraphStyleAttributeName:style};
            [textAttri1 addAttributes:dict range:NSMakeRange(0, textAttri1.length)];
            
            CGSize textSize = [textAttri1 boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                      context:nil].size;
            textSize.width = ceilf(textSize.width);
            textSize.height = ceilf(textSize.height);// + 1;
            height += (textSize.height + CCGetRealFromPt(10) + CCGetRealFromPt(20));
            height += 2;
            baseHeight = 0;
        }
    }

    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_questionTextField resignFirstResponder];
}

@end
