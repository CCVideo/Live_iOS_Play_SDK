//
//  AnnouncementView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2018/12/25.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "AnnouncementView.h"

@interface AnnouncementView ()
@property (nonatomic, copy) NSString               *announcementStr;//公告内容
@property (nonatomic, strong) UIImageView          *topBgView;//顶部视图
@property (nonatomic, strong) UILabel              *topLabel;//顶部标题
@property (nonatomic, strong) UILabel              *announcementLabel;//公告
@property (nonatomic, strong) UIButton             *closeBtn;//关闭按钮
@property (nonatomic, strong) UIScrollView         *scrollView;//用于盛放内容的scrollView

@end
#define NOANNOUNCEMENT @"暂无公告"
@implementation AnnouncementView
/**
 初始化方法
 
 @param str 公告内容
 @return self
 */
-(instancetype)initWithAnnouncementStr:(NSString *)str{
    self = [super init];
    if (self) {
        if(!StrNotEmpty(str)) {
            str = NOANNOUNCEMENT;
        }
        self.backgroundColor = [UIColor whiteColor];
        _announcementStr = str;//初始化公告内容
        [self setUI];
    }
    return self;
}
#pragma mark - 设置UI
-(void)setUI{
    WS(ws)
    //添加顶部视图
    [self addSubview:self.topBgView];
    [_topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(ws);
        make.height.mas_equalTo(CCGetRealFromPt(80));
    }];
    
    //顶部分界线
    UIView *topline = [[UIView alloc] init];
    topline.backgroundColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.f];
    [self addSubview:topline];
    [topline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws);
        make.top.mas_equalTo(ws);
        make.size.mas_equalTo(CGSizeMake( CCGetRealFromPt(750), CCGetRealFromPt(1)));
    }];
    
    //底部分界线
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.f];
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws);
        make.top.mas_equalTo(ws.topBgView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(750), CCGetRealFromPt(1)));
    }];
    
    //添加公告标题
    [self.topBgView addSubview:self.topLabel];
    [_topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(ws.topBgView);
        make.height.mas_equalTo(CCGetRealFromPt(30));
    }];
    
    //添加关闭按钮
    [self.topBgView addSubview:self.closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.mas_right).offset(-CCGetRealFromPt(20));
        make.centerY.mas_equalTo(ws.topBgView);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(56), CCGetRealFromPt(56)));
    }];
    
    //添加scrollView
    [self addSubview:self.scrollView];
    CGSize size = CGSizeZero;
    CGSize sizeOfContent = CGSizeZero;
    size = [self getTitleSizeByFont:_announcementStr width:CCGetRealFromPt(690) font:[UIFont systemFontOfSize:FontSize_26]];
    
    //计算scrollView的contentSize
    sizeOfContent.width = CCGetRealFromPt(750);
    sizeOfContent.height = size.height < CCGetRealFromPt(798) ? CCGetRealFromPt(798) : size.height;
    
    _scrollView.contentSize = sizeOfContent;
    _scrollView.userInteractionEnabled = YES;
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws);
        make.right.mas_equalTo(ws);
        make.top.mas_equalTo(ws.topBgView.mas_bottom);
        make.bottom.mas_equalTo(ws).offset(-CCGetRealFromPt(30));
    }];
    
    //添加公告内容
    self.announcementLabel.frame = CGRectMake(CCGetRealFromPt(30), CCGetRealFromPt(25), CCGetRealFromPt(690), size.height);
    [self.scrollView addSubview:_announcementLabel];
    [self setContentLabeltext:_announcementStr];
}
#pragma mark - 更新公告内容

/**
 更新公告内容

 @param str 需要更新的内容
 */
-(void)updateViews:(NSString *)str{
    if(!StrNotEmpty(str)) {//如果为空,提示暂无公告
        str = NOANNOUNCEMENT;
    }
    CGSize size = CGSizeZero;
    CGSize sizeOfContent = CGSizeZero;
    size = [self getTitleSizeByFont:str width:CCGetRealFromPt(690) font:[UIFont systemFontOfSize:FontSize_26]];
    //计算scrollView的contentSize
    sizeOfContent.width = CCGetRealFromPt(750);
    sizeOfContent.height = size.height < CCGetRealFromPt(798) ? CCGetRealFromPt(798) : size.height;
    
    _scrollView.contentSize = sizeOfContent;
    self.announcementLabel.frame = CGRectMake(CCGetRealFromPt(30), CCGetRealFromPt(25), CCGetRealFromPt(690), size.height);
    [self setContentLabeltext:str];
}
#pragma mark - 关闭按钮
-(void)closeBtnClicked{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, SCREENH_HEIGHT, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
#pragma mark - 计算文字高度
-(void)setContentLabeltext:(NSString *)str {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.minimumLineHeight = CCGetRealFromPt(45);
    paragraphStyle.maximumLineHeight = CCGetRealFromPt(45);
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_30],NSForegroundColorAttributeName:[UIColor whiteColor],NSBackgroundColorAttributeName:CCClearColor,NSParagraphStyleAttributeName:paragraphStyle};
    [attr addAttributes:dict range:NSMakeRange(0, attr.length)];
    
    self.announcementLabel.attributedText = attr;
    self.announcementLabel.textColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
}

/**
 计算字符串大小

 @param str 需要计算的字符串
 @param width 最大宽度
 @param font 字体大小
 @return 计算后的大小
 */
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
#pragma mark - 懒加载
//顶部背景图
-(UIImageView *)topBgView {
    if(!_topBgView) {
        _topBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bar"]];
        _topBgView.backgroundColor = CCClearColor;
        _topBgView.userInteractionEnabled = YES;
    }
    return _topBgView;
}
//顶部标题
-(UILabel *)topLabel{
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.text = @"公告";
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.font = [UIFont systemFontOfSize:FontSize_30];
        _topLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1.f];
    }
    return _topLabel;
}
//关闭按钮
-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.backgroundColor = CCClearColor;
        _closeBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}
//scrollView
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}
//公告内容
-(UILabel *)announcementLabel{
    if (!_announcementLabel) {
        _announcementLabel = [[UILabel alloc] init];
        _announcementLabel.numberOfLines = 0;
    }
    return _announcementLabel;
}
@end
