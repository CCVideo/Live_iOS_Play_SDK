//
//  CCIntroductionView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/6.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCIntroductionView.h"
#import <WebKit/WebKit.h>

@interface CCIntroductionView ()<UIScrollViewDelegate>



@end
@implementation CCIntroductionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

/**
 重写roomName的set方法

 @param roomName 直播间信息
 */
- (void)setRoomName:(NSString *)roomName {
    _roomName = roomName;
    [self setupUI];
}

/**
 过滤html

 @param html 需要过滤的html
 @return 过滤过的html
 */
-(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}
#pragma mark - 设置UI布局
- (void)setupUI {
    //计算文字高度
    float textMaxWidth = CCGetRealFromPt(690);
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:_roomName];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.minimumLineHeight = CCGetRealFromPt(48);
    paragraphStyle.maximumLineHeight = CCGetRealFromPt(48);
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_32],NSParagraphStyleAttributeName:paragraphStyle};
    
    [attrStr addAttributes:dict range:NSMakeRange(0, attrStr.length)];
    CGSize textSize = [attrStr boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil].size;
    //添加背景视图
    UIView *titleLabelView = [[UIView alloc] init];
    titleLabelView.backgroundColor = [UIColor whiteColor];
    titleLabelView.frame = CGRectMake(0, 0, self.frame.size.width, textSize.height + CCGetRealFromPt(30) + CCGetRealFromPt(30));
    [self addSubview:titleLabelView];
    
    //添加分割线
    UIView * line= [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"#ff9049" alpha:1.0f];
    [titleLabelView addSubview:line];
    
    //添加titleLabel，显示简介内容
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.backgroundColor = CCClearColor;
    titleLabel.textColor = [UIColor colorWithHexString:@"#38404b" alpha:1.0f];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.attributedText = attrStr;

    [titleLabelView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(CCGetRealFromPt(50));
        make.top.equalTo(self).offset(CCGetRealFromPt(30));
        make.right.equalTo(self).offset(-10);
    }];
//    self.roomDesc = [self filterHTML:self.roomDesc];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(titleLabel.mas_left).offset(-5);
        make.top.equalTo(titleLabel).offset(5);
        make.height.mas_equalTo(17);
        make.width.mas_equalTo(2);
    }];
    
   
    WKWebView *web = [[WKWebView alloc] init];
    web.backgroundColor = [UIColor whiteColor];
    web.scrollView.showsHorizontalScrollIndicator = NO;
    web.scrollView.showsVerticalScrollIndicator = NO;
    web.scrollView.bouncesZoom = NO;
    web.opaque = NO;
    [self addSubview:web];
    [web mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.bottom.equalTo(self);
    }];
    
    NSString *headerString = @"<header><meta name='viewport' content='width=device-width, user-scalable=no'><style>img{max-width:100% !important; height:auto!important;}</style></header>";
//    NSString *headerString = [NSString stringWithFormat:@"<header><meta name='viewport' content='width=%f, user-scalable=no'><style>img{max-width:100%% !important; height:auto!important;}</style></header>",SCREEN_WIDTH];
     [web loadHTMLString:[headerString stringByAppendingString:self.roomDesc] baseURL:nil];
}


@end
