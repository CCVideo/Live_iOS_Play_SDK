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
#import "InformationShowView.h"
#import "UIImageView+WebCache.h"
#import "ChatViewCell.h"
#import "CellHeight.h"
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

@property(nonatomic,strong)NSMutableArray               *publicChatArray;
@property(nonatomic,copy)  PublicChatBlock              publicChatBlock;
@property(nonatomic,copy)  PrivateChatBlock             privateChatBlock;
@property(nonatomic,strong)NSMutableDictionary          *privateChatDict;
@property(nonatomic,assign)BOOL                         input;
@property(nonatomic,strong)InformationShowView          *informationView;
@property (nonatomic, strong)NSMutableArray             *heightArray;//缓存cell的高度数组

@property (nonatomic, assign)BOOL                       keyBoradHidden;
@property (nonatomic, assign)BOOL                       privateHidden;
@end
#define CELLID @"CellChatView"
#define IMGURL @"[img_"
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
        [self layoutIfNeeded];
        [self.publicTableView reloadData];
        
        if (self.publicChatArray != nil && [self.publicChatArray count] != 0 ) {
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.publicChatArray.count - 1) inSection:0];
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
        NSInteger tabheight = IS_IPHONE_X?178:110;
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.right.and.left.mas_equalTo(ws);
            make.height.mas_equalTo(CCGetRealFromPt(tabheight));
        }];
        
        [self addSubview:self.publicTableView];
        [_publicTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.left.mas_equalTo(ws);
            make.bottom.mas_equalTo(ws.contentView.mas_top);
        }];
        
        //添加私聊视图
        [APPDelegate.window addSubview:self.ccPrivateChatView];
        self.ccPrivateChatView.frame = CGRectMake(0, SCREENH_HEIGHT, SCREEN_WIDTH, CCGetRealFromPt(835));
        self.privateHidden = YES;
//        [self.ccPrivateChatView setCheckDotBlock1:^(BOOL flag) {
//            ws.menuView.privateChatBtn.selected = flag;
//        }];
        
        UIView * line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithHexString:@"#e8e8e8" alpha:1.0f];
        [self.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];

        
        [self.contentView addSubview:self.chatTextField];
        [_chatTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(10));
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(24));
            make.right.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(24));
            make.height.mas_equalTo(CCGetRealFromPt(90));

        }];
        
        UIView * line1 = [[UIView alloc] init];
        line1.backgroundColor = [UIColor colorWithHexString:@"#e8e8e8" alpha:1.0f];
        [self.contentView addSubview:line1];
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.contentView);
            make.height.mas_equalTo(2);
//            make.top.equalTo(self.chatTextField.mas_bottom);
        }];
        
    } else {
        [self addSubview:self.publicTableView];
        [_publicTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws);
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(!StrNotEmpty([_chatTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]])) {
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:@"发送内容为空"];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(informationViewRemove) userInfo:nil repeats:NO];
        return YES;
    }
    [self chatSendMessage];
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
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
    if (_keyBoradHidden == YES) {
        [self endEditing:YES];
    }
    if(![self.chatTextField isFirstResponder]) {
        return;
    }
    
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
//    CGFloat x = _keyboardRect.size.width;
    //NSLog(@"键盘高度是  %d",(int)y);
    //NSLog(@"键盘宽度是  %d",(int)x);
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
                [self.publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self hideKeyboard];
}

-(void)hideKeyboard {
    WS(ws)
    NSInteger tabheight = IS_IPHONE_X?178:110;
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.and.left.and.bottom.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(tabheight));
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
        _contentView.backgroundColor = CCRGBColor(255,255,255);
    }
    return _contentView;
}

-(CustomTextField *)chatTextField {
    if(!_chatTextField) {
        _chatTextField = [CustomTextField new];
        _chatTextField.delegate = self;
        _chatTextField.layer.cornerRadius = CCGetRealFromPt(45);
        [_chatTextField addTarget:self action:@selector(chatTextFieldChange) forControlEvents:UIControlEventEditingChanged];
        _chatTextField.rightView = self.rightView;
        
    }
    return _chatTextField;
}

-(void)chatTextFieldChange {
    
    if(_chatTextField.text.length > 300) {
        //        [self endEditing:YES];
        _chatTextField.text = [_chatTextField.text substringToIndex:300];
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:@"输入限制在300个字符以内"];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];

        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(informationViewRemove) userInfo:nil repeats:NO];
    }
}

-(void)informationViewRemove {
    [_informationView removeFromSuperview];
    _informationView = nil;
}

-(UIButton *)rightView {
    if(!_rightView) {
        _rightView = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightView.frame = CGRectMake(0, 0, 42, 42);
        _rightView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightView.backgroundColor = CCClearColor;
//        [_rightView setBackgroundImage:[UIImage imageNamed:@"face_nov"] forState:UIControlStateNormal];
        [_rightView setImage:[UIImage imageNamed:@"face_nov"] forState:UIControlStateNormal];
        [_rightView setImage:[UIImage imageNamed:@"face_hov"] forState:UIControlStateSelected];
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
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:@"发送内容为空"];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];

        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(informationViewRemove) userInfo:nil repeats:NO];
        return;
    }
    
    [self chatSendMessage];
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}

-(UITableView *)publicTableView {
    if(!_publicTableView) {
        _publicTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _publicTableView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];
        _publicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _publicTableView.delegate = self;
        _publicTableView.dataSource = self;
        _publicTableView.showsVerticalScrollIndicator = NO;
        _publicTableView.estimatedRowHeight = 0;
        _publicTableView.estimatedSectionHeaderHeight = 0;
        _publicTableView.estimatedSectionFooterHeight = 0;
        [_publicTableView registerClass:[ChatViewCell class] forCellReuseIdentifier:@"CellChatView"];
        if (@available(iOS 11.0, *)) {
            _publicTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _publicTableView;
}

-(NSMutableArray *)publicChatArray {
    if(!_publicChatArray) {
        _publicChatArray = [[NSMutableArray alloc] init];
    }
    return _publicChatArray;
}

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

//计算cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Dialogue *dialogue = [self.publicChatArray objectAtIndex:indexPath.row];
    CGFloat height;
    //判断消息方是否是自己
    BOOL fromSelf = [dialogue.fromuserid isEqualToString:dialogue.myViwerId];
    //聊天审核 如果消息状态码为1,不显示此消息,状态可能没有
    if (dialogue.status && [dialogue.status isEqualToString:@"1"] && !fromSelf) {
        return 0;
    }
    if(dialogue.msg != nil && dialogue.fromusername == nil && dialogue.fromuserid == nil) {
        //返回广播消息的cell高度
        float textMaxWidth = CCGetRealFromPt(560);
        NSMutableAttributedString *textAttri = [Utility emotionStrWithString:dialogue.msg y:-8];
        [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(248,129,25) range:NSMakeRange(0, textAttri.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentLeft;
        style.minimumLineHeight = CCGetRealFromPt(34);
        style.maximumLineHeight = CCGetRealFromPt(34);
        style.lineBreakMode = NSLineBreakByCharWrapping;
        NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_24],NSParagraphStyleAttributeName:style};
        [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
        
        CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                  context:nil].size;
        textSize.height = ceilf(textSize.height);// + 1;
        return textSize.height + CCGetRealFromPt(18) * 2 + CCGetRealFromPt(30);
    } else {
        //返回用户消息的高度
        //判断是否有图片
        BOOL haveImg = [dialogue.msg containsString:IMGURL];//是否含有图片
        
        CGSize imgSize = CGSizeZero;
        //计算文本高度
        float textMaxWidth = CCGetRealFromPt(438);
        NSString * textAttr = [NSString stringWithFormat:@"%@:%@",dialogue.username,dialogue.msg];
        //如果有图片，消息只显示用户名
        //Ps:如果图文混排，只需要过滤掉图片地址即可
        if (haveImg) {
            textAttr = [NSString stringWithFormat:@"%@:", dialogue.username];
        }
        NSMutableAttributedString *textAttri = [Utility emotionStrWithString:textAttr y:-8];
        [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentLeft;
        style.minimumLineHeight = CCGetRealFromPt(36);
        style.maximumLineHeight = CCGetRealFromPt(60);
        style.lineBreakMode = NSLineBreakByCharWrapping;
        NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_28],NSParagraphStyleAttributeName:style};
        [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
        
        CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                  context:nil].size;
        textSize.height = ceilf(textSize.height);// + 1;
        //添加消息内容
        height = textSize.height + CCGetRealFromPt(18) * 2;
        //--------------如果有图片，计算图片高度
        if (haveImg) {
            //------------解析图片地址-------start---------
            //从字符A中分隔成2个元素的数组
            NSArray *getTitleArray = [dialogue.msg componentsSeparatedByString:IMGURL];
            //去除前缀
            NSString *url = [NSString stringWithFormat:@"%@", getTitleArray[1]];
            //        NSLog(@"imgUrl = %@", obj.msg);
            NSArray *arr = [url componentsSeparatedByString:@"]"];
            //去除后缀，得到url
            url = [NSString stringWithFormat:@"%@", arr[0]];
            //-----------解析图片地址---------end------------
            imgSize.height = [[CellHeight sharedHeight] getHeightForKey:url];
            if (imgSize.height == 0) {
                imgSize.height = [UIImage imageNamed:@"图片加载失败"].size.height;
            }
            height += imgSize.height;
        }
        //计算气泡的宽度和高度
        if(height < CCGetRealFromPt(80)) {//计算高度
            height = CCGetRealFromPt(80) + 20;
        } else {
            height = textSize.height + CCGetRealFromPt(18) * 2 + 20;
            if (haveImg) {
                height += imgSize.height;
            }
        };
        return height;
    }
}
#pragma mark - 设置图片相关设置
//返回一个处理过的图片大小
-(CGSize)getCGSizeWithImage:(UIImage *)image{
    CGSize imageSize = image.size;
    //先判断图片的宽度和高度哪一个大
    if (image.size.width > image.size.height) {
        //以宽度为准
        if (imageSize.width > CCGetRealFromPt(438)) {
            imageSize.height = CCGetRealFromPt(438) / imageSize.width * imageSize.height;
            imageSize.width = CCGetRealFromPt(438);
        }
    }else{
        //以高度为准
        if (imageSize.height >= CCGetRealFromPt(438)) {
            imageSize.width = CCGetRealFromPt(438) / imageSize.height * imageSize.width;
            imageSize.height = CCGetRealFromPt(438);
        }
    }
    return imageSize;
}
-(void)headBtnClicked:(UIButton *)sender {
//    if (!_ccPrivateChatView) {
//        [APPDelegate.window addSubview:self.ccPrivateChatView];
//        self.ccPrivateChatView.frame = CGRectMake(0, SCREENH_HEIGHT, SCREEN_WIDTH, CCGetRealFromPt(835));
//    }
    self.privateHidden = NO;
    self.ccPrivateChatView.hidden = NO;
    self.ccPrivateChatView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH,IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835));
    
    [self.ccPrivateChatView selectByClickHead:[self.publicChatArray objectAtIndex:sender.tag]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"CellChatView";
    
    ChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLID];
    if (cell == nil) {
        cell = [[ChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELLID] ;
    } else {
        for(UIView *cellView in cell.subviews){
            [cellView removeFromSuperview];
        }
    }
    [cell setBackgroundColor:[UIColor colorWithHexString:@"f5f5f5" alpha:1.0f]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Dialogue *dialogue = [self.publicChatArray objectAtIndex:indexPath.row];
    //判断消息方是否是自己
    BOOL fromSelf = [dialogue.fromuserid isEqualToString:dialogue.myViwerId];
    //聊天审核-------------如果消息状态码为1,不显示此消息,状态栏可能没有
    if (dialogue.status && [dialogue.status isEqualToString:@"1"] && !fromSelf){
        cell.hidden = YES;
        return cell;
    }
    //-----------------------
    WS(ws)
    if(dialogue.msg != nil && dialogue.fromusername == nil && dialogue.fromuserid == nil) {
        //设置广播消息UI布局
        [cell setBroadcastUI:dialogue.msg];
    } else {
        //返回用户消息UI布局
        [cell setMessageUI:dialogue isInput:self.input indexPath:indexPath];
        //头像点击回调
        cell.headBtnClickBlock = ^(UIButton * _Nonnull btn) {
            [ws headBtnClicked:btn];
        };
    }
    //图片下载完成，刷新UI
    cell.reloadBlock = ^(NSIndexPath * _Nonnull indexPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.publicTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //判断当前行数是否是最后一行，如果是,刷新至最后一行
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(ws.publicChatArray.count - 1) inSection:0];
            if (indexPath.row == indexPathLast.row) {
                [self.publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];;
            }
        });
    };
    cell.hiddenBlock = ^(BOOL hidden) {
        ws.keyBoradHidden = hidden;
        [ws endEditing:YES];
    };
    return cell;
}
//根据宽度求高度  content 计算的内容  width 计算的宽度 font字体大小
- (CGFloat)getLabelHeightWithText:(NSString *)text width:(CGFloat)width font: (CGFloat)font
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    
    return rect.size.height;
}


-(NSMutableDictionary *)privateChatDict {
    if(!_privateChatDict) {
        _privateChatDict = [[NSMutableDictionary alloc] init];
    }
    return _privateChatDict;
}
-(void)privateChatBtnClicked {
//    if (!_ccPrivateChatView) {
//        [APPDelegate.window addSubview:self.ccPrivateChatView];
//        self.ccPrivateChatView.frame = CGRectMake(0, SCREENH_HEIGHT, SCREEN_WIDTH, CCGetRealFromPt(835));
//    }
    self.privateHidden = NO;
    self.ccPrivateChatView.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^{
        self.ccPrivateChatView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH, IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835));
    } completion:^(BOOL finished) {
    }];
}
//初始化私聊界面
-(CCPrivateChatView *)ccPrivateChatView {
    if(!_ccPrivateChatView) {
        WS(ws)
        _ccPrivateChatView = [[CCPrivateChatView alloc] initWithCloseBlock:^{
            [UIView animateWithDuration:0.25f animations:^{
                ws.ccPrivateChatView.frame = CGRectMake(0, SCREENH_HEIGHT, SCREEN_WIDTH, CCGetRealFromPt(835));
            } completion:^(BOOL finished) {
                if(ws.ccPrivateChatView.privateChatViewForOne) {
                    [ws.ccPrivateChatView.privateChatViewForOne removeFromSuperview];
                    ws.ccPrivateChatView.privateChatViewForOne = nil;
                }
            }];
        } isResponseBlock:^(CGFloat y) {
            [UIView animateWithDuration:0.25f animations:^{
                self.ccPrivateChatView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH, IS_IPHONE_X ? CCGetRealFromPt(835) + 90 - y + kScreenBottom:CCGetRealFromPt(835)-y);;
            } completion:^(BOOL finished) {
            }];
        } isNotResponseBlock:^{
            [UIView animateWithDuration:0.25f animations:^{
                self.ccPrivateChatView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH, IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835));;
            } completion:^(BOOL finished) {
            }];
        }  dataPrivateDic:[self.privateChatDict copy] isScreenLandScape:NO];
    }
    return _ccPrivateChatView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //如果有输入框，点击cell时对私聊视图进行操作
    if(self.input){
        [_chatTextField resignFirstResponder];
        [_ccPrivateChatView.privateChatViewForOne.chatTextField resignFirstResponder];
        WS(ws)
        [_ccPrivateChatView showTableView];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.ccPrivateChatView.frame = CGRectMake(0, SCREENH_HEIGHT, SCREEN_WIDTH, CCGetRealFromPt(835));
        } completion:^(BOOL finished) {
            if(ws.ccPrivateChatView.privateChatViewForOne) {
                [ws.ccPrivateChatView.privateChatViewForOne removeFromSuperview];
                ws.ccPrivateChatView.privateChatViewForOne = nil;
            }
        }];
    }
}
//添加公聊信息
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
            [ws.publicTableView scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}
//聊天审核
-(void)reloadStatusWithIndexPaths:(NSMutableArray *)arr publicArr:(NSMutableArray *)publicArr{
//    NSLog(@"arr = %@", arr);
    [self.publicChatArray removeAllObjects];
    self.publicChatArray = [publicArr mutableCopy];
    NSArray *reloadArr = (NSArray *)[arr mutableCopy];
    [self.publicTableView reloadRowsAtIndexPaths:reloadArr withRowAnimation:UITableViewRowAnimationNone];
    //todo  是否能去掉GCD
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        //判断当前行数是否是最后一行，如果是,刷新至最后一行
        NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(ws.publicChatArray.count - 1) inSection:0];
        [self.publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];;
    });
}

@end

