//
//  CCQuestionViewCell.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/14.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCQuestionViewCell.h"

@interface CCQuestionViewCell ()
@property (nonatomic, strong) UIImageView        *head;//头像
@property (nonatomic, strong) UILabel            *titleLabel;//昵称
@property (nonatomic, strong) UILabel            *timeLabel;//时间
@property (nonatomic, strong) UILabel            *contentLabel;//内容（问题）
@property (nonatomic, strong) UIView             *lineView;//分割线
@end

@implementation CCQuestionViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        ///格栅处理
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        ///异步绘制
        self.layer.drawsAsynchronously = YES;
        [self setUI];//设置UI布局
    }
    return self;
}
#pragma mark - 初始化UI布局
-(void)setUI{
    //设置头像视图
    self.head = [[UIImageView alloc] init];
    self.head.backgroundColor = CCClearColor;
    self.head.contentMode = UIViewContentModeScaleAspectFit;
    self.head.userInteractionEnabled = NO;
    [self addSubview:self.head];
    [self.head mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(CCGetRealFromPt(30));
        make.top.mas_equalTo(self).offset(CCGetRealFromPt(30));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
    }];
    
    //添加昵称
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = CCClearColor;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.font = [UIFont systemFontOfSize:FontSize_28];
    self.titleLabel.userInteractionEnabled = NO;
    [self addSubview:self.titleLabel];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    //添加timeLabel
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.numberOfLines = 1;
    self.timeLabel.backgroundColor = CCClearColor;
    self.timeLabel.font = [UIFont systemFontOfSize:FontSize_20];
    self.timeLabel.textColor = CCRGBColor(153,153,153);
    self.timeLabel.userInteractionEnabled = NO;
    [self addSubview:self.timeLabel];
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.titleLabel).offset(-2);
        make.size.mas_equalTo(CGSizeMake(50, CCGetRealFromPt(20)));
    }];
    
    
    //设置内容
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.backgroundColor = CCClearColor;
    self.contentLabel.textColor = CCRGBColor(51,51,51);
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    self.contentLabel.userInteractionEnabled = NO;
    [self addSubview:self.contentLabel];
    
    //设置分界线
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.0f];
    [self addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.mas_bottom).offset(13);
        make.left.mas_equalTo(self).offset(CCGetRealFromPt(130));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(590), 1));
    }];
    self.lineView.hidden = YES;
    
    //设置底部分界线
    UIView *cellBottomLine = [[UIView alloc] init];
    cellBottomLine.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];;
    [self addSubview:cellBottomLine];
    [cellBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(5);
    }];
}

/**
 为视图赋值

 @param dialogue 数据模型
 @param indexPath cell的位置
 @param arr l数组
 @param input 是否有输入框
 */
-(void)setQuestionModel:(Dialogue *)dialogue indexPath:(NSIndexPath *)indexPath arr:(nonnull NSMutableArray *)arr isInput:(BOOL)input{
    
    
    //设置头像视图
    NSURL *url = [NSURL URLWithString:dialogue.useravatar];
    [self.head sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"chatHead_student"]];
    
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
    //设置昵称
    self.titleLabel.text = dialogue.username;
    if (fromSelf) {
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#ff6633" alpha:1.0f];
    }else {
        self.titleLabel.textColor = CCRGBColor(102,102,102);
    }
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.head.mas_right).offset(CCGetRealFromPt(20));
        make.top.mas_equalTo(self.head);
        make.size.mas_equalTo(CGSizeMake(textSize.width * 1.2, CCGetRealFromPt(24) + 6));
    }];
    
    //        //设置时间戳文本
    NSString * startTime = GetFromUserDefaults(LIVE_STARTTIME);
    if (!input) {
        startTime = [startTime substringToIndex:19];
    }
    NSInteger timea = [NSString timeSwitchTimestamp:startTime andFormatter:@"yyyy-MM-dd HH:mm:ss"];
    timea += [dialogue.time integerValue];
    self.timeLabel.text = [NSString timestampSwitchTime:timea andFormatter:@"HH:mm"];
    // 问答禁言
    if ([dialogue.time integerValue] == -1) {
//        NSLog(@"您已被禁言");
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        NSDate *datenow = [NSDate date];
        self.timeLabel.text = [formatter stringFromDate:datenow];
    }
    
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
    
    //设置聊天内容
    
    self.contentLabel.attributedText = textAttri;
    
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.head.mas_right).offset(CCGetRealFromPt(20));
        make.top.mas_equalTo(self.head.mas_centerY).offset(-1);
        make.size.mas_equalTo(textSize1);
    }];
    //添加分割线，第一行是问题，下面是答案
    if (arr.count > 1) {
        self.lineView.hidden = NO;
    }
    //添加答案视图
    [self addAnswerView:arr];
}
#pragma mark - 添加其他的视图
-(void)addAnswerView:(NSMutableArray *)arr{
    //清空cell的contentView,避免视图重复创建
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    UIView *viewBase = nil;
    //遍历答案，设置视图
    for(int i = 1;i < [arr count];i++) {
        
        Dialogue *dialogue = [arr objectAtIndex:i];
        UIView *viewTop = [[UIView alloc] init];
        viewTop.backgroundColor = CCRGBColor(255,255,255);
        [self.contentView addSubview:viewTop];
        if(viewBase == nil) {
            [viewTop mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(CCGetRealFromPt(130));
                make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(CCGetRealFromPt(16)+10);
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(590), 1));
            }];
        } else {
            viewTop = viewBase;
        }
        //解析数据
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
        UIView *viewBg = [[UIView alloc] init];
        viewBg.backgroundColor = CCRGBColor(255,255,255);
        [self.contentView addSubview:viewBg];
        [viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(viewTop);
            make.top.mas_equalTo(viewTop.mas_bottom);
            make.height.mas_equalTo(textSize.height + CCGetRealFromPt(10) + CCGetRealFromPt(20)-10);
        }];
        //设置答案内容
        UILabel *contentLabel = [[UILabel alloc] init];
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
        //设置答案的底部视图
        UIView *viewBottom = [[UIView alloc] init];
        viewBottom.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:viewBottom];
        [viewBottom mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(viewTop);
            make.top.mas_equalTo(viewBg.mas_bottom);
            make.height.mas_equalTo(1);
        }];
        
        viewBase = viewBottom;
    }
}
@end
