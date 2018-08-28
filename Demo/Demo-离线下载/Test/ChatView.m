//
//  ChatView.m
//  NewCCDemo
//
//  Created by cc on 2016/12/29.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "ChatView.h"
#import "CustomTextField.h"
#import "Dialogue.h"
#import "Utility.h"
#import "UIImage+Extension.h"
#import "CCPrivateChatView.h"
#import "InformationShowView.h"

@interface ChatView()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,strong)UITableView                  *publicTableView;
@property(nonatomic,copy)  NSString                     *antename;
@property(nonatomic,copy)  NSString                     *anteid;
@property(nonatomic,strong)CustomTextField              *chatTextField;
@property(nonatomic,strong)UIButton                     *sendButton;
@property(nonatomic,strong)UIView                       *contentView;
@property(nonatomic,strong)UIButton                     *rightView;
@property(nonatomic,strong)UIView                       *emojiView;
@property(nonatomic,assign)CGRect                       keyboardRect;

@property(nonatomic,strong)UIButton                     *privateChatBtn;
@property(nonatomic,strong)CCPrivateChatView            *ccPrivateChatView;

@property(nonatomic,strong)NSMutableArray               *publicChatArray;
@property(nonatomic,copy)  PublicChatBlock              publicChatBlock;
@property(nonatomic,copy)  PrivateChatBlock             privateChatBlock;
@property(nonatomic,strong)NSMutableDictionary          *privateChatDict;
@property(nonatomic,assign)BOOL                         input;

@end

@implementation ChatView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithPublicChatBlock:(PublicChatBlock)publicChatBlock PrivateChatBlock:(PrivateChatBlock)privateChatBlock input:(BOOL)input{
    self = [super init];
    if(self) {
        self.publicChatBlock    = publicChatBlock;
        self.privateChatBlock   = privateChatBlock;
        self.input              = input;
        [self initUI];
        if(self.input) {
            [self addObserver];
        }
    }
    return self;
}

- (void)reloadPrivateChatDict:(NSMutableDictionary *)dict anteName:anteName anteid:anteid {
    [self.ccPrivateChatView reloadDict:[dict mutableCopy] anteName:anteName anteid:anteid];
}

- (void)reloadPublicChatArray:(NSMutableArray *)array {
//    NSLog(@"array = %@",array);
    self.publicChatArray = [array mutableCopy];
//    NSLog(@"self.publicChatArray = %@",self.publicChatArray);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.publicTableView reloadData];
        if (self.publicChatArray != nil && [self.publicChatArray count] != 0 ) {
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.publicChatArray.count-1) inSection:0];
            [self.publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
        
        [self addSubview:self.publicTableView];
        [_publicTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.left.mas_equalTo(ws);
            make.bottom.mas_equalTo(ws.contentView.mas_top);
        }];
        
        [self addSubview:self.privateChatBtn];
        [_privateChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(18));
            make.bottom.mas_equalTo(ws).offset(-CCGetRealFromPt(314));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(56), CCGetRealFromPt(56)));
        }];
        
        [self addSubview:self.ccPrivateChatView];
        [self.ccPrivateChatView setCheckDotBlock1:^(BOOL flag) {
            ws.privateChatBtn.selected = flag;
        }];
        
        [_ccPrivateChatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws);
            make.height.mas_equalTo(CCGetRealFromPt(542));
            make.bottom.mas_equalTo(ws).offset(CCGetRealFromPt(542));
        }];
        
        [self.contentView addSubview:self.chatTextField];
        [_chatTextField mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [self addSubview:self.publicTableView];
        [_publicTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws);
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self chatSendMessage];
    return YES;
}

-(void)chatSendMessage {
    NSString *str = _chatTextField.text;
    if(str == nil || str.length == 0) {
        return;
    }
    
    if(self.publicChatBlock) {
        self.publicChatBlock(str);
    }
    
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(privateChat:)
                                                 name:@"private_Chat"
                                               object:nil];
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"private_Chat"
                                                  object:nil];
}

- (void) privateChat:(NSNotification*) notification
{
    NSDictionary *dic = [notification object];
    
    if(self.privateChatBlock) {
        self.privateChatBlock(dic[@"anteid"],dic[@"str"]);
    }
}

#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.chatTextField isFirstResponder]) {
        return;
    }
    
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
    CGFloat x = _keyboardRect.size.width;
    NSLog(@"键盘高度是  %d",(int)y);
    NSLog(@"键盘宽度是  %d",(int)x);
    if ([self.chatTextField isFirstResponder]) {
        WS(ws)
        [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.and.left.mas_equalTo(ws);
            make.bottom.mas_equalTo(ws).offset(-y);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        
        [_publicTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.left.mas_equalTo(ws);
            make.bottom.mas_equalTo(ws.contentView.mas_top);
        }];
        
        [UIView animateWithDuration:0.25f animations:^{
            [ws layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (ws.publicChatArray != nil && [ws.publicChatArray count] != 0 ) {
                NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(ws.publicChatArray.count - 1) inSection:0];
                [_publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self hideKeyboard];
}

-(void)hideKeyboard {
    WS(ws)
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.and.left.and.bottom.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(110));
    }];
    
    [_publicTableView mas_updateConstraints:^(MASConstraintMaker *make) {
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

-(CustomTextField *)chatTextField {
    if(!_chatTextField) {
        _chatTextField = [CustomTextField new];
        _chatTextField.delegate = self;
        [_chatTextField addTarget:self action:@selector(chatTextFieldChange) forControlEvents:UIControlEventEditingChanged];
//        _chatTextField.text = @"输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制在输入限制";
        _chatTextField.rightView = self.rightView;
    }
    return _chatTextField;
}

-(void)chatTextFieldChange {
    if(_chatTextField.text.length > 300) {
//        [self endEditing:YES];
        _chatTextField.text = [_chatTextField.text substringToIndex:300];
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

-(UIButton *)rightView {
    if(!_rightView) {
        _rightView = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightView.frame = CGRectMake(0, 0, CCGetRealFromPt(48), CCGetRealFromPt(48));
        _rightView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightView.backgroundColor = CCClearColor;
        [_rightView setImage:[UIImage imageNamed:@"chat_ic_face_nor"] forState:UIControlStateNormal];
        [_rightView setImage:[UIImage imageNamed:@"chat_ic_face_hov"] forState:UIControlStateSelected];
        [_rightView addTarget:self action:@selector(faceBoardClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightView;
}

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
    if(!StrNotEmpty([_chatTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]])) {
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
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}

-(UITableView *)publicTableView {
    if(!_publicTableView) {
        _publicTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _publicTableView.backgroundColor = [UIColor whiteColor];
        _publicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _publicTableView.delegate = self;
        _publicTableView.dataSource = self;
        _publicTableView.showsVerticalScrollIndicator = NO;
        _publicTableView.estimatedRowHeight = 0;
        _publicTableView.estimatedSectionHeaderHeight = 0;
        _publicTableView.estimatedSectionFooterHeight = 0;
    }
    return _publicTableView;
}

-(NSMutableArray *)publicChatArray {
    if(!_publicChatArray) {
        _publicChatArray = [[NSMutableArray alloc] init];
        
//        Dialogue *privateDialogue1 = [Dialogue new];
//        privateDialogue1.msg = @"Hello，美女，我们约在周二7月19日下午，你…Hello，美女，我们约在周二7月19日下午，你…Hello，美女，我们约在周二7月19日下午，你…";
//        privateDialogue1.head =
//        privateDialogue1.fromusername = @"张三";
//        privateDialogue1.fromuserid = @"12345";
//        privateDialogue1.myViwerId = @"12345";
//
//        Dialogue *privateDialogue2 = [Dialogue new];
//        privateDialogue2.msg = @"Hello，美女，我们约在周二7月19日下午，你…Hello，美女，我们约在周二7月19日下午，你…Hello，美女，我们约在周二7月19日下午，你…";
//        privateDialogue2.head = @"chat_img_photo_nor";
//        privateDialogue2.fromusername = @"张三";
//        privateDialogue2.fromuserid = @"54321";
//        privateDialogue2.myViwerId = @"12345";
//
//        [_tableArray addObject:privateDialogue1];
//        [_tableArray addObject:privateDialogue2];
    }
    return _publicChatArray;
}

-(UIView *)emojiView {
    if(!_emojiView) {
        
        if(_keyboardRect.size.width == 0 || _keyboardRect.size.height ==0) {
            _keyboardRect = CGRectMake(0, 0, 414, 271);
        }
        _emojiView = [[UIView alloc] initWithFrame:_keyboardRect];
        _emojiView.backgroundColor = CCRGBColor(242,239,237);
        
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
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.publicChatArray count];
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
    Dialogue *dialogue = [self.publicChatArray objectAtIndex:indexPath.row];
    return [self heightForCellOfPublic:dialogue.msg];
}

-(void)headBtnClicked:(UIButton *)sender {
    WS(ws)
    //TODO
    [_ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(542));
    }];
    
    [self.ccPrivateChatView selectByClickHead:[self.publicChatArray objectAtIndex:sender.tag]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellChatView";
    
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
    
    Dialogue *dialogue = [self.publicChatArray objectAtIndex:indexPath.row];
    BOOL fromSelf = [dialogue.fromuserid isEqualToString:dialogue.myViwerId];
    
    UIButton *headBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    headBtn.tag = indexPath.row;
    if(!fromSelf && self.input) {
        [headBtn addTarget:self action:@selector(headBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    if(StrNotEmpty(dialogue.useravatar)) {
        [headBtn setBackgroundImage:[UIImage imageNamed:@"chat_bg_photo_nor"] forState:UIControlStateNormal];
    } else {
        [headBtn setBackgroundImage:[UIImage imageNamed:@"chat_img_photo_nor"] forState:UIControlStateNormal];
    }
    headBtn.backgroundColor = CCClearColor;
    headBtn.contentMode = UIViewContentModeScaleAspectFit;
    [cell addSubview:headBtn];
    if(fromSelf) {
        [headBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(cell).offset(-CCGetRealFromPt(30));
//            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(20));
            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
        }];
    } else {
        [headBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(cell).offset(CCGetRealFromPt(30));
//            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(20));
            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
        }];
    }
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.backgroundColor = CCClearColor;
    [titleButton setTitle:dialogue.fromusername forState:UIControlStateNormal];
    [titleButton setTitleColor:CCRGBColor(102,102,102) forState:UIControlStateNormal];
    [titleButton.titleLabel setFont:[UIFont systemFontOfSize:FontSize_24]];
    titleButton.tag = indexPath.row;
    if(!fromSelf && self.input) {
        [titleButton addTarget:self action:@selector(headBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell addSubview:titleButton];
    if(fromSelf) {
        titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(headBtn.mas_left).offset(-CCGetRealFromPt(32));
//            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(26));
            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(36));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(490),CCGetRealFromPt(24)));
        }];
    } else {
        titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(headBtn.mas_right).offset(CCGetRealFromPt(32));
//            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(26));
            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(36));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(490),CCGetRealFromPt(24)));
        }];
    }

    float textMaxWidth = CCGetRealFromPt(438);
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:dialogue.msg y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.minimumLineHeight = CCGetRealFromPt(36);
    style.maximumLineHeight = CCGetRealFromPt(60);
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil].size;
    textSize.width = ceilf(textSize.width);
    textSize.height = ceilf(textSize.height);// + 1;
    UIImage *image = [UIImage imageNamed:@"chat_bubble_self_widehalf_height60px"];
    NSLog(@"textSize = %@",NSStringFromCGSize(textSize));
    UIButton *bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cell addSubview:bgButton];
    CGFloat height = textSize.height + CCGetRealFromPt(18) * 2;
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = CCClearColor;
    contentLabel.textColor = CCRGBColor(51,51,51);
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.userInteractionEnabled = NO;
    contentLabel.attributedText = textAttri;
    [bgButton addSubview:contentLabel];

    float width = textSize.width + CCGetRealFromPt(30) + CCGetRealFromPt(20);
    BOOL widthSmall = NO;
    if(width < image.size.width) {
        width = image.size.width;
        widthSmall = YES;
    }
    if(height < CCGetRealFromPt(80)) {
        if(fromSelf) {
            [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(headBtn.mas_left).offset(-CCGetRealFromPt(22));
                make.top.mas_equalTo(headBtn.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(width, CCGetRealFromPt(80)));
            }];
        } else {
            [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(headBtn.mas_right).offset(CCGetRealFromPt(22));
                make.top.mas_equalTo(headBtn.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(width, CCGetRealFromPt(80)));
            }];
        }
    } else {
        if(fromSelf) {
            [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(headBtn.mas_left).offset(-CCGetRealFromPt(22));
                make.top.mas_equalTo(headBtn.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(width, textSize.height + CCGetRealFromPt(18) * 2));
            }];
        } else {
            [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(headBtn.mas_right).offset(CCGetRealFromPt(22));
                make.top.mas_equalTo(headBtn.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(width, textSize.height + CCGetRealFromPt(18) * 2));
            }];
        }
    };
    
    UIImage *bgImage = nil;
    if(fromSelf) {
        bgImage = [UIImage resizableImageWithName:@"chat_bubble_self_widehalf_height60px"];
        if(widthSmall) {
            [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(bgButton.mas_centerX).offset(-CCGetRealFromPt(6));
                make.centerY.mas_equalTo(bgButton).offset(-1);
                make.size.mas_equalTo(CGSizeMake(textSize.width, textSize.height + 1));
            }];
        } else {
            [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(bgButton).offset(CCGetRealFromPt(20));
                make.centerY.mas_equalTo(bgButton).offset(-1);
                make.size.mas_equalTo(CGSizeMake(textSize.width, textSize.height + 1));
            }];
        }
    } else {
        bgImage = [UIImage resizableImageWithName:@"chat_bubble_them_widehalf_height60px"];
        if(widthSmall) {
            [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(bgButton.mas_centerX).offset(CCGetRealFromPt(6));
                make.centerY.mas_equalTo(bgButton).offset(-1);
                make.size.mas_equalTo(CGSizeMake(textSize.width, textSize.height + 1));
            }];
        } else {
            [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(bgButton).offset(CCGetRealFromPt(30));
                make.centerY.mas_equalTo(bgButton).offset(-1);
                make.size.mas_equalTo(CGSizeMake(textSize.width, textSize.height + 1));
            }];
        }
    }
    bgButton.enabled = NO;
    [bgButton setBackgroundImage:bgImage forState:UIControlStateDisabled];
    [bgButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    //bgButton.enabled = NO;
    return cell;
}

-(CGFloat)heightForCellOfPublic:(NSString *)msg {
//    CGFloat height = CCGetRealFromPt(140);
    CGFloat height = CCGetRealFromPt(150);
    
    float textMaxWidth = CCGetRealFromPt(438);
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:msg];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = CCGetRealFromPt(36);
    style.maximumLineHeight = CCGetRealFromPt(60);
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.width = ceilf(textSize.width);
    textSize.height = ceilf(textSize.height);// + 1;
    CGFloat heightText = textSize.height + CCGetRealFromPt(18) * 2;

    if(heightText < CCGetRealFromPt(80)) {
//        height = CCGetRealFromPt(140);
        height = CCGetRealFromPt(150);
    } else {
//        height = CCGetRealFromPt(60) + heightText;
        height = CCGetRealFromPt(70) + heightText;
    };
    return height;
}

-(NSMutableDictionary *)privateChatDict {
    if(!_privateChatDict) {
        _privateChatDict = [[NSMutableDictionary alloc] init];
    }
    return _privateChatDict;
}

-(UIButton *)privateChatBtn {
    if(!_privateChatBtn) {
        _privateChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_privateChatBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_privateChatBtn setBackgroundImage:[UIImage imageNamed:@"video_ic_news_nor"] forState:UIControlStateNormal];
        [_privateChatBtn setBackgroundImage:[UIImage imageNamed:@"video_ic_newsmsg_nor"] forState:UIControlStateSelected];
        [_privateChatBtn addTarget:self action:@selector(privateChatBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _privateChatBtn;
}

-(void)privateChatBtnClicked {
    WS(ws)
    [_ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(542));
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [ws layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

-(CCPrivateChatView *)ccPrivateChatView {
    if(!_ccPrivateChatView) {
        WS(ws)
        _ccPrivateChatView = [[CCPrivateChatView alloc] initWithCloseBlock:^{
            [ws.ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.mas_equalTo(ws);
                make.height.mas_equalTo(CCGetRealFromPt(542));
                make.bottom.mas_equalTo(ws).offset(CCGetRealFromPt(542));
            }];
            
            [UIView animateWithDuration:0.25f animations:^{
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                if(ws.ccPrivateChatView.privateChatViewForOne) {
                    [ws.ccPrivateChatView.privateChatViewForOne removeFromSuperview];
                    ws.ccPrivateChatView.privateChatViewForOne = nil;
                }
            }];
        } isResponseBlock:^(CGFloat y) {
            NSLog(@"PushViewController isResponseBlock y = %f",y);
            [_ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.mas_equalTo(ws);
                make.height.mas_equalTo(CCGetRealFromPt(542));
                make.bottom.mas_equalTo(ws).mas_offset(-y);
            }];
            
            [UIView animateWithDuration:0.25f animations:^{
                [ws layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        } isNotResponseBlock:^{
            [_ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.mas_equalTo(ws);
                make.height.mas_equalTo(CCGetRealFromPt(542));
                make.bottom.mas_equalTo(ws);
            }];
            
            [UIView animateWithDuration:0.25f animations:^{
                [ws layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        }  dataPrivateDic:[self.privateChatDict copy] isScreenLandScape:NO];
    }
    return _ccPrivateChatView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_chatTextField resignFirstResponder];
    [_ccPrivateChatView.privateChatViewForOne.chatTextField resignFirstResponder];
    WS(ws)
    
    [_ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(542));
        make.bottom.mas_equalTo(ws).offset(CCGetRealFromPt(542));
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(ws.ccPrivateChatView.privateChatViewForOne) {
            [ws.ccPrivateChatView.privateChatViewForOne removeFromSuperview];
            ws.ccPrivateChatView.privateChatViewForOne = nil;
        }
    }];
}

- (void)addPublicChatArray:(NSMutableArray *)array {
    if([array count] == 0) return;
    
    NSInteger preIndex = [self.publicChatArray count];
    [self.publicChatArray addObjectsFromArray:[array mutableCopy]];
    NSInteger bacIndex = [self.publicChatArray count];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for(NSInteger row = preIndex + 1;row <= bacIndex;row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(row-1) inSection:0];
        [indexPaths addObject: indexPath];
    }
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.publicTableView beginUpdates];
        [ws.publicTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [ws.publicTableView endUpdates];
        
        if (indexPaths != nil && [indexPaths count] != 0 ) {
            [ws.publicTableView scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    });
}





@end
