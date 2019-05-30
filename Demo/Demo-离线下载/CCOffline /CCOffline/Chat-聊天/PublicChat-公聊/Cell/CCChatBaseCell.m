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
#pragma mark - 广播
@property (nonatomic, strong) UIButton    *radioBgButton;//广播背景视图
@property (nonatomic, strong) UILabel     *radioLabel;//广播label
#pragma mark - 文本消息
@property (nonatomic, strong) UIButton    *headBtn;//头像
@property (nonatomic, strong) UIImageView * imageid;//头像标识

@property (nonatomic, strong) UIButton    *bgBtn;//背景视图
@property (nonatomic, strong) UILabel     *contentLabel;//消息文本
#pragma mark - 图片消息
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
        [self setUpUI];
    }
    return self;
}
#pragma mark - 设置UI布局
-(void)setUpUI{
    //设置广播消息
    _radioBgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBgButton.enabled = NO;
    _radioBgButton.layer.cornerRadius = CCGetRealFromPt(4);
    _radioBgButton.layer.masksToBounds = YES;
    [_radioBgButton setBackgroundColor:CCRGBColor(237,237,237)];
    [self addSubview:_radioBgButton];
    //设置广播文本
    _radioLabel = [[UILabel alloc] init];
    _radioLabel.numberOfLines = 0;
    _radioLabel.backgroundColor = CCClearColor;
    _radioLabel.textColor = CCRGBColor(248,129,25);
    _radioLabel.textAlignment = NSTextAlignmentLeft;
    _radioLabel.userInteractionEnabled = NO;
    [_radioBgButton addSubview:_radioLabel];
    _radioLabel.font = [UIFont systemFontOfSize:FontSize_24];
    
    //添加头像
    _headBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _headBtn.backgroundColor = CCClearColor;
    _headBtn.layer.cornerRadius = CCGetRealFromPt(40);
    _headBtn.layer.masksToBounds = YES;
    [self addSubview:_headBtn];
    
    //添加头像标识
    _imageid= [[UIImageView alloc] init];
    [self addSubview:_imageid];
    
    //添加背景btn
    _bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_bgBtn];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.backgroundColor = CCClearColor;
    _contentLabel.textColor = CCRGBColor(51,51,51);
    _contentLabel.textAlignment = NSTextAlignmentLeft;
    _contentLabel.userInteractionEnabled = NO;
    [_bgBtn addSubview:_contentLabel];
    
    _smallImageView = [[CCImageView alloc] init];
    [_bgBtn addSubview:_smallImageView];
}
#pragma mark - 加载广播消息

/**
 加载广播消息

 @param model 公聊数据模型
 */
-(void)setRadioModel:(CCPublicChatModel *)model{
    //设置广播消息的背景btn
    [_radioBgButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(CCGetRealFromPt(25) * 2 + model.textSize.width);
        make.top.mas_equalTo(self).offset(CCGetRealFromPt(15));
        make.bottom.mas_equalTo(self).offset(CCGetRealFromPt(-15));
    }];
    //设置广播的消息内容
    _radioLabel.text = model.msg;
    [_radioLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_radioBgButton.mas_centerX);
        make.centerY.mas_equalTo(_radioBgButton.mas_centerY).offset(-1);
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
    [self dealHeadBtnWithModel:model isInput:input indexPath:indexPath];
    //设置聊天背景
    _contentLabel.attributedText = [self getTextAttri:model];
    
    //计算气泡的宽度和高度
    height = model.textSize.height + CCGetRealFromPt(18) * 2;
    width = model.textSize.width + CCGetRealFromPt(30) + CCGetRealFromPt(20);
    if(height < CCGetRealFromPt(80)) {//计算高度
        [_bgBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.headBtn.mas_right).offset(CCGetRealFromPt(22));
            make.top.mas_equalTo(self.headBtn);
            make.size.mas_equalTo(CGSizeMake(width, CCGetRealFromPt(80)));
        }];
    } else {
        height = model.textSize.height + CCGetRealFromPt(18) * 2;
        [self.bgBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.headBtn.mas_right).offset(CCGetRealFromPt(22));
            make.top.mas_equalTo(self.headBtn);
            make.size.mas_equalTo(CGSizeMake(width, height));
        }];
    };
    [self.bgBtn layoutIfNeeded];
    //设置Label的约束
    [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgBtn).offset(CCGetRealFromPt(25));
        make.centerY.mas_equalTo(self.bgBtn).offset(-1);
        make.size.mas_equalTo(CGSizeMake(model.textSize.width + 1, model.textSize.height + 1));
    }];
    [self dealWithBtn:self.bgBtn];
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
    //设置头像
    [self dealHeadBtnWithModel:model isInput:input indexPath:indexPath];
    
    //添加消息内容
    _contentLabel.attributedText = [self getTextAttri:model];
    
    height = model.textSize.height + CCGetRealFromPt(18) * 2;
    //判断本地是否有这张图片
    [self downloadImage:model.msg index:indexPath];
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
        [_bgBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.headBtn.mas_right).offset(CCGetRealFromPt(22));
            make.top.mas_equalTo(self.headBtn);
            make.size.mas_equalTo(CGSizeMake(width, CCGetRealFromPt(80)));
        }];
    } else {
        height = model.textSize.height + CCGetRealFromPt(18) * 2 + model.imageSize.height;
        [_bgBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.headBtn.mas_right).offset(CCGetRealFromPt(22));
            make.top.mas_equalTo(self.headBtn);
            make.size.mas_equalTo(CGSizeMake(width, height));
        }];
    };
    [self.bgBtn layoutIfNeeded];
    //重置文字内容的约束
    [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgBtn).offset(CCGetRealFromPt(25));
        make.top.mas_equalTo(self.bgBtn).offset(5);
        make.size.mas_equalTo(CGSizeMake(model.textSize.width + 1, model.textSize.height + 1));
    }];
    //设置smallChatImage的约束
    [_smallImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgBtn).offset(CCGetRealFromPt(25));
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(5);
        make.size.mas_equalTo(model.imageSize);
    }];
    
    [self dealWithBtn:self.bgBtn];
}
#pragma mark - 设置用户头像
-(void)dealHeadBtnWithModel:(CCPublicChatModel *)model
           isInput:(BOOL)input
         indexPath:(NSIndexPath *)indexPath{
    //设置头像
    //todo 离线下载没有myViwerId这个字段
//    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];//判断是否是自己发的
    _headBtn.tag = indexPath.row;
    if(input) {
        [_headBtn addTarget:self action:@selector(headBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    //判断用户是否有头像，如果有,用网络头像，如果没有,用本地头像
    if(StrNotEmpty(model.useravatar) && [model.useravatar containsString:@"http"]) {
        NSData *data = [NSData  dataWithContentsOfURL:[NSURL URLWithString:model.useravatar]];
        UIImage *image =  [UIImage imageWithData:data];
        [_headBtn setBackgroundImage:image forState:UIControlStateNormal];
    } else {
        [_headBtn setBackgroundImage:[UIImage imageNamed:model.headImgName] forState:UIControlStateNormal];
    }
    [_headBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(CCGetRealFromPt(30));
        make.top.mas_equalTo(self).offset(CCGetRealFromPt(30));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
    }];
    [_headBtn layoutIfNeeded];
    //根据身份为头像设置身份标示
    _imageid.image = [UIImage imageNamed:model.headTag];
    [_imageid mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_headBtn);
    }];
}
#pragma mark - 设置字体
-(NSAttributedString *)getTextAttri:(CCPublicChatModel *)model{
    //todo 离线下载没有myViewerId这个字段
//    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];//判断是否是自己发的
    UIColor *textColor = [UIColor colorWithHexString:model.textColorHexing alpha:1.f];
//    if(fromSelf) {
//        textColor = [UIColor colorWithHexString:@"#ff6633" alpha:1.0f];
//    }
    NSString * textAttr = [NSString stringWithFormat:@"%@:%@",model.username,model.msg];
    if (model.typeState == 2) {//如果是图片的话,过滤掉消息
        textAttr = [NSString stringWithFormat:@"%@:", model.username];
    }
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:textAttr y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
    
    //找出特定字符在整个字符串中的位置
    //todo  用户名为特殊字符时，算不出redRange
    if (!model.username.length) {
        model.username = @"_";
    }
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
