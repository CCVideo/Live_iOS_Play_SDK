//
//  CCIntroductionView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/6.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCIntroductionView.h"


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

- (void)setRoomName:(NSString *)roomName {
    _roomName = roomName;
    [self setupUI];
}

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
- (void)setupUI {
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
    
    UIView *titleLabelView = [UIView new];
    titleLabelView.backgroundColor = [UIColor whiteColor];
    titleLabelView.frame = CGRectMake(0, 0, self.frame.size.width, textSize.height + CCGetRealFromPt(30) + CCGetRealFromPt(30));
    [self addSubview:titleLabelView];
    
    UIView * line= [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"#ff9049" alpha:1.0f];
    [titleLabelView addSubview:line];
    
    UILabel *titleLabel = [UILabel new];
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
    
    UIWebView * web = [[UIWebView alloc] init];
    web.backgroundColor = [UIColor whiteColor];
    web.scrollView.showsHorizontalScrollIndicator = NO;
    web.opaque = NO;
    [self addSubview:web];
    [web mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.bottom.equalTo(self);
    }];
    self.roomDesc = [NSString stringWithFormat:@"<head ><style type=\"text/css\" >img{height: auto;max-width: 100%%;max-height: 100%%;}</style></head ><body style=\"word-wrap:break-word;\"> <div style= \" width:%fpx\">%@ </div> </body>", SCREEN_WIDTH,self.roomDesc];
    [web loadHTMLString:self.roomDesc baseURL:nil];

}



@end
