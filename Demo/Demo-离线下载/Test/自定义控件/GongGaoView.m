//
//  GongGaoView.m
//  NewCCDemo
//
//  Created by cc on 2016/12/17.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "GongGaoView.h"

@interface GongGaoView()

@property(strong,nonatomic)UIButton             *closeBtn;
@property(strong,nonatomic)UILabel              *contentLabel;
@property(strong,nonatomic)UILabel              *titleLabel;
@property(strong,nonatomic)UIImageView          *imageView;
@property(strong,nonatomic)UIScrollView         *scrollView;
@property(assign,nonatomic)BOOL                 isScreenLandScape;
@property(copy  ,nonatomic)CloseBlock           block;
//@property(assign,nonatomic)BOOL                 forPC;

@end

@implementation GongGaoView

-(instancetype)initWithLeftLabelText:(NSString *)leftLabelText isScreenLandScape:(BOOL)isScreenLandScape forPC:(BOOL)forPC block:(CloseBlock)block {
    self = [super init];
    if(self) {
        _block = block;
//        _forPC = forPC;
        self.userInteractionEnabled = YES;
        _isScreenLandScape = isScreenLandScape;
        [self initViews:leftLabelText];
    }
    return self;
}

-(void)updateViews:(NSString *)str {
    if(!StrNotEmpty(str)) {
        str = @"暂无公告";
    }
    if(self.isScreenLandScape) {
        CGSize size = [self getTitleSizeByFont:str width:CCGetRealFromPt(870) font:[UIFont systemFontOfSize:FontSize_30]];
        
        CGSize sizeOfContent = CGSizeZero;
        sizeOfContent.width = size.width < CCGetRealFromPt(870) ? CCGetRealFromPt(870) : size.width;
        sizeOfContent.height = size.height < CCGetRealFromPt(360) ? CCGetRealFromPt(360) : size.height;

        _scrollView.contentSize = sizeOfContent;
        
        self.contentLabel.frame = CGRectMake(0, 0, size.width, size.height);
    } else {
        CGSize size = CGSizeZero;
        CGSize sizeOfContent = CGSizeZero;
//        if(self.isScreenLandScape) {
//            size = [self getTitleSizeByFont:str width:CCGetRealFromPt(600) font:[UIFont systemFontOfSize:FontSize_30]];
//            sizeOfContent.width = size.width < CCGetRealFromPt(600) ? CCGetRealFromPt(600) : size.width;
//            sizeOfContent.height = size.height < CCGetRealFromPt(870) ? CCGetRealFromPt(870) : size.height;
//            
//            _scrollView.contentSize = sizeOfContent;
//        } else {
            size = [self getTitleSizeByFont:str width:CCGetRealFromPt(600) font:[UIFont systemFontOfSize:FontSize_30]];
            sizeOfContent.width = size.width < CCGetRealFromPt(600) ? CCGetRealFromPt(600) : size.width;
            sizeOfContent.height = size.height < CCGetRealFromPt(152) ? CCGetRealFromPt(152) : size.height;
            
            _scrollView.contentSize = sizeOfContent;
//        }
        
        self.contentLabel.frame = CGRectMake(0, 0, size.width, size.height);
        [self setContentLabeltext:str];
    }
}

-(void)initViews:(NSString *)str {
    if(!StrNotEmpty(str)) {
        str = @"暂无公告";
    }
    self.backgroundColor = CCRGBAColor(0, 0, 0, 0.69);
     WS(ws)
    [self addSubview:self.closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
        make.bottom.mas_equalTo(ws).offset(-CCGetRealFromPt(30));
    }];
    
    [self addSubview:self.imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws).offset(CCGetRealFromPt(50));
        make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(50));
        make.top.mas_equalTo(ws).offset(CCGetRealFromPt(80));
        make.height.mas_equalTo(CCGetRealFromPt(60));
    }];

    [self addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.imageView);
    }];

    [self addSubview:self.scrollView];
    CGSize size = CGSizeZero;
    CGSize sizeOfContent = CGSizeZero;
    if(self.isScreenLandScape) {
        size = [self getTitleSizeByFont:str width:CCGetRealFromPt(870) font:[UIFont systemFontOfSize:FontSize_30]];
        sizeOfContent.width = size.width < CCGetRealFromPt(870) ? CCGetRealFromPt(870) : size.width;
        sizeOfContent.height = size.height < CCGetRealFromPt(360) ? CCGetRealFromPt(360) : size.height;
        
        _scrollView.contentSize = sizeOfContent;
        _scrollView.userInteractionEnabled = YES;
        [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws).offset(CCGetRealFromPt(232));
            make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(232));
            make.top.mas_equalTo(ws.imageView.mas_bottom).offset(CCGetRealFromPt(40));
            make.bottom.mas_equalTo(ws.closeBtn.mas_top).offset(-CCGetRealFromPt(40));
        }];
    } else {
        size = [self getTitleSizeByFont:str width:CCGetRealFromPt(630) font:[UIFont systemFontOfSize:FontSize_30]];
        sizeOfContent.width = size.width < CCGetRealFromPt(630) ? CCGetRealFromPt(630) : size.width;
        sizeOfContent.height = size.height < CCGetRealFromPt(152) ? CCGetRealFromPt(152) : size.height;
        
        _scrollView.contentSize = sizeOfContent;
        _scrollView.userInteractionEnabled = YES;
        [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws).offset(CCGetRealFromPt(60));
            make.right.mas_equalTo(ws).offset(-CCGetRealFromPt(60));
            make.top.mas_equalTo(ws.imageView.mas_bottom).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.closeBtn.mas_top).offset(-CCGetRealFromPt(30));
        }];
    }
    self.contentLabel.frame = CGRectMake(0, 0, size.width, size.height);
    [self.scrollView addSubview:self.contentLabel];
//    NSLog(@"---str = %@",str);
    [self setContentLabeltext:str];
}

-(void)setContentLabeltext:(NSString *)str {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.minimumLineHeight = CCGetRealFromPt(45);
    paragraphStyle.maximumLineHeight = CCGetRealFromPt(45);
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_30],NSForegroundColorAttributeName:[UIColor whiteColor],NSBackgroundColorAttributeName:CCClearColor,NSParagraphStyleAttributeName:paragraphStyle};
    [attr addAttributes:dict range:NSMakeRange(0, attr.length)];
    
    self.contentLabel.attributedText = attr;
}

-(CGSize)getTitleSizeByFont:(NSString *)str width:(CGFloat)width font:(UIFont *)font {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.minimumLineHeight = CCGetRealFromPt(45);
    paragraphStyle.maximumLineHeight = CCGetRealFromPt(45);
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    return size;
}

-(UIButton *)closeBtn {
    if(!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"notice_ic_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(void)closeBtnClicked {
    if(self.block) {
        self.block();
    }
}

-(UIImageView *)imageView {
    if(!_imageView) {
        _imageView = [UIImageView new];
        _imageView.backgroundColor = CCClearColor;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        if(self.isScreenLandScape) {
            _imageView.image = [UIImage imageNamed:@"notice_img_titlebig"];
        } else {
            _imageView.image = [UIImage imageNamed:@"notice_img_title"];
        }
    }
    return _imageView;
}

-(UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"直播公告";
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_28];
    }
    return _titleLabel;
}

-(UILabel *)contentLabel {
    if(!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    return;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    return YES;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
