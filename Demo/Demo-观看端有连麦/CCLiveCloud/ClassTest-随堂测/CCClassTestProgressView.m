//
//  CCClassTestProgressView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/27.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCClassTestProgressView.h"
#import "NSString+Extension.h"
@interface CCClassTestProgressView ()
@property (nonatomic, strong) NSDictionary   * resultDic;//统计结果字典
@property (nonatomic, strong) NSMutableArray * viewArr;//存放视图的数组
@property (nonatomic, assign) BOOL           isScreen;//是否全屏
@end
@implementation CCClassTestProgressView

-(instancetype)initWithFrame:(CGRect)frame ResultDic:(NSDictionary *)dic isScreen:(BOOL)isScreen{
    if (self = [super initWithFrame:frame]) {
        _resultDic = dic;
        _viewArr = [NSMutableArray array];
        self.isScreen = isScreen;
        [self setUpUI];
    }
    return self;
}
#pragma mark - 设置布局
-(void)setUpUI{
    int i = 0;
    float originY = self.isScreen?27:34;
    for (NSDictionary *dic in _resultDic[@"practice"][@"options"]) {
        NSInteger type = [_resultDic[@"practice"][@"type"] integerValue];
        NSString *text = [NSString stringWithFormat:@"%@:", [NSString stringWithFilterStr:dic[@"index"] withType:type ]];
        //处理text
        UILabel *label = [UILabel labelWithText:text fontSize:[UIFont systemFontOfSize:12] textColor:CCRGBColor(51, 51, 51) textAlignment:NSTextAlignmentCenter];
        label.frame = CGRectMake(16, i * originY, 22, 12);
        [self addSubview:label];
        
        //处理背景视图
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = CCRGBColor(240, 241, 242).CGColor;
        layer.frame = CGRectMake(43, i * originY, 239, 15);
        [self.layer addSublayer:layer];
        
        float percent = [dic[@"percent"] floatValue];
        //添加进度条
        CALayer *progressLayer = [CALayer layer];
        if ([dic[@"isCorrect"] intValue] == 1) {
            progressLayer.backgroundColor = CCRGBColor(23, 188, 47).CGColor;
        }else{
            progressLayer.backgroundColor = CCRGBColor(255, 100, 61).CGColor;
        }
        progressLayer.frame = CGRectMake(43, i * originY, 239 * percent / 100, 15);
        [self.layer addSublayer:progressLayer];
        
        //添加计算label
        UILabel *countLabel = [UILabel labelWithText: [NSString stringWithFormat:@"%d人", [dic[@"count"] intValue]] fontSize:[UIFont systemFontOfSize:13] textColor:CCRGBColor(121, 128, 139) textAlignment:NSTextAlignmentRight];
        countLabel.frame = CGRectMake(230, i * originY, 42, 13);
        [self addSubview:countLabel];
        
        //添加百分比label
        NSString *textStr = [self dealWithPercent:[NSString stringWithFormat:@"%@", dic[@"percent"]]];
        UILabel *percentLabel = [UILabel labelWithText:textStr fontSize:[UIFont systemFontOfSize:13] textColor:CCRGBColor(51, 51, 51) textAlignment:NSTextAlignmentLeft];
        percentLabel.frame = CGRectMake(292, i * originY, 60, 13);
        [self addSubview:percentLabel];
        
        NSArray *arr = [NSArray arrayWithObjects:label, layer, progressLayer, countLabel, percentLabel,nil];
        [_viewArr addObject:arr];
        i++;
    }
}
#pragma mark - 更新视图
-(void)updateWithResultDic:(NSDictionary *)resultDic isScreen:(BOOL)isScreen{
    int i = 0;
    _resultDic = resultDic;
    
    float originY = isScreen?27:34;
    for (NSDictionary *dic in _resultDic[@"practice"][@"options"]) {
        float percent = [dic[@"percent"] floatValue];
        //取出text
        UILabel *textLabel = (UILabel *)_viewArr[i][0];
        textLabel.frame = CGRectMake(16, i * originY, 22, 12);
        
        //取出layer
        CALayer *layer = (CALayer *)_viewArr[i][1];
        layer.frame = CGRectMake(43, i * originY, 239, 15);
        
        //取出bgView
        CALayer *progressLayer = (CALayer *)_viewArr[i][2];
        progressLayer.frame = CGRectMake(43, i * originY, 239 * percent / 100, 15);
        
        //取出countLabel
        UILabel *countLabel = (UILabel *)_viewArr[i][3];
        countLabel.text = [NSString stringWithFormat:@"%d人", [dic[@"count"] intValue]];
        countLabel.frame = CGRectMake(230, i * originY, 42, 13);
        
        //取出percentLabel
        NSString *textStr = [self dealWithPercent:[NSString stringWithFormat:@"%@", dic[@"percent"]]];
        UILabel *percentLabel = (UILabel *)_viewArr[i][4];
        percentLabel.text = textStr;
        percentLabel.frame = CGRectMake(292, i * originY, 60, 13);
        i++;
    }
}

/**
 处理百分比

 @param percent 需要处理的百分比
 @return 处理过的百分比
 */
-(NSString *)dealWithPercent:(NSString *)percent{
    NSString *str = @"";
    NSInteger loca = [percent rangeOfString:@"."].location;
    if (loca + 2 < percent.length && loca > 0) {
//        NSLog(@"percent = %@", percent);
        str = [percent substringToIndex:loca + 2];
        NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                           decimalNumberHandlerWithRoundingMode:NSRoundDown
                                           scale:1
                                           raiseOnExactness:NO
                                           raiseOnOverflow:NO
                                           raiseOnUnderflow:NO
                                           raiseOnDivideByZero:YES];
        NSDecimalNumber *b = [NSDecimalNumber decimalNumberWithString:str];
        NSDecimalNumber *yy = [b decimalNumberByRoundingAccordingToBehavior:roundUp];
        str = [NSString stringWithFormat:@"(%@%%)", yy];
    }else{
        str = [NSString stringWithFormat:@"(%@)", percent];
    }
    return str;
}
-(void)dealloc{
//    NSLog(@"移除随堂测进度条视图");
}
@end
