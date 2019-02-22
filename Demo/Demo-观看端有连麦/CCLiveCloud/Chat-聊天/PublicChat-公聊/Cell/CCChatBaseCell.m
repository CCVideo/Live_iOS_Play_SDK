//
//  CCChatBaseCell.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/21.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCChatBaseCell.h"
#import "Utility.h"
#import "UIImage+animatedGIF.h"
#import "CCImageView.h"
#import "CCChatViewDataSourceManager.h"
@interface CCChatBaseCell ()
@property (nonatomic, strong) CCImageView *smallImageView;//图片视图
@end

@implementation CCChatBaseCell
//初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = CCClearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
#pragma mark - 加载广播消息

/**
 加载广播消息

 @param model 公聊数据模型
 */
-(void)setRadioModel:(CCPublicChatModel *)model{
    //设置广播消息的背景btn
    UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bgBtn.enabled = NO;
    bgBtn.layer.cornerRadius = CCGetRealFromPt(4);
    bgBtn.layer.masksToBounds = YES;
    [bgBtn setBackgroundColor:CCRGBColor(237,237,237)];
    [self addSubview:bgBtn];
    [bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(CCGetRealFromPt(25) * 2 + model.textSize.width);
        make.top.mas_equalTo(self).offset(CCGetRealFromPt(15));
        make.bottom.mas_equalTo(self).offset(CCGetRealFromPt(-15));
    }];
    //设置广播的消息内容
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = CCClearColor;
    contentLabel.textColor = CCRGBColor(248,129,25);
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.userInteractionEnabled = NO;
    [bgBtn addSubview:contentLabel];
    contentLabel.font = [UIFont systemFontOfSize:FontSize_24];
    contentLabel.text = model.msg;
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgBtn.mas_centerX);
        make.centerY.mas_equalTo(bgBtn.mas_centerY).offset(-1);
        make.size.mas_equalTo(CGSizeMake(model.textSize.width + 1, model.textSize.height + 1));
    }];
}
#pragma mark - 加载纯文本消息
-(void)setTextModel:(CCPublicChatModel *)model
            isInput:(BOOL)input
          indexPath:(nonnull NSIndexPath *)indexPath{
    CGFloat height = 0;//计算气泡的高度
    CGFloat width = 0;//计算气泡的宽度
    //设置头像视图
    UIButton *headBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self initHeadBtn:headBtn ViewWithModel:model isInput:input indexPath:indexPath];

    //设置聊天背景
    UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:bgBtn];
    
    //设置消息内容
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = CCClearColor;
    contentLabel.textColor = CCRGBColor(51,51,51);
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.userInteractionEnabled = NO;
    contentLabel.attributedText = [self getTextAttri:model];
    [bgBtn addSubview:contentLabel];
    
    //计算气泡的宽度和高度
    height = model.textSize.height + CCGetRealFromPt(18) * 2;
    width = model.textSize.width + CCGetRealFromPt(30) + CCGetRealFromPt(20);
    if(height < CCGetRealFromPt(80)) {//计算高度
        height = 80;
        [bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(headBtn.mas_right).offset(CCGetRealFromPt(22));
            make.top.mas_equalTo(headBtn);
            make.size.mas_equalTo(CGSizeMake(width, CCGetRealFromPt(80)));
        }];
    } else {
        height = model.textSize.height + CCGetRealFromPt(18) * 2;
        [bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(headBtn.mas_right).offset(CCGetRealFromPt(22));
            make.top.mas_equalTo(headBtn);
            make.size.mas_equalTo(CGSizeMake(width, height));
        }];
    };
    [bgBtn layoutIfNeeded];
    //设置Label的约束
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bgBtn).offset(CCGetRealFromPt(25));
        make.centerY.mas_equalTo(bgBtn).offset(-1);
        make.size.mas_equalTo(CGSizeMake(model.textSize.width + 1, model.textSize.height + 1));
    }];
    [self dealWithBtn:bgBtn];
}
#pragma mark - 为btn添加圆角
-(void)dealWithBtn:(UIButton *)bgBtn{
    UIImage *bgImage = nil;
    UIView * bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.frame = bgBtn.frame;
    //设置所需的圆角位置以及大小
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bgView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bgView.bounds;
    maskLayer.path = maskPath.CGPath;
    bgView.layer.mask = maskLayer;
    bgImage = [self convertViewToImage:bgView];
    [bgBtn setBackgroundImage:bgImage forState:UIControlStateDisabled];
    [bgBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    bgBtn.userInteractionEnabled = YES;
}
//btn绘制方法
-(UIImage*)convertViewToImage:(UIView*)v{
    CGSize s = v.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark - 点击头像回调
-(void)headBtnClicked:(UIButton *)btn
{
    if (_headBtnClick) {
        _headBtnClick(btn);
    }
}
#pragma mark - 加载图片cell
-(void)setImageModel:(CCPublicChatModel *)model
             isInput:(BOOL)input
           indexPath:(nonnull NSIndexPath *)indexPath{
    CGFloat height = 0;//计算气泡的高度
    CGFloat width = 0;//计算气泡的宽度
    if (_smallImageView) {
        [_smallImageView removeFromSuperview];
        _smallImageView = nil;
    }
    //设置头像
    UIButton *headBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self initHeadBtn:headBtn ViewWithModel:model isInput:input indexPath:indexPath];
    
    //设置气泡
    UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:bgBtn];
    
    //添加消息内容
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = CCClearColor;
    contentLabel.textColor = CCRGBColor(51,51,51);
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.userInteractionEnabled = NO;
    [bgBtn addSubview:contentLabel];
    contentLabel.attributedText = [self getTextAttri:model];
    
    height = model.textSize.height + CCGetRealFromPt(18) * 2;
    //判断本地是否有这张图片
    _smallImageView = [[CCImageView alloc] init];
    [self downloadImage:model.msg index:indexPath];
    [bgBtn addSubview:_smallImageView];
    height += model.imageSize.height;
    //----------------------------------------------------
    //计算气泡的宽度和高度
    width = model.textSize.width + CCGetRealFromPt(30) + CCGetRealFromPt(20);
    if (model.imageSize.width > width) {//计算宽度
        width = model.imageSize.width + CCGetRealFromPt(30) + CCGetRealFromPt(20);
    }
    if (width < CCGetRealFromPt(200)) {
        width = CCGetRealFromPt(200);
    }
    if(height < CCGetRealFromPt(80)) {//计算高度
        height = 80;
        [bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(headBtn.mas_right).offset(CCGetRealFromPt(22));
            make.top.mas_equalTo(headBtn);
            make.size.mas_equalTo(CGSizeMake(width, CCGetRealFromPt(80)));
        }];
    } else {
        height = model.textSize.height + CCGetRealFromPt(18) * 2 + model.imageSize.height;
        [bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(headBtn.mas_right).offset(CCGetRealFromPt(22));
            make.top.mas_equalTo(headBtn);
            make.size.mas_equalTo(CGSizeMake(width, height));
        }];
    };
    [bgBtn layoutIfNeeded];
    //重置文字内容的约束
    [contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bgBtn).offset(CCGetRealFromPt(25));
        make.top.mas_equalTo(bgBtn).offset(5);
        make.size.mas_equalTo(CGSizeMake(model.textSize.width + 1, model.textSize.height + 1));
    }];
    //设置smallChatImage的约束
    [_smallImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bgBtn).offset(CCGetRealFromPt(25));
        make.top.mas_equalTo(contentLabel.mas_bottom).offset(5);
        make.size.mas_equalTo(model.imageSize);
    }];
    
    [self dealWithBtn:bgBtn];
}
#pragma mark - 设置用户头像
-(void)initHeadBtn:(UIButton *)headBtn
     ViewWithModel:(CCPublicChatModel *)model
           isInput:(BOOL)input
         indexPath:(NSIndexPath *)indexPath{
    //设置头像
    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];//判断是否是自己发的
    headBtn.tag = indexPath.row;
    if(!fromSelf && input) {
        [headBtn addTarget:self action:@selector(headBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    //判断用户是否有头像，如果有,用网络头像，如果没有,用本地头像
    if(StrNotEmpty(model.useravatar) && [model.useravatar containsString:@"http"]) {
        NSData *data = [NSData  dataWithContentsOfURL:[NSURL URLWithString:model.useravatar]];
        UIImage *image =  [UIImage imageWithData:data];
        [headBtn setBackgroundImage:image forState:UIControlStateNormal];
    } else {
        [headBtn setBackgroundImage:[UIImage imageNamed:model.headImgName] forState:UIControlStateNormal];
    }
    headBtn.backgroundColor = CCClearColor;
    headBtn.layer.cornerRadius = CCGetRealFromPt(40);
    headBtn.layer.masksToBounds = YES;
    [self addSubview:headBtn];
    [headBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(CCGetRealFromPt(30));
        make.top.mas_equalTo(self).offset(CCGetRealFromPt(30));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
    }];
    [headBtn layoutIfNeeded];
    //根据身份为头像设置身份标示
    UIImageView * imageid= [[UIImageView alloc] initWithImage:[UIImage imageNamed:model.headTag]];
    [self addSubview:imageid];
    [imageid mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headBtn);
    }];
}
#pragma mark - 设置字体
-(NSAttributedString *)getTextAttri:(CCPublicChatModel *)model{
    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];//判断是否是自己发的
    UIColor *textColor = [UIColor colorWithHexString:model.textColorHexing alpha:1.f];
    if(fromSelf) {
        textColor = [UIColor colorWithHexString:@"#ff6633" alpha:1.0f];
    }
    NSString * textAttr = [NSString stringWithFormat:@"%@:%@",model.username,model.msg];
    if (model.typeState == 2) {//如果是图片的话,过滤掉消息
        textAttr = [NSString stringWithFormat:@"%@:", model.username];
    }
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:textAttr y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
    
    //找出特定字符在整个字符串中的位置
    NSRange redRange = NSMakeRange([[textAttri string] rangeOfString:model.username].location, [[textAttri string] rangeOfString:model.username].length+1);
    //修改特定字符的颜色
    //userName时特定表情时会崩溃  redRange会显示不确定的大小
    [textAttri addAttribute:NSForegroundColorAttributeName value:textColor range:redRange];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.minimumLineHeight = CCGetRealFromPt(36);
    style.maximumLineHeight = CCGetRealFromPt(60);
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_28],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    return textAttri;
}
#pragma mark - 设置图片相关设置
//返回一个处理过的图片大小
-(CGSize)getCGSizeWithImage:(UIImage *)image{
    CGSize imageSize = image.size;
    //先判断图片的宽度和高度哪一个大
    if (image.size.width > image.size.height) {
        //以宽度为准，设置最大宽度
        if (imageSize.width > CCGetRealFromPt(438)) {
            imageSize.height = CCGetRealFromPt(438) / imageSize.width * imageSize.height;
            imageSize.width = CCGetRealFromPt(438);
        }
    }else{
        //以高度为准，设置最大高度
        if (imageSize.height >= CCGetRealFromPt(438)) {
            imageSize.width = CCGetRealFromPt(438) / imageSize.height * imageSize.width;
            imageSize.height = CCGetRealFromPt(438);
        }
    }
    return imageSize;
}
#pragma mark - 缓存图片
- (void)downloadImage:(NSString *)URL index:(NSIndexPath *)indexPath{
    WS(ws)
    [_smallImageView sd_setImageWithURL:[NSURL URLWithString:URL] placeholderImage:[UIImage imageNamed:@"picture_loading"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        //判断是否已下载，if down return
        BOOL exist = [[CCChatViewDataSourceManager sharedManager] existImageWithUrl:URL];
        if (exist) {
            return;
        }
        if (error) {
            //加载失败,显示图片加载失败
            UIImage *errorImage = [UIImage imageNamed:@"picture_load_fail"];
            ws.smallImageView.image = errorImage;
            //缓存图片信息
            [[CCChatViewDataSourceManager sharedManager] updateCellHeightWithIndexPath:indexPath imageSize:errorImage.size];
        }else{
            //缓存图片信息
            [[CCChatViewDataSourceManager sharedManager] updateCellHeightWithIndexPath:indexPath imageSize:image.size];
        }
    }];
}
@end
