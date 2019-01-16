//
//  CCQuestionView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/6.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCQuestionView.h"
#import "QuestionTextField.h"
#import "Dialogue.h"
#import "UIImage+Extension.h"
#import "InformationShowView.h"
#import "UIImageView+WebCache.h"

@interface CCQuestionView()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

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
@property(nonatomic,strong)NSMutableArray               *keysArrAll;

@property(nonatomic,strong)NSMutableDictionary          *newQADic;
@property(nonatomic,strong)NSMutableArray               *newKeysArr;

@property(nonatomic,copy)  QuestionBlock                block;
@property(nonatomic,assign)BOOL                         input;
@property(nonatomic,strong)InformationShowView          *informationView;
@property(nonatomic,strong)UIView *imageView;
//
@end

@implementation CCQuestionView




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

-(NSMutableArray *)newKeysArr {
    if(!_newKeysArr) {
        _newKeysArr = [[NSMutableArray alloc] init];
    }
    return _newKeysArr;
}

-(NSMutableDictionary *)newQADic {
    if(!_newQADic) {
        _newQADic = [[NSMutableDictionary alloc] init];
    }
    return _newQADic;
}

-(void)reloadQADic:(NSMutableDictionary *)QADic keysArrAll:(NSMutableArray *)keysArrAll {
    self.QADic = [QADic mutableCopy];
    self.keysArrAll = [keysArrAll mutableCopy];
    [self.newKeysArr removeAllObjects];
    [self.newQADic removeAllObjects];

    int keysArrCount = (int)[self.keysArrAll count];
    for(int i = 0;i <keysArrCount ;i++) {
        NSString *encryptId = [self.keysArrAll objectAtIndex:i];
        NSMutableArray *arr = [self.QADic objectForKey:encryptId];
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        for(int j = 0;j < [arr count];j++) {
            Dialogue *dialogue = [arr objectAtIndex:j];
            if(j == 0 && ![newArr containsObject:dialogue]) {
                if(dialogue.dataType == NS_CONTENT_TYPE_QA_QUESTION &&
                   ![self.newKeysArr containsObject:encryptId] &&
                   ([dialogue.fromuserid isEqualToString:dialogue.myViwerId] ||
                    dialogue.isPublish == YES)) {
                       if(self.leftView.selected) {
                           if([dialogue.fromuserid isEqualToString:dialogue.myViwerId]) {
                               [self.newKeysArr addObject:encryptId];
                               [newArr addObject:dialogue];
                               [self.newQADic setObject:newArr forKey:encryptId];
                           }
                       } else {
                           [self.newKeysArr addObject:encryptId];
                           [newArr addObject:dialogue];
                           [self.newQADic setObject:newArr forKey:encryptId];
                       }
                   }
            } else if(![newArr containsObject:dialogue] && [newArr count] > 0) {
                Dialogue *firstDialogue = [arr objectAtIndex:0];
                if((dialogue.isPrivate == 0 || (dialogue.isPrivate == 1 && [firstDialogue.fromuserid isEqualToString:dialogue.myViwerId])) && dialogue.dataType == NS_CONTENT_TYPE_QA_ANSWER) {
                    NSMutableArray *newArr = [self.newQADic objectForKey:encryptId];
                    if (newArr != nil) {
                        [newArr addObject:dialogue];
                    }
                }
            }
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.questionTableView reloadData];
        if (self.newKeysArr != nil && [self.newKeysArr count] != 0 ) {
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.newKeysArr.count-1) inSection:0];
            [self.questionTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

-(void)dealloc {
    [self removeObserver];
}

-(void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    if(self.input) {
        [self addSubview:self.contentView];
        NSInteger tabheight = IS_IPHONE_X?178:110;
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.right.and.left.mas_equalTo(self);
            make.height.mas_equalTo(CCGetRealFromPt(tabheight));
        }];

        [self addSubview:self.questionTableView];
        [_questionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.left.mas_equalTo(self);
            make.bottom.mas_equalTo(self.contentView.mas_top);
        }];
        UIView * line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithHexString:@"#e8e8e8" alpha:1.0f];
        [self.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];

        [self.contentView addSubview:self.questionTextField];
        [_questionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(CCGetRealFromPt(10));
            make.left.mas_equalTo(self.contentView).offset(CCGetRealFromPt(24));
            make.right.equalTo(self.contentView).offset(-CCGetRealFromPt(24));
            make.height.mas_equalTo(CCGetRealFromPt(84));
        }];

    } else {
        [self addSubview:self.questionTableView];
        [_questionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
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
    //    CGFloat x = _keyboardRect.size.width;
    //    NSLog(@"键盘高度是  %d",(int)y);
    //    NSLog(@"键盘宽度是  %d",(int)x);
    if ([self.questionTextField isFirstResponder]) {

        [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.and.left.mas_equalTo(self);
            make.bottom.mas_equalTo(self).offset(-y);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];

        [_questionTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.left.mas_equalTo(self);
            make.bottom.mas_equalTo(self.contentView.mas_top);
        }];

        [UIView animateWithDuration:0.25f animations:^{
                    [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (self.newKeysArr != nil && [self.newKeysArr count] != 0 ) {
                NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.newKeysArr.count - 1) inSection:0];
                [self.questionTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }];

    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self hideKeyboard];
}

- (void)hideKeyboard {
    NSInteger tabheight = IS_IPHONE_X?178:110;
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.and.left.and.bottom.mas_equalTo(self);
        make.height.mas_equalTo(CCGetRealFromPt(tabheight));
    }];

    [_questionTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.and.left.mas_equalTo(self);
        make.bottom.mas_equalTo(self.contentView.mas_top);
    }];

    [UIView animateWithDuration:0.25f animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = CCRGBColor(255,255,255);

    }
    return _contentView;
}

-(QuestionTextField *)questionTextField {
    if(!_questionTextField) {
        _questionTextField = [QuestionTextField new];
        _questionTextField.delegate = self;
        _questionTextField.leftView = self.leftView;
        _questionTextField.layer.cornerRadius = CCGetRealFromPt(42);
        [_questionTextField addTarget:self action:@selector(questionTextFieldChange) forControlEvents:UIControlEventEditingChanged];
    }
    return _questionTextField;
}

-(void)questionTextFieldChange {
    if(_questionTextField.text.length > 300) {
        //        [self endEditing:YES];
        _questionTextField.text = [_questionTextField.text substringToIndex:300];
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:@"输入限制在300个字符以内"];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];

        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
    }
}

-(void)removeInformationView {
    [_informationView removeFromSuperview];
    _informationView = nil;
}

-(UIButton *)leftView {
    if(!_leftView) {
        _leftView = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftView.frame = CGRectMake(0, 0, CCGetRealFromPt(90), CCGetRealFromPt(84));
        _leftView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _leftView.backgroundColor = CCClearColor;
        [_leftView setImage:[UIImage imageNamed:@"question_ic_lookoff"] forState:UIControlStateNormal];
        [_leftView setImage:[UIImage imageNamed:@"question_ic_lookon"] forState:UIControlStateSelected];
        [_leftView addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftView;
}

-(void)leftButtonClicked {
    BOOL selected = !_leftView.selected;
    _leftView.selected = selected;
    _leftView.userInteractionEnabled = NO;

    [self bringSubviewToFront:self.contentView];

     self.imageView = [[UIView alloc] init];
    self.imageView.backgroundColor = [UIColor colorWithHexString:@"#1e1f21" alpha:0.6f];
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.mas_equalTo(self.contentView.mas_top).mas_equalTo(-CCGetRealFromPt(6));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(234), CCGetRealFromPt(60)));
    }];
    [self.imageView layoutIfNeeded];
    self.imageView.layer.cornerRadius = CCGetRealFromPt(30);

    UILabel *label = [UILabel new];
    if(selected) {
        label.text = @"查看我的问答";
    } else {
        label.text = @"查看所有回答";
    }
    label.backgroundColor = CCClearColor;
    label.font = [UIFont systemFontOfSize:FontSize_26];
    label.textColor = [UIColor whiteColor];
    label.userInteractionEnabled = NO;
    label.textAlignment = NSTextAlignmentCenter;
    [self.imageView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.imageView);
    }];

    [self reloadQADic:self.QADic keysArrAll:self.keysArrAll];

    [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.imageView removeFromSuperview];
        self.leftView.userInteractionEnabled = YES;
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
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:@"发送内容为空"];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];

        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
        return;
    }
    [self chatSendMessage];
    _questionTextField.text = nil;
    [_questionTextField resignFirstResponder];
}
//
-(UITableView *)questionTableView {
    if(!_questionTableView) {
        _questionTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _questionTableView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];
        _questionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _questionTableView.delegate = self;
        _questionTableView.dataSource = self;
        _questionTableView.showsVerticalScrollIndicator = NO;
        _questionTableView.estimatedRowHeight = 0;
        _questionTableView.estimatedSectionHeaderHeight = 0;
        _questionTableView.estimatedSectionFooterHeight = 0;
        if (@available(iOS 11.0, *)) {
            _questionTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _questionTableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.newKeysArr count];
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
    NSString *encryptId = [self.newKeysArr objectAtIndex:indexPath.row];
    NSMutableArray *arr = [self.newQADic objectForKey:encryptId];
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
    [cell setBackgroundColor:[UIColor whiteColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSString *encryptId = [self.newKeysArr objectAtIndex:indexPath.row];
    NSMutableArray *arr = [self.newQADic objectForKey:encryptId];
    Dialogue *dialogue = [arr objectAtIndex:0];

//    NSArray * useravatarArr = @[@"用户1",@"用户2",@"用户3",@"用户4",@"用户5",@"主持",@"讲师",@"助教"];
//    int r = arc4random() % [useravatarArr count];
    UIImageView *head = [[UIImageView alloc] init];
    NSURL *url = [NSURL URLWithString:dialogue.useravatar];
    [head sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"chatHead_student"]];
//    if(StrNotEmpty(dialogue.useravatar)) {
//        head = [[UIImageView alloc] initWithImage:[UIImage ]];
//    } else {
//        head = [[UIImageView alloc] initWithImage:[UIImage imageNamed:useravatarArr[r]]];
//    }
    
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
    [textAttr addAttribute:NSForegroundColorAttributeName value:CCRGBColor(248,129,25) range:NSMakeRange(0, textAttr.length)];

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
    BOOL fromSelf = [dialogue.fromuserid isEqualToString:dialogue.myViwerId];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = dialogue.username;
    titleLabel.backgroundColor = CCClearColor;
    titleLabel.numberOfLines = 1;
    titleLabel.font = [UIFont systemFontOfSize:FontSize_28];
    if (fromSelf) {
        titleLabel.textColor = [UIColor colorWithHexString:@"#ff6633" alpha:1.0f];
    }else {
        titleLabel.textColor = CCRGBColor(102,102,102);
    }
    titleLabel.userInteractionEnabled = NO;
    [cell addSubview:titleLabel];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(head.mas_right).offset(CCGetRealFromPt(20));
        make.top.mas_equalTo(head);
        make.size.mas_equalTo(CGSizeMake(textSize.width * 1.2, CCGetRealFromPt(24) + 6));
    }];

//    if(self.input) {
        UILabel *timeLabel = [UILabel new];
        timeLabel.numberOfLines = 1;
        NSString * startTime = GetFromUserDefaults(LIVE_STARTTIME);
    if (!self.input) {
        startTime = [startTime substringToIndex:19];
    }
//    NSLog(@"userName:%@, time = %@", dialogue.username, startTime);
        NSInteger timea = [NSString timeSwitchTimestamp:startTime andFormatter:@"yyyy-MM-dd HH:mm:ss"];
        timea += [dialogue.time integerValue];
        timeLabel.text = [NSString timestampSwitchTime:timea andFormatter:@"HH:mm"];
    //todo 问答禁言
    if ([dialogue.time integerValue] == -1) {
        NSLog(@"您已被禁言");
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        NSDate *datenow = [NSDate date];
        timeLabel.text = [formatter stringFromDate:datenow];
    }
//    NSLog(@"最终显示时间:%@, 接口返回的持续时间 %@", timeLabel.text, dialogue.time);
        timeLabel.backgroundColor = CCClearColor;
        timeLabel.font = [UIFont systemFontOfSize:FontSize_20];
        timeLabel.textColor = CCRGBColor(153,153,153);
        timeLabel.userInteractionEnabled = NO;
        [cell addSubview:timeLabel];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(cell);
            make.bottom.mas_equalTo(titleLabel).offset(-2);
            make.size.mas_equalTo(CGSizeMake(50, CCGetRealFromPt(20)));
        }];
//    }

    float textMaxWidth = CCGetRealFromPt(590);
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:dialogue.msg];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51,51,51) range:NSMakeRange(0, textAttri.length)];
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
    
    if (arr.count > 1) {
            UIView * line =[[UIView alloc] init];
            line.backgroundColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.0f];
            [cell addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(contentLabel.mas_bottom).offset(13);
                make.left.mas_equalTo(cell).offset(CCGetRealFromPt(130));
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(590), 1));
            }];
    }
    
    UIView *viewBase = nil;
    for(int i = 1;i < [arr count];i++) {
        
        Dialogue *dialogue = [arr objectAtIndex:i];
        UIView *viewTop = [UIView new];
        viewTop.backgroundColor = CCRGBColor(255,255,255);
        [cell addSubview:viewTop];
        if(viewBase == nil) {
            [viewTop mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(cell).offset(CCGetRealFromPt(130));
                make.top.mas_equalTo(contentLabel.mas_bottom).offset(CCGetRealFromPt(16)+10);
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
        //找出特定字符在整个字符串中的位置
        NSRange redRange = NSMakeRange([[textAttri1 string] rangeOfString:dialogue.username].location, [[textAttri1 string] rangeOfString:dialogue.username].length+1);
        //修改特定字符的颜色
        [textAttri1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#12ad1a" alpha:1.0f] range:redRange];
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
        UIView *viewBg = [UIView new];
        viewBg.backgroundColor = CCRGBColor(255,255,255);
        [cell addSubview:viewBg];
        [viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(viewTop);
            make.top.mas_equalTo(viewTop.mas_bottom);
            make.height.mas_equalTo(textSize.height + CCGetRealFromPt(10) + CCGetRealFromPt(20)-10);
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
            make.left.mas_equalTo(viewBg);
            make.centerY.mas_equalTo(viewBg).offset(-1);//.offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(textSize);
        }];
        UIView *viewBottom = [UIView new];
        viewBottom.backgroundColor = [UIColor clearColor];
        [cell addSubview:viewBottom];
        [viewBottom mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(viewTop);
            make.top.mas_equalTo(viewBg.mas_bottom);
            make.height.mas_equalTo(1);
        }];

        viewBase = viewBottom;
    }
    UIView *cellBottomLine = [UIView new];
    cellBottomLine.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];;
    [cell addSubview:cellBottomLine];
    [cellBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(cell);
        make.height.mas_equalTo(5);
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
            height = CCGetRealFromPt(130)+5;
        } else {
            height = CCGetRealFromPt(70) + textSize.height + CCGetRealFromPt(20)+5;
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
            height += (textSize.height + CCGetRealFromPt(10));
            height += 2;
            baseHeight = 0;
        }
    }

    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_questionTextField resignFirstResponder];
}

//#pragma mark - 将某个时间转化成 时间戳
//- (NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format{
//
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    [formatter setDateFormat:format]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
//    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
//    [formatter setTimeZone:timeZone];
//    NSDate* date = [formatter dateFromString:formatTime]; //------------将字符串按formatter转成nsdate
//    //时间转时间戳的方法:
//    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
//    return timeSp;
//
//}
//
//#pragma mark - 将某个时间戳转化成 时间
//- (NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format{
//
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    [formatter setDateFormat:format]; // （@"YYYY-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
//    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
//    [formatter setTimeZone:timeZone];
//    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
//    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
//    return confromTimespStr;
//
//}



@end
