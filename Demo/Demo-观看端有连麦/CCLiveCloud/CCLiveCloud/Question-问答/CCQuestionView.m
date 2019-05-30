//
//  CCQuestionView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/6.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCQuestionView.h"
#import "QuestionTextField.h"//问答输入框
#import "Dialogue.h"//数据模型
#import "UIImage+Extension.h"//image扩展
#import "InformationShowView.h"//提示视图
#import "UIImageView+WebCache.h"
#import "CCQuestionViewCell.h"//cell

@interface CCQuestionView()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,strong)UITableView                  *questionTableView;//问答视图
//@property(nonatomic,strong)NSMutableArray               *tableArray;
@property(nonatomic,copy)  NSString                     *antename;//名称
@property(nonatomic,copy)  NSString                     *anteid;//id
@property(nonatomic,strong)QuestionTextField            *questionTextField;//输入框
@property(nonatomic,strong)UIView                       *contentView;//输入视图
@property(nonatomic,strong)UIButton                     *leftView;//左侧leftBtn
@property(nonatomic,strong)UIView                       *emojiView;//表情视图
@property(nonatomic,assign)CGRect                       keyboardRect;//键盘大小

@property(nonatomic,strong)NSMutableDictionary          *QADic;//问答字典
@property(nonatomic,strong)NSMutableArray               *keysArrAll;//所有的答案数组

@property(nonatomic,strong)NSMutableDictionary          *newQADic;//新问答字典
@property(nonatomic,strong)NSMutableArray               *newKeysArr;//新答案数组

@property(nonatomic,copy)  QuestionBlock                block;//问答回调
@property(nonatomic,assign)BOOL                         input;//是否有输入框
@property(nonatomic,strong)InformationShowView          *informationView;//提示信息
@property(nonatomic,strong)UIView *imageView;//
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
//初始化视图
-(void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    if(self.input) {
        //添加输入视图
        [self addSubview:self.contentView];
        NSInteger tabheight = IS_IPHONE_X?178:110;
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.right.and.left.mas_equalTo(self);
            make.height.mas_equalTo(CCGetRealFromPt(tabheight));
        }];
        //添加问答tableView
        [self addSubview:self.questionTableView];
        [_questionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.left.mas_equalTo(self);
            make.bottom.mas_equalTo(self.contentView.mas_top);
        }];
        //为输入框添加分界线
        UIView * line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithHexString:@"#e8e8e8" alpha:1.0f];
        [self.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
        //为输入视图添加输入框
        [self.contentView addSubview:self.questionTextField];
        [_questionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(CCGetRealFromPt(10));
            make.left.mas_equalTo(self.contentView).offset(CCGetRealFromPt(24));
            make.right.equalTo(self.contentView).offset(-CCGetRealFromPt(24));
            make.height.mas_equalTo(CCGetRealFromPt(84));
        }];

    } else {//没有输入时
        //添加问答视图
        [self addSubview:self.questionTableView];
        [_questionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
}
//键盘将要退出时
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(!StrNotEmpty([_questionTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]])) {
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:ALERT_EMPTYMESSAGE];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
        return YES;
    }
    [self chatSendMessage];
    return YES;
}

/**
 发送问答消息
 */
-(void)chatSendMessage {
    NSString *str = _questionTextField.text;
    if(str == nil || str.length == 0) {
        return;
    }

    if(self.block) {
        self.block(str);//问答消息回调
    }

    _questionTextField.text = nil;
    [_questionTextField resignFirstResponder];
}
#pragma mark - 添加通知
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
//移除通知
-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark keyboard notification
//键盘将要出现
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
//键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notif {
    [self hideKeyboard];
}
//隐藏键盘
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
//输入视图
-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = CCRGBColor(255,255,255);

    }
    return _contentView;
}
//问答输入框
-(QuestionTextField *)questionTextField {
    if(!_questionTextField) {
        _questionTextField = [[QuestionTextField alloc] init];
        _questionTextField.delegate = self;
        _questionTextField.leftView = self.leftView;
        _questionTextField.layer.cornerRadius = CCGetRealFromPt(42);
        [_questionTextField addTarget:self action:@selector(questionTextFieldChange) forControlEvents:UIControlEventEditingChanged];
    }
    return _questionTextField;
}
//输入框内容改变
-(void)questionTextFieldChange {
    if(_questionTextField.text.length > 300) {
        //        [self endEditing:YES];
        _questionTextField.text = [_questionTextField.text substringToIndex:300];
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:ALERT_INPUTLIMITATION];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];

        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
    }
}
//移除提示信息
-(void)removeInformationView {
    [_informationView removeFromSuperview];
    _informationView = nil;
}
//左侧按钮
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

//点击左侧按钮
-(void)leftButtonClicked {
    BOOL selected = !_leftView.selected;
    _leftView.selected = selected;
    _leftView.userInteractionEnabled = NO;

    [self bringSubviewToFront:self.contentView];
//添加提示背景
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
//添加提示label
    UILabel *label = [[UILabel alloc] init];
    label.text = ALERT_CHECKQUESTION(selected);
    label.backgroundColor = CCClearColor;
    label.font = [UIFont systemFontOfSize:FontSize_26];
    label.textColor = [UIColor whiteColor];
    label.userInteractionEnabled = NO;
    label.textAlignment = NSTextAlignmentCenter;
    [self.imageView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.imageView);
    }];
//重载我的问答和所有问答
    [self reloadQADic:self.QADic keysArrAll:self.keysArrAll];
//加载动画
    [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.imageView removeFromSuperview];
        self.leftView.userInteractionEnabled = YES;
    }];
}
//问答tableView
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
#pragma mark - tableView Delegate And DataSource
//返回行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.newKeysArr count];
}
//返回footerView的高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CCGetRealFromPt(26);
}
//设置footerView
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, CCGetRealFromPt(26))];
    view.backgroundColor = CCClearColor;
    return view;
}
//设置每行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *encryptId = [self.newKeysArr objectAtIndex:indexPath.row];
    NSMutableArray *arr = [self.newQADic objectForKey:encryptId];
    //计算高度
    CGFloat height = [self heightForCellOfQuestion:arr] + 2;
    if(indexPath.row == 0) {
        height += 2;
    }
    return height;
}
#pragma mark - 设置cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellQuestionView";
    //注册cell
    CCQuestionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CCQuestionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    //解析数据
    NSString *encryptId = [self.newKeysArr objectAtIndex:indexPath.row];
    NSMutableArray *arr = [self.newQADic objectForKey:encryptId];
    Dialogue *dialogue = [arr objectAtIndex:0];
    //设置cell
    [cell setQuestionModel:dialogue indexPath:indexPath arr:arr isInput:self.input];

    return cell;
}

/**
 计算cell的高度

 @param array 问答数据数组
 @return 高度
 */
-(CGFloat)heightForCellOfQuestion:(NSMutableArray *)array {
    CGFloat height;
//计算高度
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


@end
