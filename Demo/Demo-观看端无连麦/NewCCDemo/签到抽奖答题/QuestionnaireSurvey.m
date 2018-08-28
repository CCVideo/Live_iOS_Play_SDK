//
//  VoteView.m
//  NewCCDemo
//
//  Created by cc on 2017/1/11.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "QuestionnaireSurvey.h"
#import "UIButton+UserInfo.h"
#import "UITextView+UserInfo.h"
#import "UIColor+RCColor.h"

@interface QuestionnaireSurvey()<UITextViewDelegate>

@property(nonatomic,strong)UIImageView              *questionImage;
@property(nonatomic,strong)UIView                   *bgView;
@property(nonatomic,strong)UILabel                  *label;
@property(nonatomic,strong)UIView                   *lineView;
@property(nonatomic,strong)UIButton                 *closeBtn;

@property(nonatomic,strong)UILabel                  *secondLabel;
@property(nonatomic,strong)UIButton                 *submitBtn;
@property(nonatomic,strong)UIView                   *view;
@property(nonatomic,assign)BOOL                     isScreenLandScape;
@property(nonatomic,assign)BOOL                     isStastic;
@property(nonatomic,copy)  CloseBlock               closeblock;
@property(strong,nonatomic)UIScrollView             *scrollView;
//@property(strong,nonatomic)NSDictionary             *questionDic;
@property(nonatomic,assign)CGRect                   keyboardRect;
@property(nonatomic,strong)UITextView               *selectedTextView;
@property(nonatomic,strong)UILabel                  *msgLabel;
@property(nonatomic,strong)NSMutableArray           *buttonIdArray;
@property(nonatomic,strong)NSMutableArray           *correctLabelArray;
@property(nonatomic,strong)NSMutableArray           *buttonArray;
@property(nonatomic,strong)NSMutableArray           *textViewArray;
@property(nonatomic,assign)NSInteger                selectQuestionCount;
@property(nonatomic,strong)NSDictionary             *questionnaireDic;
@property(nonatomic,strong)NSDictionary             *selectDic;
@property(nonatomic,assign)NSInteger                submitedAction;//是否显示答案1显示其他不显示
@property(nonatomic,assign)CGFloat                submitAnswerViewerCount;//提交人数

@property(nonatomic,copy)  CommitBlock              commitblock;
@property(nonatomic,strong)UILabel                   *correctLabel;//正确答案前面的提示
@property(nonatomic,assign)NSInteger                 lastType;

@end

//答题
@implementation QuestionnaireSurvey

- (instancetype)initWithCloseBlock:(CloseBlock)closeblock CommitBlock:(CommitBlock)commitblock questionnaireDic:(NSDictionary *)questionnaireDic isScreenLandScape:(BOOL)isScreenLandScape isStastic:(BOOL)isStastic {

    self = [super init];
    if(self) {
        self.isScreenLandScape  = isScreenLandScape;
        self.isStastic          = isStastic;
        self.closeblock         = closeblock;
        self.commitblock        = commitblock;
        self.questionnaireDic   = questionnaireDic;
        self.submitedAction     = [questionnaireDic[@"submitedAction"] integerValue];//
        self.submitAnswerViewerCount = (CGFloat)[questionnaireDic[@"submitAnswerViewerCount"] integerValue];
//        self.lastType = 2;
        [self initUI];
        [self addObserver];
    }
    return self;
}

-(NSMutableArray *)buttonArray {
    if(!_buttonArray) {
        _buttonArray = [[NSMutableArray alloc]init];
    }
    return _buttonArray;
}

-(NSMutableArray *)textViewArray {
    if(!_textViewArray) {
        _textViewArray = [[NSMutableArray alloc]init];
    }
    return _textViewArray;
}

-(NSMutableArray *)buttonIdArray {
    if(!_buttonIdArray) {
        _buttonIdArray = [[NSMutableArray alloc]init];
    }
    return _buttonIdArray;
}
-(NSMutableArray *)correctLabelArray {
    if(!_correctLabelArray) {
        _correctLabelArray = [[NSMutableArray alloc]init];
    }
    return _correctLabelArray;
}

-(void)initUI {
    WS(ws)
    _selectQuestionCount = 0;
    self.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
    [self addGestureRecognizer:singleTap];
    
    _view = [[UIView alloc]init];
    _view.backgroundColor = CCRGBColor(255,81,44);
    _view.layer.cornerRadius = CCGetRealFromPt(8);
    
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
    [_view addGestureRecognizer:singleTap1];
    [self addSubview:_view];
    if(!self.isScreenLandScape) {
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws).offset(CCGetRealFromPt(40));
            make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(40));
            make.top.mas_equalTo(ws).offset(CCGetRealFromPt(192));
            make.bottom.mas_equalTo(ws).offset(-CCGetRealFromPt(90));
        }];
    } else {
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws).offset(CCGetRealFromPt(232));
            make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(232));
            make.top.mas_equalTo(ws).offset(CCGetRealFromPt(122));
            make.bottom.mas_equalTo(ws).offset(-CCGetRealFromPt(60));
        }];
    }
    
    self.bgView = [UIView new];
    [self.bgView setBackgroundColor:[UIColor whiteColor]];
    self.bgView.layer.cornerRadius = CCGetRealFromPt(8);
    [_view addSubview:self.bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(1);
        make.top.mas_equalTo(ws.view).offset(1);
        make.right.mas_equalTo(ws.view).offset(-1);
        make.bottom.mas_equalTo(ws.view).offset(-(1 + CCGetRealFromPt(4)));
    }];
    
    [self.bgView addSubview:self.lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.bgView).offset(CCGetRealFromPt(81));
        make.right.mas_equalTo(ws.bgView).offset(-CCGetRealFromPt(79));
        make.top.mas_equalTo(ws.bgView).offset(CCGetRealFromPt(26));
        make.height.mas_equalTo(1);
    }];
    
    [self.bgView addSubview:self.questionImage];
    [_questionImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.bgView);
        make.bottom.mas_equalTo(ws.view.mas_top).offset(CCGetRealFromPt(54));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(110), CCGetRealFromPt(110)));
    }];
    
    [self.bgView addSubview:self.closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.bgView);//.offset(CCGetRealFromPt(0));
        make.right.mas_equalTo(ws.bgView);//.offset(-CCGetRealFromPt(0));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
    }];
    
    [self.bgView addSubview:self.label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.bgView);
        make.top.mas_equalTo(ws.bgView).offset(CCGetRealFromPt(66));
        make.height.mas_equalTo(CCGetRealFromPt(36));
    }];
    
    [self addSubview:self.scrollView];
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
    [_scrollView addGestureRecognizer:singleTap2];
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.userInteractionEnabled = YES;
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.bgView);
        make.right.mas_equalTo(ws.bgView);
        make.top.mas_equalTo(ws.label.mas_bottom).offset(CCGetRealFromPt(25));
        make.bottom.mas_equalTo(ws.bgView);
    }];

//    NSString *questionStr = @"{\"id\": \"83450A45EB037826\",\"title\": \"CC视频问卷功能细节考评\",\"subjects\": [{\"id\": \"8CF77A91E659162F\",\"index\": 0,\"type\": 0,\"content\": \"第一道题（单选题）, type = 0\",\"options\": [{\"id\": \"83450A45EB037826\",\"index\": 0,\"content\": \"第01个选项（正确答案）\"},{\"id\": \"23C36A9C2E8649CA\",\"index\": 1,\"content\": \"第02个选项（错误答案）\"},{\"id\": \"20543941BC1B9A28\",\"index\": 2,\"content\": \"第03个选项（错误答案）\"},{\"id\": \"72AF62C81D0B48F7\",\"index\": 2,\"content\": \"第04个选项（错误答案）\"}]},{\"id\": \"736BE943513CC9C2\",\"index\": 1,\"type\": 1,\"content\": \"第二道题（多选题）, type = 1\",\"options\": [{\"id\": \"11A3D9A7F1169A89\",\"index\": 0,\"content\": \"第01个选项（正确答案）\"},{\"id\": \"9EEC738B25189C8D\",\"index\": 1,\"content\": \"第02个选项（错误答案）\"},{\"id\": \"5C28C57726CF8726\",\"index\": 2,\"content\": \"第03个选项（正确答案）\"},{\"id\": \"D1CD8F561E26EF7C\",\"index\": 3,\"content\": \"第04个选项（错误答案）\"}]},{\"id\": \"1BE68588D53A91D8\",\"index\": 2,\"type\": 2,\"content\": \"第三道题（问答题）, type = 2\"}]}";
    
//    NSData *jsonData = [questionStr dataUsingEncoding:NSUTF8StringEncoding];
//    id jsonDrawValue = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
//    _questionnaireDic = (NSDictionary *)jsonDrawValue;
    float textMaxWidth = self.isScreenLandScape? CCGetRealFromPt(669) : CCGetRealFromPt(610);
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:_questionnaireDic[@"title"]];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(153,153,153) range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = CCGetRealFromPt(20);
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_24],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.width = ceilf(textSize.width);
    textSize.height = ceilf(textSize.height);
    
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = CCClearColor;
    contentLabel.textColor = CCRGBColor(153,153,153);
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.userInteractionEnabled = NO;
    contentLabel.attributedText = textAttri;
    [_scrollView addSubview:contentLabel];

    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textMaxWidth);
        make.centerX.mas_equalTo(_scrollView);
        make.top.mas_equalTo(_scrollView);
        make.height.mas_equalTo(textSize.height);
    }];
    
    NSMutableArray *subjectsArray = _questionnaireDic[@"subjects"];
    NSString *AStr = @"A： ";
    CGSize ASize = [self getSizeByStr:AStr minFontHeight:CCGetRealFromPt(26) maxFontHeight:CCGetRealFromPt(26) UIFont:[UIFont boldSystemFontOfSize:FontSize_26] textMaxWidth:textMaxWidth lineSpacing:CCGetRealFromPt(0)];
    UIView *referenceViewPreview = contentLabel;
    for(int i = 0;i < [subjectsArray count];i++) {
        NSString *leftStr = [NSString stringWithFormat:@"%d.",i+1];
        CGSize leftSizeNum = [self getSizeByStr:leftStr minFontHeight:CCGetRealFromPt(26) maxFontHeight:CCGetRealFromPt(26) UIFont:[UIFont boldSystemFontOfSize:FontSize_26] textMaxWidth:textMaxWidth lineSpacing:CCGetRealFromPt(0)];
        
        NSDictionary *opthionsDic = subjectsArray[i];
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.text = leftStr;
        leftLabel.textColor = CCRGBColor(102,102,102);
        leftLabel.textAlignment = NSTextAlignmentLeft;
        leftLabel.font = [UIFont boldSystemFontOfSize:FontSize_26];
        [_scrollView addSubview:leftLabel];
        
        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_scrollView.mas_left).offset(CCGetRealFromPt(30));
            if(i == 0) {
                make.top.mas_equalTo(referenceViewPreview.mas_bottom).offset(CCGetRealFromPt(52));
            } else {
                if ([opthionsDic[@"type"] intValue] == 2 && self.isStastic) {
                    if (self.lastType == 1 || self.lastType == 0) {
                        make.top.mas_equalTo(referenceViewPreview.mas_bottom).offset(CCGetRealFromPt(58+2));
                    } else {
                        make.top.mas_equalTo(referenceViewPreview.mas_bottom).offset(CCGetRealFromPt(1));
                    }
                } else {
                    make.top.mas_equalTo(referenceViewPreview.mas_bottom).offset(CCGetRealFromPt(58+2));
                }
            }
            self.lastType = [opthionsDic[@"type"] intValue];
            make.width.mas_equalTo(leftSizeNum.width);
            make.height.mas_equalTo(leftSizeNum.height);
        }];
        
        NSString *centerStr = nil;
        if([opthionsDic[@"type"] intValue] == 0) {
            centerStr = @"单选";
            _selectQuestionCount ++;
        } else if([opthionsDic[@"type"] intValue] == 1) {
            centerStr = @"多选";
            _selectQuestionCount ++;
        } else if([opthionsDic[@"type"] intValue] == 2) {
            centerStr = @"问答";
        }
        
        UILabel *centerLabel = [[UILabel alloc] init];
        centerLabel.text = centerStr;
        centerLabel.textColor = CCRGBColor(252,81,43);
        centerLabel.textAlignment = NSTextAlignmentLeft;
        centerLabel.font = [UIFont boldSystemFontOfSize:FontSize_26];
        [_scrollView addSubview:centerLabel];
        
        CGSize centerSizeNum = [self getSizeByStr:centerStr minFontHeight:CCGetRealFromPt(26) maxFontHeight:CCGetRealFromPt(26) UIFont:[UIFont boldSystemFontOfSize:FontSize_26] textMaxWidth:textMaxWidth lineSpacing:CCGetRealFromPt(0)];

        [centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_scrollView.mas_left).offset(CCGetRealFromPt(30) + leftSizeNum.width + CCGetRealFromPt(15));
            make.top.mas_equalTo(leftLabel.mas_top);
            make.width.mas_equalTo(centerSizeNum.width);
            make.height.mas_equalTo(centerSizeNum.height);
        }];
        
        UIImageView *centerImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"分隔点"]];
        [_scrollView addSubview:centerImageView];
        
        [centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_scrollView.mas_left).offset(CCGetRealFromPt(30) + leftSizeNum.width + CCGetRealFromPt(15) + centerSizeNum.width + CCGetRealFromPt(10));
            make.centerY.mas_equalTo(leftLabel.mas_centerY);
            make.width.mas_equalTo(CCGetRealFromPt(8));
            make.height.mas_equalTo(CCGetRealFromPt(8));
        }];
        
        CGFloat maxContentWidth = self.isScreenLandScape ? CCGetRealFromPt(692) : CCGetRealFromPt(492);
        NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:opthionsDic[@"content"]];
        [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51,51,51) range:NSMakeRange(0, textAttri.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//        style.minimumLineHeight = CCGetRealFromPt(28);
        style.lineSpacing = CCGetRealFromPt(20);
        style.alignment = NSTextAlignmentLeft;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_28],NSParagraphStyleAttributeName:style};
        [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
        
        CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(maxContentWidth, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                  context:nil].size;
        textSize.width = ceilf(textSize.width);
        textSize.height = ceilf(textSize.height);
        
        UILabel *contentLabelQue = [UILabel new];
        contentLabelQue.numberOfLines = 0;
        contentLabelQue.backgroundColor = CCClearColor;
        contentLabelQue.textColor = CCRGBColor(51,51,51);
        contentLabelQue.textAlignment = NSTextAlignmentLeft;
        contentLabelQue.userInteractionEnabled = NO;
        contentLabelQue.attributedText = textAttri;
        [_scrollView addSubview:contentLabelQue];
        
        [contentLabelQue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_scrollView.mas_left).offset(CCGetRealFromPt(30) + leftSizeNum.width + CCGetRealFromPt(15) + centerSizeNum.width + CCGetRealFromPt(10) + centerImageView.frame.size.width + CCGetRealFromPt(10) + 1);
            make.top.mas_equalTo(leftLabel.mas_top);//.offset(3);
            make.width.mas_equalTo(textSize.width);
            make.height.mas_equalTo(textSize.height);
        }];
        
        NSArray *optionsArray = opthionsDic[@"options"];
        UIView *referenceView = contentLabelQue;
        if(([opthionsDic[@"type"] intValue] == 0 || [opthionsDic[@"type"] intValue] == 1) && optionsArray) {
            for(int j = 0;j < [optionsArray count];j++) {
                NSDictionary *optionDic = optionsArray[j];
                UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
                selectButton.hidden = self.isStastic? YES: NO;
                [selectButton addTarget:self action:@selector(selectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                if([opthionsDic[@"type"] intValue] == 0) {
                    [selectButton setBackgroundImage:[UIImage imageNamed:@"单选未选"] forState:UIControlStateNormal];
                    [selectButton setBackgroundImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateSelected];
                    [selectButton setBackgroundImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateHighlighted];
                } else if([opthionsDic[@"type"] intValue] == 1) {
                    [selectButton setBackgroundImage:[UIImage imageNamed:@"多选未选"] forState:UIControlStateNormal];
                    [selectButton setBackgroundImage:[UIImage imageNamed:@"多选选中"] forState:UIControlStateSelected];
                    [selectButton setBackgroundImage:[UIImage imageNamed:@"多选选中"] forState:UIControlStateHighlighted];
                }
                
                //题号-类型（0：单选，1:多选）-选项个数-选项索引值-题目ID-选项ID
                NSString *buttonId = [NSString stringWithFormat:@"%d-%d-%d-%d-%@-%@",i,[opthionsDic[@"type"] intValue],(int)[optionsArray count],j,opthionsDic[@"id"],optionDic[@"id"]];
                selectButton.userid = buttonId;
                [self.buttonArray addObject:selectButton];
                [self.buttonIdArray addObject:buttonId];
                
                [_scrollView addSubview:selectButton];
                
                [selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(_scrollView.mas_left).offset(CCGetRealFromPt(74));
                    if(j == 0) {
                        make.top.mas_equalTo(referenceView.mas_bottom).offset(CCGetRealFromPt(40));
                    } else {
                        make.top.mas_equalTo(referenceView.mas_bottom).offset(CCGetRealFromPt(58));
                    }
                    make.width.mas_equalTo(CCGetRealFromPt(40));
                    make.height.mas_equalTo(CCGetRealFromPt(40));
                }];
//需要判断是否正确
                if ([optionsArray[j][@"correct"] integerValue] == 1) {
                    
                        UILabel * correctLabel = [[UILabel alloc] init];
                        _correctLabel = correctLabel;
                        correctLabel.text = @"正确";
                        correctLabel.textColor = CCRGBColor(67,181,15);
                        correctLabel.textAlignment = NSTextAlignmentLeft;
                        correctLabel.font = [UIFont boldSystemFontOfSize:FontSize_24];
                    correctLabel.hidden = self.isStastic ? NO : YES;
                        [_scrollView addSubview:correctLabel];
                        [correctLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.centerY.mas_equalTo(selectButton);
                            make.right.mas_equalTo(selectButton.mas_left).offset(-5);
                        }];
                    [self.correctLabelArray addObject:correctLabel];
                }

            
                UILabel *ALabel = [[UILabel alloc] init];
                ALabel.text = [NSString stringWithFormat:@"%c：",'A' + j];
                ALabel.textColor = CCRGBColor(102,102,102);
                ALabel.textAlignment = NSTextAlignmentLeft;
                ALabel.font = [UIFont boldSystemFontOfSize:FontSize_26];
                [_scrollView addSubview:ALabel];
                
                [ALabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(selectButton.mas_right).offset(CCGetRealFromPt(30));
                    make.centerY.mas_equalTo(selectButton.mas_centerY);
                    make.width.mas_equalTo(ASize.width);
                    make.height.mas_equalTo(ASize.height);
                }];
                
                CGFloat maxOptionContentWidth = self.isScreenLandScape ? CCGetRealFromPt(641) : CCGetRealFromPt(441);
                NSMutableAttributedString *textAttriOption = [[NSMutableAttributedString alloc] initWithString:optionDic[@"content"]];
                [textAttriOption addAttribute:NSForegroundColorAttributeName value:CCRGBColor(102,102,102) range:NSMakeRange(0, textAttriOption.length)];
                NSMutableParagraphStyle *styleOption = [[NSMutableParagraphStyle alloc] init];
//                styleOption.minimumLineHeight = CCGetRealFromPt(26);
                styleOption.lineSpacing = CCGetRealFromPt(20);
                styleOption.alignment = NSTextAlignmentLeft;
                styleOption.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *dictOption = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],NSParagraphStyleAttributeName:styleOption};
                [textAttriOption addAttributes:dictOption range:NSMakeRange(0, textAttriOption.length)];
                
                CGSize textSizeOption = [textAttriOption boundingRectWithSize:CGSizeMake(maxOptionContentWidth, CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                          context:nil].size;
                textSizeOption.width = ceilf(textSizeOption.width);
                textSizeOption.height = ceilf(textSizeOption.height);
                
                UILabel *contentLabelOption = [UILabel new];
                contentLabelOption.numberOfLines = 0;
                contentLabelOption.backgroundColor = CCClearColor;
                contentLabelOption.textColor = CCRGBColor(51,51,51);
                contentLabelOption.textAlignment = NSTextAlignmentLeft;
                contentLabelOption.userInteractionEnabled = NO;
                contentLabelOption.attributedText = textAttriOption;
                [_scrollView addSubview:contentLabelOption];
                
                [contentLabelOption mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(ALabel.mas_right).offset(CCGetRealFromPt(10));
                    make.top.mas_equalTo(ALabel.mas_top);//.offset(3);
                    make.width.mas_equalTo(textSizeOption.width);
                    make.height.mas_equalTo(textSizeOption.height);
                }];
                
                referenceView = contentLabelOption;

                referenceViewPreview = contentLabelOption;
                
//添加统计条形图
                if (self.isStastic) {
                    CGFloat  submitCount = (CGFloat)([optionsArray[j][@"selectedCount"] integerValue] / self.submitAnswerViewerCount);
                    selectButton.userInteractionEnabled = NO;
                    //背景
                    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
                    bgView.backgroundColor = [UIColor colorWithHexString:@"#edf5ff" alpha:1.0f];
                    [_scrollView addSubview:bgView];
                    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(selectButton);
                        make.right.equalTo(self).offset(-100);
                        make.top.mas_equalTo(contentLabelOption.mas_bottom).offset(10);
                        make.height.mas_equalTo(15);
                    }];
                    //数据
                    UIView *dataView = [[UIView alloc] initWithFrame:CGRectZero];
                    dataView.backgroundColor = [UIColor colorWithHexString:@"#43b50f" alpha:1.0f];
                    [_scrollView addSubview:dataView];
                    [dataView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(selectButton);
                        make.width.equalTo(bgView).multipliedBy(submitCount);
                        make.top.mas_equalTo(contentLabelOption.mas_bottom).offset(10);
                        make.height.mas_equalTo(15);
                    }];
                    
                    //百分比
                    
                    UILabel *percent = [[UILabel alloc] init];
                    percent.text = [NSString stringWithFormat:@"%ld人(%.1f%%)",[optionsArray[j][@"selectedCount"] integerValue],submitCount*100];
                    percent.textAlignment = NSTextAlignmentCenter;
                    [percent setTextColor:[UIColor darkGrayColor]];
                    percent.font = [UIFont systemFontOfSize:12];
                    [_scrollView addSubview:percent];
                    [percent mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.equalTo(bgView);
                        make.left.equalTo(bgView.mas_right).offset(2);
                    }];
                }
            }

        } else if([opthionsDic[@"type"] intValue] == 2) {
            UIView *viewBG = [[UIView alloc] init];
            viewBG.backgroundColor = CCRGBColor(250,250,250);
            viewBG.hidden = self.isStastic? YES: NO;
                [_scrollView addSubview:viewBG];
                [viewBG mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(_scrollView.mas_left).offset(CCGetRealFromPt(70));
                    make.top.mas_equalTo(referenceView.mas_bottom).offset(CCGetRealFromPt(40));
                    if(ws.isScreenLandScape) {
                        make.width.mas_equalTo(CCGetRealFromPt(770));
                    } else {
                        make.width.mas_equalTo(CCGetRealFromPt(570));
                    }
                    make.height.mas_equalTo(CCGetRealFromPt(self.isStastic?1:178));
                }];

            viewBG.layer.borderColor = CCRGBColor(221,221,221).CGColor;
            viewBG.layer.borderWidth = 1;
            viewBG.tag = i + 1 + 100;
            referenceView.tag = viewBG.tag + 100;
            
            UITextView *uiTextView = [[UITextView alloc] init];
            uiTextView.backgroundColor = CCClearColor;
            uiTextView.font = [UIFont systemFontOfSize:FontSize_26];
            uiTextView.textColor = CCRGBColor(102,102,102);
            uiTextView.textAlignment = NSTextAlignmentLeft;
            uiTextView.autocorrectionType = UITextAutocorrectionTypeNo;
            uiTextView.keyboardType = UIKeyboardTypeDefault;
            uiTextView.returnKeyType = UIReturnKeyDone;
            uiTextView.scrollEnabled = YES;
            uiTextView.userid = opthionsDic[@"id"];
            uiTextView.delegate = self;
            uiTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
            if (!self.isStastic) {
            
                [self.textViewArray addObject:uiTextView];
                [viewBG addSubview:uiTextView];
                [uiTextView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(viewBG).offset(CCGetRealFromPt(20));
                    make.top.mas_equalTo(viewBG).offset(CCGetRealFromPt(20));
                    make.bottom.mas_equalTo(viewBG).offset(-CCGetRealFromPt(20));
                    make.right.mas_equalTo(viewBG).offset(-CCGetRealFromPt(20));
                }];
            }
            referenceViewPreview = viewBG;
        }
    }
    
    NSString *msgStr = @"答卷提交成功!";
    CGSize msgSizeNum = [self getSizeByStr:msgStr minFontHeight:CCGetRealFromPt(28) maxFontHeight:CCGetRealFromPt(28) UIFont:[UIFont boldSystemFontOfSize:FontSize_28] textMaxWidth:textMaxWidth lineSpacing:CCGetRealFromPt(0)];
    
    _msgLabel = [[UILabel alloc] init];
    _msgLabel.text = msgStr;
    _msgLabel.textColor = CCRGBColor(23,188,47);
    _msgLabel.textAlignment = NSTextAlignmentCenter;
    _msgLabel.font = [UIFont boldSystemFontOfSize:FontSize_28];
    _msgLabel.hidden = YES;
    [_scrollView addSubview:_msgLabel];
    
    [_msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_scrollView);
        if(self.isScreenLandScape) {
            make.top.mas_equalTo(referenceViewPreview.mas_bottom).offset(CCGetRealFromPt(67));
        } else {
            make.top.mas_equalTo(referenceViewPreview.mas_bottom).offset(CCGetRealFromPt(103));
        }
        make.width.mas_equalTo(self.scrollView);
        make.height.mas_equalTo(msgSizeNum.height);
    }];

    [_scrollView addSubview:self.submitBtn];
    [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.scrollView);
        make.top.mas_equalTo(ws.msgLabel.mas_bottom).offset(CCGetRealFromPt(30));
        make.width.mas_equalTo(CCGetRealFromPt(180));
        make.height.mas_equalTo(CCGetRealFromPt(60));
    }];
    
    [self layoutIfNeeded];

    self.scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _submitBtn.frame.origin.y + CCGetRealFromPt(60) + CCGetRealFromPt(30));
}

- (BOOL) textView: (UITextView *) textView  shouldChangeTextInRange: (NSRange) range replacementText: (NSString *)text {
    if( [ @"\n" isEqualToString: text]){
        [_scrollView endEditing:YES];
        return NO;
    }
    return YES;
}

- (void)dealSingleTap:(UITapGestureRecognizer *)tap {
    [_scrollView endEditing:YES];
}

/**
 开始编辑
 @param textView textView
 */
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

/**
 结束编辑
 @param textView textView
 */
-(void)textViewDidEndEditing:(UITextView *)textView
{
    WS(ws)
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = CCGetRealFromPt(20);// 字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],
                                 NSParagraphStyleAttributeName:paragraphStyle};
    textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
    
    CGSize size = [self getSizeByStr:textView.text minFontHeight:CCGetRealFromPt(26) maxFontHeight:CCGetRealFromPt(26) UIFont:[UIFont systemFontOfSize:FontSize_26] textMaxWidth:textView.frame.size.width lineSpacing:CCGetRealFromPt(23)];
    
    UIView *viewBG = textView.superview;
    NSInteger tag = viewBG.tag + 100;
    UIView *referenceView = [_scrollView viewWithTag:tag];
    
    CGFloat height = size.height + CCGetRealFromPt(20) * 2 > CCGetRealFromPt(178) ? (size.height + CCGetRealFromPt(20) * 2) : CCGetRealFromPt(178);
    if(height != viewBG.frame.size.height) {
        CGSize contentSize = self.scrollView.contentSize;
        CGSize viewBGSize = viewBG.frame.size;
        [viewBG mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_scrollView.mas_left).offset(CCGetRealFromPt(70));
            make.top.mas_equalTo(referenceView.mas_bottom).offset(CCGetRealFromPt(40));
            if(ws.isScreenLandScape) {
                make.width.mas_equalTo(CCGetRealFromPt(770));
            } else {
                make.width.mas_equalTo(CCGetRealFromPt(570));
            }
            make.height.mas_equalTo(height);
        }];
        
        [self layoutIfNeeded];
        
        self.scrollView.contentSize = CGSizeMake(contentSize.width, contentSize.height - viewBGSize.height + height);
    }
    
    CGPoint point = ws.scrollView.contentOffset;
    CGFloat contentOffSize = point.y;
    if(point.y < 0) {
        contentOffSize = 0;
    } else if (point.y > self.scrollView.contentSize.height - self.scrollView.frame.size.height) {
        contentOffSize = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
        contentOffSize = contentOffSize >= 0 ? contentOffSize : 0;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        [ws.scrollView setContentOffset:CGPointMake(0, contentOffSize)];
    } completion:^(BOOL finished) {
    }];
    
    [textView resignFirstResponder];
}

-(void)commitSuccess:(BOOL)success {
    if(success) {
        _msgLabel.text = @"答卷提交成功!";
        _msgLabel.hidden = NO;
        _msgLabel.textColor = CCRGBColor(23,188,47);
    } else {
        _msgLabel.text = @"网络异常，提交失败，请重试。";
        _msgLabel.hidden = NO;
        _msgLabel.textColor = CCRGBColor(224,58,58);
    }
}

/**
 内容发生改变编辑 自定义文本框placeholder
 有时候我们要控件自适应输入的文本的内容的高度，只要在textViewDidChange的代理方法中加入调整控件大小的代理即可
 @param textView textView
 */
- (void)textViewDidChange:(UITextView *)textView
{

}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.selectedTextView = textView;
//    self.selectedTextView.backgroundColor = CCRGBColor(255, 0, 0);
    return YES;
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
    _msgLabel.hidden = YES;
    
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
    NSLog(@"y = %f",y);
//    CGFloat x = _keyboardRect.size.width;
    //NSLog(@"键盘高度是  %d",(int)y);
    //NSLog(@"键盘宽度是  %d",(int)x);
    if ([self.selectedTextView isFirstResponder]) {
        WS(ws)
        UIView *view = self.selectedTextView.superview;
//        CGPoint point = [self convertPoint:self.scrollView.frame.origin fromView:self.bgView];
        CGFloat scrollKeyboard = self.frame.size.height - (self.view.frame.origin.y + self.view.frame.size.height + y);
//        NSLog(@"scrollKeyboard = %f",scrollKeyboard);
//        self.selectedTextView.backgroundColor = CCRGBColor(255, 0, 0);
        CGFloat contentOffSize = view.frame.origin.y + view.frame.size.height - self.scrollView.frame.size.height - scrollKeyboard;

        [UIView animateWithDuration:0.25f animations:^{
            [ws.scrollView setContentOffset:CGPointMake(0, contentOffSize)];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self hideKeyboard];
}

-(void)hideKeyboard {
//    WS(ws)
//    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.and.left.and.bottom.mas_equalTo(ws);
//        make.height.mas_equalTo(CCGetRealFromPt(110));
//    }];
//    
//    [_publicTableView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.and.right.and.left.mas_equalTo(ws);
//        make.bottom.mas_equalTo(ws.contentView.mas_top);
//    }];
//    
//    [UIView animateWithDuration:0.25f animations:^{
//        [ws layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        
//    }];
}

-(UIScrollView *)scrollView {
    if(!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.backgroundColor = CCClearColor;
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

-(CGSize)getSizeByStr:(NSString *)str minFontHeight:(NSInteger)minFontHeight maxFontHeight:(NSInteger)maxFontHeight UIFont:(UIFont *)font textMaxWidth:(CGFloat)textMaxWidth lineSpacing:(CGFloat)lineSpacing {
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    style.minimumLineHeight = CCGetRealFromPt(minFontHeight);
//    style.maximumLineHeight = CCGetRealFromPt(maxFontHeight);
    style.lineSpacing = lineSpacing;
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dict = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                    context:nil].size;
    return CGSizeMake(ceilf(textSize.width),ceilf(textSize.height));
}

-(UIButton *)closeBtn {
    if(!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.backgroundColor = CCClearColor;
        _closeBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"qs_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

-(UIButton *)submitBtn {
    if(_submitBtn == nil) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitBtn.backgroundColor = CCRGBColor(255,102,51);
        if (self.isStastic) {
//            [_submitBtn setTitle:@"统计信息" forState:UIControlStateNormal];
//            _submitBtn.userInteractionEnabled = NO;
            _submitBtn.hidden = YES;
        } else {
            
            [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        }
        [_submitBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_submitBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_submitBtn.layer setMasksToBounds:YES];
        [_submitBtn.layer setBorderWidth:2.0];
        [_submitBtn.layer setBorderColor:[CCRGBColor(252,92,61) CGColor]];
        [_submitBtn.layer setCornerRadius:CCGetRealFromPt(30)];
        [_submitBtn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_submitBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(255,102,51)] forState:UIControlStateNormal];
        [_submitBtn setBackgroundImage:[self createImageWithColor:CCRGBAColor(255,102,51,0.4)] forState:UIControlStateHighlighted];
    }
    return _submitBtn;
}

-(void)submitAction {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for(UIButton *button in self.buttonArray) {
        if(button.selected == YES) {
            NSArray *separatedArray = [button.userid componentsSeparatedByString:@"-"];
            NSString *subjectId = separatedArray[4];
            BOOL flag = NO;
            NSMutableDictionary *dicGet = nil;
            for(NSMutableDictionary *dic in array) {
                if([dic[@"subjectId"] isEqualToString:subjectId]) {
                    dicGet = dic;
                    flag = YES;
                    break;
                }
            }
            if(flag == NO) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                dic[@"subjectId"] = subjectId;
                dicGet = dic;
                [array addObject:dic];
            }
            //题号-类型（0：单选，1:多选）-选项个数-选项索引值-题目ID-选项ID
            if([separatedArray[1] intValue] == 0) {
                NSString *str = dicGet[@"selectedOptionId"];
                if(StrNotEmpty(str)) {
                } else {
                    dicGet[@"selectedOptionId"] = separatedArray[5];
                }
            } else {
                NSString *str = dicGet[@"selectedOptionIds"];
                if(StrNotEmpty(str)) {
                    dicGet[@"selectedOptionIds"] = [NSString stringWithFormat:@"%@,%@",str,separatedArray[5]];
                } else {
                    dicGet[@"selectedOptionIds"] = separatedArray[5];
                }
            }
            
        }
    }
    
    if(_selectQuestionCount != [array count]) {
        //TODO
        _msgLabel.text = @"您尚有部分题目未回答，请检查。";
        _msgLabel.hidden = NO;
        _msgLabel.textColor = CCRGBColor(224,58,58);
        return;
    }
    
    for(UITextView *textView in self.textViewArray) {
        NSString *subjectId = textView.userid;
        BOOL flag = NO;
        NSMutableDictionary *dicGet = nil;
        for(NSMutableDictionary *dic in array) {
            if([dic[@"subjectId"] isEqualToString:subjectId]) {
                dicGet = dic;
                flag = YES;
                break;
            }
        }
        if(flag == NO) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            dic[@"subjectId"] = subjectId;
            dicGet = dic;
            [array addObject:dic];
        }
        NSString *str = textView.text;
//        NSLog(@"---str1=%@--",str);
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        NSLog(@"---str2=%@--",str);
        if(StrNotEmpty(str)) {
            if (str.length > 300) {
                _msgLabel.text = @"问答回复最多支持300个字符！";
                _msgLabel.hidden = NO;
                _msgLabel.textColor = CCRGBColor(224,58,58);
                return;
            } else {
                dicGet[@"answerContent"] = str;
            }
        } else {
            _msgLabel.text = @"您尚有部分题目未回答，请检查。";
            _msgLabel.hidden = NO;
            _msgLabel.textColor = CCRGBColor(224,58,58);
            return;
        }
    }
    NSLog(@"--------------------------------------------");
    NSLog(@"%@",array);
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    dic[@"subjectsAnswer"] = array;
    if(self.commitblock) {
        self.commitblock(dic);
        if (self.submitedAction == 1) {
            [_submitBtn setTitle:@"已提交" forState:UIControlStateNormal];
            _submitBtn.userInteractionEnabled = NO;
            for(UILabel *correctLabel in self.correctLabelArray) {
                correctLabel.hidden = NO;
            }
        }

    }
}

-(void)selectBtnClicked:(UIButton *)sender {
    bool selected = sender.selected;
    if(selected == YES) {
        sender.selected = NO;
        return;
    }
    sender.selected = YES;
    _msgLabel.hidden = YES;
    NSString *str = sender.userid;
    NSArray *strArr = [str componentsSeparatedByString:@"-"];
    if([strArr[1] intValue] == 0) {
        for(int i = 0;i < [strArr[2] intValue]; i++) {
            NSString *userId = [NSString stringWithFormat:@"%@-%@-%@-%d",strArr[0],strArr[1],strArr[2],i];
            if(![userId isEqualToString:[self separatedString:sender.userid]]) {
                for(UIButton *button in self.buttonArray) {
                    if([userId isEqualToString:[self separatedString:button.userid]]) {
                        button.selected = NO;
                    }
                }
            }
        }
    }
}

-(NSString *)separatedString:(NSString *)userInfoId {
    NSArray *strArr = [userInfoId componentsSeparatedByString:@"-"];
    return [NSString stringWithFormat:@"%@-%@-%@-%@",strArr[0],strArr[1],strArr[2],strArr[3]];
}

- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(void)closeBtnClicked {
    [self removeObserver];
    if(self.closeblock) {
        self.closeblock();
    }
}

-(UILabel *)label {
    if(!_label) {
        _label = [UILabel new];
        _label.text = self.isStastic? @"问卷统计":@"问卷调查";
        _label.textColor = CCRGBColor(51,51,51);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:FontSize_36];
    }
    return _label;
}

-(UIView *)lineView {
    if(!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = CCRGBAColor(255,102,51,0.5);
    }
    return _lineView;
}

-(UIImageView *)questionImage {
    if(!_questionImage) {
        _questionImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qs_pic_nav"]];
        _questionImage.backgroundColor = CCClearColor;
        _questionImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _questionImage;
}

@end
