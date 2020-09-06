//
//  VoteViewResult.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/25.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "VoteViewResult.h"

@interface VoteViewResult()

@property(nonatomic,strong)UIImageView              *topBgView;//顶部视图
@property(nonatomic,strong)UILabel                  *topLabel;//顶部标题
@property(nonatomic,strong)UILabel                  *titleLabel;//标题label
@property(nonatomic,strong)UIButton                 *closeBtn;//关闭按钮
@property(nonatomic,strong)UIView                   *labelBgView;//文本背景视图
@property(nonatomic,strong)UILabel                  *centerLabel;//提示label
@property(nonatomic,strong)UIView                   *view;

@property(nonatomic,strong)UILabel                  *myLabel;//我的答案
@property(nonatomic,strong)UILabel                  *correctLabel;//正确答案
@property(nonatomic,assign)NSDictionary             *resultDic;//结果字典
@property(nonatomic,assign)NSInteger                mySelectIndex;//自己选择的答案(单选)
@property(nonatomic,strong)NSMutableArray           *mySelectIndexArray;//自己选择的答案(多选)
@property(nonatomic,assign)BOOL                     isScreenLandScape;//是否是全屏

@end

//答题
@implementation VoteViewResult

/**
 初始化方法
 
 @param resultDic 答题结果字典
 @param mySelectIndex 我选择的答案
 @param mySelectIndexArray 我选择的答案数组
 @param isScreenLandScape 是否全屏
 @return self
 */
-(instancetype) initWithResultDic:(NSDictionary *)resultDic mySelectIndex:(NSInteger)mySelectIndex mySelectIndexArray:(NSMutableArray *)mySelectIndexArray isScreenLandScape:(BOOL)isScreenLandScape{
    self = [super init];
    if(self) {
        self.isScreenLandScape      = isScreenLandScape;//是否是全屏
        self.mySelectIndex          = mySelectIndex;//自己选择的答案(单选)
        self.resultDic              = resultDic;//结果字典
        self.mySelectIndexArray     = [mySelectIndexArray mutableCopy];//自己选择的答案(多选)
        [self initUI];
    }
    return self;
}
#pragma mark - 添加背景视图
/**
 添加背景视图
 */
-(void)addBgView{
    //初始化view
    _view = [[UIView alloc]init];
    _view.backgroundColor = [UIColor whiteColor];
    _view.layer.cornerRadius = CCGetRealFromPt(10);
    [self addSubview:_view];
    NSInteger count = [self.resultDic[@"statisics"] count];
    if(!self.isScreenLandScape) {//竖屏模式下view的约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
//            make.top.mas_equalTo(self).offset(CCGetRealFromPt(567));
            make.centerY.mas_equalTo(self).offset(CCGetRealFromPt(180));
            make.width.mas_equalTo(CCGetRealFromPt(710));
            if (count >= 2 && count <=5) {
                make.height.mas_equalTo(CCGetRealFromPt(491) + CCGetRealFromPt((count - 2) * 68));
            }
        }];
    } else {//横屏模式下view的约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
            make.width.mas_equalTo(CCGetRealFromPt(710));
            if (count >= 2 && count <=5) {
                make.height.mas_equalTo(CCGetRealFromPt(491) + CCGetRealFromPt((count - 2) * 68));
            }
        }];
    }
}
/**
 计算多少人回答

 @param count 计算过的人数
 */
-(void)getAnswerCount:(int)count{
    //计算多少人回答
    NSNumber *answerCount = self.resultDic[@"answerCount"];
    if(answerCount != nil) {
        self.centerLabel.text = [NSString stringWithFormat:@"共%d人回答",[answerCount intValue]];
    } else {
        self.centerLabel.text = [NSString stringWithFormat:@"共%d人回答",(count)];
    }
}

/**
 判断自己的答案是否正确,并且设置自己答案的颜色

 @return 是否正确,BOOL值
 */
-(BOOL)judgeAnswer{
    BOOL correct = NO;
    if([self.resultDic[@"correctOption"] isKindOfClass:[NSNumber class]]) {
        if(_mySelectIndex == [self.resultDic[@"correctOption"] integerValue]) {
            self.myLabel.textColor = CCRGBColor(18,184,143);
            correct = YES;
        } else {
            self.myLabel.textColor = CCRGBColor(252,81,43);
            correct = NO;
        }
    } else if ([self.resultDic[@"correctOption"] isKindOfClass:[NSArray class]]) {
        if([self sameWithArrayA:self.resultDic[@"correctOption"] arrayB:self.mySelectIndexArray]) {
            self.myLabel.textColor = CCRGBColor(18,184,143);
            correct = YES;
        } else {
            self.myLabel.textColor = CCRGBColor(252,81,43);
            correct = NO;
        }
    }
    self.correctLabel.textColor = CCRGBColor(18,184,143);
    return correct;
}
/**
 设置单选的label样式
 */
-(void)setSingelAnswerStyle{
    if(_mySelectIndex != -1) {
        self.myLabel.text = [NSString stringWithFormat:@"%@%c", VOTERESULT_MYANSWER,((int)_mySelectIndex + 'A')];
    }
    if([self.resultDic[@"correctOption"] intValue] != -1) {
        self.correctLabel.text = [NSString stringWithFormat:@"%@%c", VOTERESULT_CORRECTANSWER,[self.resultDic[@"correctOption"] intValue] + 'A'];
    }
}
/**
 设置多选的label样式
 */
-(void)setMultipleAnswerStyle{
    NSArray *sortedMySelectIndexArray = [self.mySelectIndexArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    NSArray *sortedResultArray = [self.resultDic[@"correctOption"] sortedArrayUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    if(sortedMySelectIndexArray != nil && [sortedMySelectIndexArray count] > 0) {
        NSString *str = VOTERESULT_MYANSWER;
        for(id num in sortedMySelectIndexArray) {
            str = [NSString stringWithFormat:@"%@%c",str,[num intValue] + 'A'];
        }
        self.myLabel.text = str;
    }
    if(sortedResultArray != nil && [sortedResultArray count] > 0) {
        NSString *str = VOTERESULT_CORRECTANSWER;
        for(id num in sortedResultArray) {
            str = [NSString stringWithFormat:@"%@%c",str,[num intValue] + 'A'];
        }
        self.correctLabel.text = str;
    }
}

/**
 设置判断题我的答案图片样式

 @param correct 答案是否正确
 */
-(void)setCheckingMyAnswerStyle:(BOOL)correct{
    //设置自己答案的图片
    UIImageView *imageViewMy = nil;
    if(correct == YES) {
        if(_mySelectIndex == 0) {
            imageViewMy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inconformity_right"]];
        } else if(_mySelectIndex == 1) {
            imageViewMy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qs_wrong_same"]];
        }
    } else if(correct == NO) {
        if(_mySelectIndex == 0) {
            imageViewMy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"agreed_right"]];
        } else if(_mySelectIndex == 1) {
            imageViewMy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qs_wrong_different"]];
        }
    }
    //更新我的答案约束
    [_myLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).offset(-CCGetRealFromPt(418));
        make.left.mas_equalTo(self.view).offset(CCGetRealFromPt(70));
        make.top.mas_equalTo(self.view).offset(CCGetRealFromPt(260));
        make.height.mas_equalTo(CCGetRealFromPt(32));
    }];
    //设置图片的约束
    imageViewMy.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageViewMy];
    [imageViewMy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(CCGetRealFromPt(302));
        make.right.mas_equalTo(self.view).offset(-CCGetRealFromPt(370));
        make.centerY.mas_equalTo(self.myLabel);
        make.height.mas_equalTo(CCGetRealFromPt(32));
    }];
}

/**
 设置判断题正确答案图片样式
 */
-(void)setCheckingCorrectAnswerStyle{
    UIImageView *imageViewCorrect = nil;
    if([self.resultDic[@"correctOption"] integerValue] == 0) {
        imageViewCorrect = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inconformity_right"]];
    } else if([self.resultDic[@"correctOption"] integerValue] == 1) {
        imageViewCorrect = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qs_wrong_same"]];
    }
    imageViewCorrect.contentMode = UIViewContentModeScaleAspectFit;
    
    //设置正确答案图片的约束
    [self.view addSubview:imageViewCorrect];
    [imageViewCorrect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(CCGetRealFromPt(531));
        make.right.mas_equalTo(self.view).offset(-CCGetRealFromPt(141));
        make.centerY.mas_equalTo(self.myLabel);
        make.height.mas_equalTo(CCGetRealFromPt(32));
    }];
}
/**
 添加其他视图
 */
-(void)addOtherViews{
    //选择答案的人数
    int result_1 = 0,result_2 = 0,result_3 = 0,result_4 = 0,result_5 = 0;
    //选择答案的百分比
    int percent_1 = 0,percent_2 = 0,percent_3 = 0,percent_4 = 0,percent_5 = 0;
    NSArray *array = self.resultDic[@"statisics"];
    //取出数组中的数据
    for(NSDictionary * dic in array) {
        if([dic[@"option"] integerValue] == 0) {
            result_1 = [dic[@"count"] intValue];
            percent_1 = [dic[@"percent"] floatValue];
        } else if([dic[@"option"] integerValue]== 1){
            result_2 = [dic[@"count"] intValue];
            percent_2 = [dic[@"percent"] floatValue];
        } else if([dic[@"option"] integerValue] == 2){
            result_3 = [dic[@"count"] intValue];
            percent_3 = [dic[@"percent"] floatValue];
        } else if([dic[@"option"] integerValue] == 3) {
            result_4 = [dic[@"count"] intValue];
            percent_4 = [dic[@"percent"] floatValue];
        } else if([dic[@"option"] integerValue] == 4) {
            result_5 = [dic[@"count"] intValue];
            percent_5 = [dic[@"percent"] floatValue];
        }
    }
    //计算多少人回答
    [self getAnswerCount:(result_1 + result_2 + result_3 + result_4 + result_5)];
    //判断自己的答案是否正确
    BOOL correct = [self judgeAnswer];
    
    NSInteger arrayCount = [array count];
    if(arrayCount >= 3) {
        if([self.resultDic[@"correctOption"] isKindOfClass:[NSNumber class]]) {//如果是单选
            [self setSingelAnswerStyle];
        } else if([self.resultDic[@"correctOption"] isKindOfClass:[NSArray class]]) {//如果是多选
            [self setMultipleAnswerStyle];
        }
        //设置统计柱状图和人数统计
        if(arrayCount >= 3) {
            [self addProgressViewWithLeftStr:@"A:" rightStr:[NSString stringWithFormat:@"%d人 (%d%%)",result_1,percent_1] index:1 percent:percent_1];
            [self addProgressViewWithLeftStr:@"B:" rightStr:[NSString stringWithFormat:@"%d人 (%d%%)",result_2,percent_2] index:2 percent:percent_2];
            [self addProgressViewWithLeftStr:@"C:" rightStr:[NSString stringWithFormat:@"%d人 (%d%%)",result_3,percent_3] index:3 percent:percent_3];
        }
        if(arrayCount >= 4) {
            [self addProgressViewWithLeftStr:@"D:" rightStr:[NSString stringWithFormat:@"%d人 (%d%%)",result_4,percent_4] index:4 percent:percent_4];
        }
        if(arrayCount >= 5) {
            [self addProgressViewWithLeftStr:@"E:" rightStr:[NSString stringWithFormat:@"%d人 (%d%%)",result_5,percent_5] index:5 percent:percent_5];
        }
    } else if(arrayCount == 2) {
        //设置自己的答案的图片
        [self setCheckingMyAnswerStyle:correct];
        
        //设置正确答案的图片样式
        [self setCheckingCorrectAnswerStyle];
        
        //添加统计图
        [self addProgressViewWithLeftStr:@"√:" rightStr:[NSString stringWithFormat:@"%d人 (%d%%)",result_1,percent_1] index:1 percent:percent_1];
        [self addProgressViewWithLeftStr:@"X:" rightStr:[NSString stringWithFormat:@"%d人 (%d%%)",result_2,percent_2] index:2 percent:percent_2];
    }
}
#pragma mark - 设置UI布局
-(void)initUI {
    self.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
    //添加背景视图
    [self addBgView];
    
    //顶部视图
    [self.view addSubview:self.topBgView];
    [_topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.height.mas_equalTo(CCGetRealFromPt(80));
    }];
    
    //关闭按钮
    [self.topBgView addSubview:self.closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topBgView).offset(-CCGetRealFromPt(20));
        make.centerY.mas_equalTo(self.topBgView);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(56),CCGetRealFromPt(56)));
    }];
    
    //头部label
    [self.topBgView addSubview:self.topLabel];
    [_topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.topBgView);
    }];
    
    //答题卡提示
    [self.view addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(CCGetRealFromPt(120));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(710), CCGetRealFromPt(36)));
    }];
    
    //label背景
    [self.view addSubview:self.labelBgView];
    [_labelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(CCGetRealFromPt(180));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(390), CCGetRealFromPt(40)));
    }];
    
    //提示label
    [_labelBgView addSubview:self.centerLabel];
    [_centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.labelBgView);
    }];
    
    //我的答案
    [self.view addSubview:self.myLabel];
    [_myLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_centerX).offset(-CCGetRealFromPt(30));
        make.left.mas_equalTo(self.view).offset(CCGetRealFromPt(70));
        make.top.mas_equalTo(self.view).offset(CCGetRealFromPt(260));
        make.height.mas_equalTo(CCGetRealFromPt(32));
    }];
    
    //正确答案
    [self.view addSubview:self.correctLabel];
    [_correctLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_centerX).offset(CCGetRealFromPt(20));
        make.top.mas_equalTo(self.view).offset(CCGetRealFromPt(260));
        make.height.mas_equalTo(CCGetRealFromPt(32));
    }];
    
    //添加其他视图
    [self addOtherViews];

    [self layoutIfNeeded];
}


/**
 判断自己选择的答案和正确答案是否相同

 @param arrayA 自己选择的答案
 @param arrayB 正确答案
 @return 返回结果，BOOL值
 */
-(BOOL)sameWithArrayA:(NSMutableArray *)arrayA arrayB:(NSMutableArray *)arrayB {
    if([arrayA count] != [arrayB count]) {
        return NO;
    }
    for(id item in arrayA) {
        if(![arrayB containsObject:item]) {
            return NO;
        }
    }
    return YES;
}

/**
 设置答案选择人数的柱状图

 @param leftStr 左侧文本显示文字
 @param rightStr 右侧文本显示文字
 @param index 答案的下标
 @param percent 设置柱状图填充样式
 */
-(void)addProgressViewWithLeftStr:(NSString *)leftStr rightStr:(NSString *)rightStr index:(NSInteger)index     percent:(CGFloat)percent{
    //过滤rightStr
//TODO下面两行
    [self filterWithStr:rightStr filterStr:@"(0.0%)"];
    [self filterWithStr:rightStr filterStr:@"(100.0%)"];
    
    //添加进度条
    [self addProgressViewWithIndex:index percent:percent];
    
    //添加leftLabel
    [self addLeftLabel:leftStr index:index];
    
    //添加rightLabel
    [self addRightLabel:rightStr index:index];

}

/**
 过滤字符串

 @param percentStr 需要被过滤的字符串
 @param filterStr 需要过滤的字段
 */
-(void)filterWithStr:(NSString *)percentStr filterStr:(NSString *)filterStr{
    if([percentStr rangeOfString:filterStr].location != NSNotFound) {
        percentStr = [percentStr stringByReplacingOccurrencesOfString:filterStr withString:filterStr];
    }
}

/**
 添加进度条

 @param index 进度条的位置
 @param percent 进度条百分比
 */
-(void)addProgressViewWithIndex:(NSInteger)index percent:(CGFloat)percent{
    //添加进度条背景
    UIView *progressBgView = [[UIView alloc] init];
    progressBgView.backgroundColor = [UIColor colorWithHexString:@"#f0f1f2" alpha:1.f];
    [self.view addSubview:progressBgView];
    [progressBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(CCGetRealFromPt(85));
        make.top.mas_equalTo(self.myLabel.mas_bottom).offset(CCGetRealFromPt(50 + (index - 2) * 68));
        make.right.mas_equalTo(self.view).offset(-CCGetRealFromPt(200));
        make.height.mas_equalTo(CCGetRealFromPt(30));
    }];
    [self layoutIfNeeded];
    [progressBgView layoutIfNeeded];
    
    
    //判断当前选项是否是正确答案
    
    //添加进度条
    UIView *progressView = [[UIView alloc] init];
    progressView.backgroundColor = [self getColorWithProgressIndex:index];
    [self.view addSubview:progressView];
    progressView.frame = CGRectMake(CCGetRealFromPt(85), progressBgView.frame.origin.y, 0, CCGetRealFromPt(30));
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.mas_equalTo(progressBgView);
        make.width.mas_equalTo(progressBgView).multipliedBy(percent / 100.0f);
    }];
    
    //加载过度动画
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        progressView.frame = CGRectMake(CCGetRealFromPt(85), progressBgView.frame.origin.y, progressBgView.frame.size.width * percent / 100.0f, CCGetRealFromPt(30));
    } completion:nil];
}

/**
 获取进度条的背景颜色

 @param index 进度条颜色下标
 @return 进度条的颜色
 */
-(UIColor *)getColorWithProgressIndex:(NSInteger)index{
    UIColor *color = [UIColor colorWithHexString:@"#ff643d" alpha:1.f];
    if([self.resultDic[@"correctOption"] isKindOfClass:[NSNumber class]]) {//如果是单选
        if ([self.resultDic[@"correctOption"] integerValue] == index - 1) {//判断此条数据是否是正确答案
            return [UIColor colorWithHexString:@"#17bc2f" alpha:1.f];//返回正确答案的颜色
        }
    } else {
        NSArray *arr = self.resultDic[@"correctOption"];
        for (int i = 0; i < arr.count; i++) {
            if ([arr[i]integerValue] == index - 1) {
                return [UIColor colorWithHexString:@"#17bc2f" alpha:1.f];//返回正确答案的颜色
            }
        }
    }
    return color;
}
/**
 添加leftLabel

 @param leftStr 左侧label的text
 @param index label的下标
 */
-(void)addLeftLabel:(NSString *)leftStr index:(NSInteger)index{
    UILabel *leftLabel = [[UILabel alloc] init];
    leftLabel.text = leftStr;
    leftLabel.textColor = CCRGBColor(51,51,51);
    leftLabel.textAlignment = NSTextAlignmentLeft;
    leftLabel.font = [UIFont boldSystemFontOfSize:FontSize_24];
    
    [self.view addSubview:leftLabel];
    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(CCGetRealFromPt(31));
        make.top.mas_equalTo(self.myLabel.mas_bottom).offset(CCGetRealFromPt(50 + (index - 2) * 68));
        make.right.mas_equalTo(self.view).offset(-CCGetRealFromPt(635));
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
}
/**
 添加rightLabel

 @param rightStr 右侧label的text
 @param index 视图下标
 */
-(void)addRightLabel:(NSString *)rightStr index:(NSInteger)index{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:rightStr];
    NSRange range = [rightStr rangeOfString:@"人"];
    [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(102,102,102) range:NSMakeRange(0, range.location + range.length)];
    [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51,51,51) range:NSMakeRange(range.location + range.length, rightStr.length - (range.location + range.length))];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, rightStr.length)];
    
    UILabel *rightLabel = [[UILabel alloc] init];
    rightLabel.attributedText = text;
    rightLabel.textAlignment = NSTextAlignmentLeft;
    rightLabel.font = [UIFont systemFontOfSize:FontSize_24];
    [self.view addSubview:rightLabel];
    [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_right).offset(-CCGetRealFromPt(184));
        make.right.mas_equalTo(self.view).offset(-CCGetRealFromPt(10));
        make.height.mas_equalTo(CCGetRealFromPt(24));
        make.top.mas_equalTo(self.myLabel.mas_bottom).offset(CCGetRealFromPt(50 + (index - 2) * 68));
    }];
}
#pragma mark - 懒加载
//关闭按钮
-(UIButton *)closeBtn {
    if(!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.backgroundColor = CCClearColor;
        _closeBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

-(void)closeBtnClicked {
    [self removeFromSuperview];
}
//顶部label
-(UILabel *)topLabel {
    if(!_topLabel) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.text = VOTERESULT;
        _topLabel.textColor = CCRGBColor(51,51,51);
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.font = [UIFont systemFontOfSize:FontSize_36];
    }
    return _topLabel;
}
//我的答案
-(UILabel *)myLabel {
    if(!_myLabel) {
        _myLabel = [[UILabel alloc] init];
        _myLabel.text = VOTERESULT_MYANSWER;
        _myLabel.textAlignment = NSTextAlignmentRight;
        _myLabel.font = [UIFont systemFontOfSize:FontSize_32];
    }
    return _myLabel;
}
//正确答案
-(UILabel *)correctLabel {
    if(!_correctLabel) {
        _correctLabel = [[UILabel alloc] init];
        _correctLabel.text = VOTERESULT_CORRECTANSWER;
        _correctLabel.textAlignment = NSTextAlignmentLeft;
        _correctLabel.font = [UIFont systemFontOfSize:FontSize_32];
    }
    return _correctLabel;
}
//中间的label
-(UILabel *)centerLabel {
    if(!_centerLabel) {
        _centerLabel = [[UILabel alloc] init];
        _centerLabel.textColor = CCRGBColor(102,102,102);
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.font = [UIFont systemFontOfSize:FontSize_24];
    }
    return _centerLabel;
}

/**
 color转image

 @param color 需要转换的color
 @return 转换后的image
 */
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
//label背景视图
-(UIView *)labelBgView {
    if(!_labelBgView) {
        _labelBgView = [[UIView alloc] init];
        _labelBgView.backgroundColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.f];
        _labelBgView.layer.masksToBounds = YES;
        _labelBgView.layer.cornerRadius = CCGetRealFromPt(20);
        _labelBgView.layer.borderColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.f].CGColor;
        _labelBgView.layer.borderWidth = CCGetRealFromPt(1);
    }
    return _labelBgView;
}

//顶部背景视图
-(UIImageView *)topBgView {
    if(!_topBgView) {
        _topBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bar"]];
        _topBgView.backgroundColor = CCClearColor;
        _topBgView.userInteractionEnabled = YES;
        // 阴影颜色
        _topBgView.layer.shadowColor = [UIColor grayColor].CGColor;
        // 阴影偏移，默认(0, -3)
        _topBgView.layer.shadowOffset = CGSizeMake(0, 3);
        // 阴影透明度，默认0.7
        _topBgView.layer.shadowOpacity = 0.2f;
        // 阴影半径，默认3
        _topBgView.layer.shadowRadius = 3;
        _topBgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _topBgView;
}
//提示标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = VOTERESULT_VOTEOVER;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#1e1f21" alpha:1.f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_36];
    }
    return _titleLabel;
}
@end

