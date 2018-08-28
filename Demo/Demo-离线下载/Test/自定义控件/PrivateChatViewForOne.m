//
//  CCPrivateChatView.m
//  NewCCDemo
//
//  Created by cc on 2016/12/7.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "PrivateChatViewForOne.h"
//#import "PrivateDialogue.h"
#import "Dialogue.h"
#import "UIImage+Extension.h"
#import "Utility.h"
//#import "CCPush/CCPushUtil.h"
#import "InformationShowView.h"

@interface PrivateChatViewForOne()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,strong)UIView                   *topView;
@property(nonatomic,strong)UILabel                  *titleLabel;
@property(nonatomic,strong)UIButton                 *closeButton;
@property(nonatomic,strong)UIButton                 *returnButton;
@property(nonatomic,strong)UITableView              *tableView;

@property(nonatomic,strong)UIButton                 *sendButton;
@property(nonatomic,strong)UIView                   *contentView;
@property(nonatomic,strong)UIButton                 *rightView;

@property(nonatomic,strong)UIView                   *emojiView;
@property(nonatomic,assign)CGRect                   keyboardRect;
@property(nonatomic,copy)  NSString                 *viewerId;
@property(nonatomic,copy)  NSString                 *anteid;
@property(nonatomic,copy)  NSString                 *anteName;

@property(nonatomic,copy)  CloseBtnClicked          closeBlock;
@property(nonatomic,copy)  ChatIcBtnClicked         chatBlock;
@property(nonatomic,copy)  IsResponseBlock          isResponseBlock;
@property(nonatomic,copy)  IsNotResponseBlock       isNotResponseBlock;
@property(nonatomic,strong)NSMutableArray           *dataArrayForOne;

@property(nonatomic,assign)Boolean                  isScreenLandScape;
@property(nonatomic, copy)UIView                    *bottomLine;
@property(nonatomic, copy)UIView                    *topLine;

@end

@implementation PrivateChatViewForOne

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(instancetype)initWithCloseBlock:(CloseBtnClicked)closeBlock ChatClicked:(ChatIcBtnClicked)chatBlock isResponseBlock:(IsResponseBlock)isResponseBlock isNotResponseBlock:(IsNotResponseBlock)isNotResponseBlock dataArrayForOne:(NSMutableArray *)dataArrayForOne anteid:(NSString *)anteid anteName:(NSString *)anteName isScreenLandScape:(BOOL)isScreenLandScape {
    self = [super init];
    if(self) {
        self.isScreenLandScape = isScreenLandScape;
        self.anteid = anteid;
        self.anteName = anteName;
        self.dataArrayForOne = dataArrayForOne;
        self.closeBlock = closeBlock;
        self.chatBlock = chatBlock;
        self.isResponseBlock = isResponseBlock;
        self.isNotResponseBlock = isNotResponseBlock;
        
        self.backgroundColor = CCRGBAColor(250,250,250,0.96);
        [self addSubviews];
        [self addObserver];
    }

    return self;
}

-(UIView *)bottomLine {
    if(!_bottomLine) {
        _bottomLine = [UIView new];
        _bottomLine.backgroundColor = CCRGBColor(221, 221, 221);
    }
    return _bottomLine;
}

-(UIView *)topLine {
    if(!_topLine) {
        _topLine = [UIView new];
        _topLine.backgroundColor = CCRGBColor(221, 221, 221);
    }
    return _topLine;
}

-(void)dealloc {
    [self removeObserver];
}

-(void)addSubviews {
    [self addSubview:self.topLine];
    WS(ws)
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(ws);
        make.height.mas_equalTo(1);
    }];
    
    [self addSubview:self.topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.topLine);
        make.top.mas_equalTo(ws.topLine.mas_bottom);
        make.height.mas_equalTo(CCGetRealFromPt(100));
    }];
    
    [self.topView addSubview:self.titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(ws.topView);
        
        make.top.bottom.mas_equalTo(ws.topView);
        make.left.mas_equalTo(ws.topView).offset(CCGetRealFromPt(100));
        make.right.mas_equalTo(ws.topView).offset(-CCGetRealFromPt(100));
    }];
    
    [self.topView addSubview:self.closeButton];
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.topView);
        make.right.mas_equalTo(ws.topView).offset(-CCGetRealFromPt(30));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(76), CCGetRealFromPt(76)));
    }];
    
    [self.topView addSubview:self.returnButton];
    
    [_returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.topView);
        make.left.mas_equalTo(ws.topView).offset(CCGetRealFromPt(30));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(76), CCGetRealFromPt(76)));
    }];
    
    [self addSubview:self.bottomLine];
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.topView);
        make.top.mas_equalTo(ws.topView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self addSubview:self.contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(110));
    }];
    
    [self.contentView addSubview:self.chatTextField];
    [_chatTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        if(!ws.isScreenLandScape) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(24));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(556), CCGetRealFromPt(84)));
        } else {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(1134), CCGetRealFromPt(84)));
        }
    }];
    
    [self.contentView addSubview:self.sendButton];
    [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if(!ws.isScreenLandScape) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.right.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(24));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(120), CCGetRealFromPt(84)));
        } else {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.right.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(120), CCGetRealFromPt(84)));
        }
    }];
    
    [self addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws);
        make.top.mas_equalTo(ws.bottomLine.mas_bottom);
        make.bottom.mas_equalTo(ws.contentView.mas_top);
    }];
    
    if([self.dataArrayForOne count] >= 1){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([_dataArrayForOne count]-1) inSection:0];
            [_tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
    
    UITapGestureRecognizer *hideTextBoardTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleInformationTap)];
    [self addGestureRecognizer:hideTextBoardTap];
}

-(void)dealSingleInformationTap {
    [self endEditing:YES];
}

-(UIButton *)returnButton {
    if(!_returnButton) {
        _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_returnButton setImage:[UIImage imageNamed:@"chat_ic_back_nor"] forState:UIControlStateNormal];
        _returnButton.contentMode = UIViewContentModeScaleAspectFit;
        [_returnButton addTarget:self action:@selector(returnBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _returnButton;
}

-(UIButton *)closeButton {
    if(!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"chat_btn_close"] forState:UIControlStateNormal];
        _closeButton.contentMode = UIViewContentModeScaleAspectFit;
        [_closeButton addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(void)closeBtnClicked {
    [_chatTextField resignFirstResponder];
    if(self.closeBlock) {
        self.closeBlock();
    }
}

-(void)returnBtnClicked {
    [_chatTextField resignFirstResponder];
    if(self.chatBlock) {
        self.chatBlock();
    }
}

-(UIView *)topView {
    if(!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = CCRGBAColor(248,248,248,0.96);
        _topView.layer.shadowColor = CCRGBColor(221,221,221).CGColor;
        _topView.layer.shadowOffset = CGSizeMake(1, 1);
    }
    return _topView;
}

-(UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.numberOfLines = 1;
        _titleLabel.backgroundColor = CCClearColor;
        _titleLabel.textColor = CCRGBColor(51,51,51);
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_32];
        _titleLabel.text = _anteName;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

-(UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

-(void)updateDataArray:(NSMutableArray *)dataArray {
    _dataArrayForOne = dataArray;
    
    if([self.dataArrayForOne count] >= 1){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([_dataArrayForOne count]-1) inSection:0];
            [_tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CCGetRealFromPt(26);
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CCGetRealFromPt(26))];
    view.backgroundColor = CCClearColor;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Dialogue *dialog = [_dataArrayForOne objectAtIndex:indexPath.row];

    float textMaxWidth = CCGetRealFromPt(438);
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:dialog.msg y:-8];
    NSLog(@"dialogue.msg = %@",dialog.msg);
    
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
    CGFloat height = textSize.height + CCGetRealFromPt(18) * 2;
    NSLog(@"height = %f,CCGetRealFromPt(80) = %f",height,CCGetRealFromPt(80));
    height = height < CCGetRealFromPt(80)?CCGetRealFromPt(80):height;
    return height + CCGetRealFromPt(36);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PrivateCellChatView";
    
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
    
    Dialogue *dialog = [_dataArrayForOne objectAtIndex:indexPath.row];
    BOOL fromSelf = [dialog.fromuserid isEqualToString:dialog.myViwerId];
    
//    UIImageView *head = nil;
//    if(StrNotEmpty(dialog.useravatar)) {
//        head = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bg_photo_nor"]];
//    } else {
//        head = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_img_photo_nor"]];
//    }
    UIImageView *head = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_img_photo_nor"]];
    head.backgroundColor = CCClearColor;
    head.contentMode = UIViewContentModeScaleAspectFit;
    head.userInteractionEnabled = NO;
    [cell addSubview:head];
    if(fromSelf) {
        [head mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(cell).offset(-CCGetRealFromPt(30));
            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
        }];
    } else {
        [head mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(cell).offset(CCGetRealFromPt(30));
            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
        }];
    }
    
//    UILabel *titleLabel = [UILabel new];
//    titleLabel.text = dialogue.fromusername;
//    titleLabel.backgroundColor = CCClearColor;
//    titleLabel.font = [UIFont systemFontOfSize:FontSize_24];
//    titleLabel.textColor = CCRGBColor(102,102,102);
//    titleLabel.userInteractionEnabled = NO;
//    [cell addSubview:titleLabel];
//    if(fromSelf) {
//        titleLabel.textAlignment = NSTextAlignmentRight;
//        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(head.mas_left).offset(-CCGetRealFromPt(32));
//            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(26));
//            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(490),CCGetRealFromPt(24)));
//        }];
//    } else {
//        titleLabel.textAlignment = NSTextAlignmentLeft;
//        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(head.mas_right).offset(CCGetRealFromPt(32));
//            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(26));
//            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(490),CCGetRealFromPt(24)));
//        }];
//    }
    
    float textMaxWidth = CCGetRealFromPt(438);
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:dialog.msg y:-8];
    NSLog(@"dialogue.msg = %@",dialog.msg);

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
    NSLog(@"textSize.width = %f,width = %f，image.size.width = %f",textSize.width,width,image.size.width);
    BOOL widthSmall = NO;
    if(width < image.size.width) {
        width = image.size.width;
        widthSmall = YES;
    }
    if(height < CCGetRealFromPt(80)) {
        if(fromSelf) {
            [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(head.mas_left).offset(-CCGetRealFromPt(22));
                make.top.mas_equalTo(head);
                make.size.mas_equalTo(CGSizeMake(width, CCGetRealFromPt(80)));
            }];
        } else {
            [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(head.mas_right).offset(CCGetRealFromPt(22));
                make.top.mas_equalTo(head);
                make.size.mas_equalTo(CGSizeMake(width, CCGetRealFromPt(80)));
            }];
        }
    } else {
        if(fromSelf) {
            [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(head.mas_left).offset(-CCGetRealFromPt(22));
                make.top.mas_equalTo(head);
                make.size.mas_equalTo(CGSizeMake(width, textSize.height + CCGetRealFromPt(18) * 2));
            }];
        } else {
            [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(head.mas_right).offset(CCGetRealFromPt(22));
                make.top.mas_equalTo(head);
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
    [bgButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    [bgButton setBackgroundImage:bgImage forState:UIControlStateDisabled];
    bgButton.enabled = NO;
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArrayForOne count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_anteid forKey:@"anteid"];
    [dic setObject:str forKey:@"str"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"private_Chat" object:dic];
    
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
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
    WS(ws)
    NSLog(@"PrivateChatViewForOne isResponseBlock");
    if(ws.isResponseBlock) {
        ws.isResponseBlock(y);
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    if(self.isNotResponseBlock) {
        self.isNotResponseBlock();
    }
}

-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = CCRGBAColor(171,179,189,0.30);
    }
    return _contentView;
}

-(CustomTextField *)chatTextField {
    if(!_chatTextField) {
        _chatTextField = [CustomTextField new];
        _chatTextField.delegate = self;
        [_chatTextField addTarget:self action:@selector(chatTextFieldChange) forControlEvents:UIControlEventEditingChanged];
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

-(UIView *)emojiView {
    if(!_emojiView) {
        if(_keyboardRect.size.width == 0 || _keyboardRect.size.height ==0) {
            _keyboardRect = CGRectMake(0, 0, 414, 271);
        }
        _emojiView = [[UIView alloc] initWithFrame:_keyboardRect];
        _emojiView.backgroundColor = CCRGBColor(242,239,237);
        
        CGFloat faceIconSize = CCGetRealFromPt(60);
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

@end
