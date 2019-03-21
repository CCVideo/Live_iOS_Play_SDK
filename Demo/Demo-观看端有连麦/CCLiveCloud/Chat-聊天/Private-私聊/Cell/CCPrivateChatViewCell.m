//
//  CCPrivateChatViewCell.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/22.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCPrivateChatViewCell.h"
#import "CCImageView.h"
#import "Utility.h"//
#import "CCChatViewDataSourceManager.h"
@interface CCPrivateChatViewCell ()
@property (nonatomic, strong) CCImageView    *photoView;//图片视图
@property (nonatomic, strong) UIButton       *bgButton;//气泡背景
@property (nonatomic, strong) UIImageView    *head;//头像
@property (nonatomic, strong) UIImageView    *imageid;//头像标识
@property (nonatomic, strong) UILabel        *contentLabel;
@end
@implementation CCPrivateChatViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
    }
    return self;
}
#pragma mark - 设置布局
-(void)setUpUI{
    //添加头像
    self.head = [[UIImageView alloc] init];
    self.head.backgroundColor = CCClearColor;
    self.head.contentMode = UIViewContentModeScaleAspectFit;
    self.head.userInteractionEnabled = NO;
    [self addSubview:self.head];
    //添加头像标识
    self.imageid = [[UIImageView alloc] init];
    [self.head addSubview:self.imageid];
    [self.imageid mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.head);
    }];
    //添加聊天背景视图
    self.bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.bgButton];
    
    
    //添加消息label
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.backgroundColor = CCClearColor;
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    self.contentLabel.userInteractionEnabled = NO;
    [self.bgButton addSubview:self.contentLabel];
    
    
    //添加imageView
    self.photoView = [[CCImageView alloc] init];
    [self addSubview:self.photoView];
    self.photoView.hidden = YES;
}
#pragma mark - 设置cell的布局

/**
 根据身份处理图片
 
 @param fromuserrole fromuserrole description
 */
-(NSArray *)dealWithFromuserrole:(NSString *)fromuserrole{
    NSString * str;//身份标识
    NSString *headImgName;//头像名称
    if ([fromuserrole isEqualToString:@"publisher"]) {//主讲
        str = @"lecturer_nor";
        headImgName = @"chatHead_lecturer";
    } else if ([fromuserrole isEqualToString:@"student"]) {//学生或观众
        str = @"role_floorplan";
        headImgName = @"chatHead_student";
    } else if ([fromuserrole isEqualToString:@"host"]) {//主持人
        str = @"compere_nor";
        headImgName = @"chatHead_compere";
    } else if ([fromuserrole isEqualToString:@"unknow"]) {//其他没有角色
        str = @"role_floorplan";
        headImgName = [NSString stringWithFormat:@"用户%d", arc4random_uniform(5) + 1];
    } else if ([fromuserrole isEqualToString:@"teacher"]) {//助教
        str = @"assistant_nor";
        headImgName = @"chatHead_assistant";
    } else{
        str = @"role_floorplan";
        headImgName = [NSString stringWithFormat:@"用户%d", arc4random_uniform(5) + 1];
    }
    NSArray *arr = [NSArray arrayWithObjects:str, headImgName, nil];
    return arr;
}
//设置cell样式
-(void)setModel:(Dialogue *)dialog WithIndexPath:(NSIndexPath *)indexPath {
    BOOL fromSelf = [dialog.fromuserid isEqualToString:dialog.myViwerId];
    //添加head
    NSArray *arr = [self dealWithFromuserrole:dialog.fromuserrole];
    self.head.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", arr[1]]];
    self.imageid.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", arr[0]]];
    if(fromSelf) {//消息方是自己,头像居右
        [self.head mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-CCGetRealFromPt(30));
            make.top.mas_equalTo(self).offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
        }];
    } else {//消息方不是自己，头像居左
        [self.head mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(CCGetRealFromPt(30));
            make.top.mas_equalTo(self).offset(CCGetRealFromPt(20));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
        }];
    }
    CGFloat height;
    float width;
    //判断是否有图片
    BOOL haveImg = [dialog.msg containsString:@"[img_"];
    if (haveImg) {
        _contentLabel.hidden = YES;
        _photoView.hidden = NO;
        //处理图片,得到url
        NSString *url = [self getUrlWithMessage:dialog.msg];
        [self downloadImage:url index:indexPath];
        CGSize size = [self getCGSizeWithImageSize:self.photoView.image.size];
        height = size.height + 20;
        width = size.width + 20;
        float offset = fromSelf?CCGetRealFromPt(20):CCGetRealFromPt(30);
        [self.photoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bgButton).offset(offset);
            make.centerY.mas_equalTo(self.bgButton).offset(-1);
            make.size.mas_equalTo(size);
        }];
    }else{
        _photoView.hidden = YES;
        _contentLabel.hidden = NO;
        NSMutableAttributedString *textAttri = [Utility emotionStrWithString:dialog.msg y:-8];
        CGSize textSize = [self getCGSizeWithAttriStr:textAttri];
        //计算label的高度
        self.contentLabel.attributedText = textAttri;
        height = textSize.height + CCGetRealFromPt(18) * 2;
        if(fromSelf) {
            self.contentLabel.textColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.f];
        }else{
            self.contentLabel.textColor = [UIColor colorWithHexString:@"#1e1f21" alpha:1.f];
        }
        width = textSize.width + CCGetRealFromPt(30) + CCGetRealFromPt(20);
        height = height < CCGetRealFromPt(60)?CCGetRealFromPt(60):(textSize.height + CCGetRealFromPt(18) * 2);
        
        //设置contentLabel的约束
        float offset = fromSelf?CCGetRealFromPt(20):CCGetRealFromPt(30);
        [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bgButton).offset(offset);
            make.centerY.mas_equalTo(self.bgButton).offset(-1);
            make.size.mas_equalTo(CGSizeMake(textSize.width, textSize.height + 1));
        }];
    }
    //设置气泡的约束
    [self.bgButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(fromSelf){//判断是否是自己
            make.right.mas_equalTo(self.head.mas_left).offset(-CCGetRealFromPt(22));
        }else{
            make.left.mas_equalTo(self.head.mas_right).offset(CCGetRealFromPt(22));
        }
        make.top.mas_equalTo(self.head);
        make.size.mas_equalTo(CGSizeMake(width, height));
    }];
    [self.bgButton layoutIfNeeded];
    //处理气泡显示样式
    [self dealWithBgBtn:self.bgButton fromSelf:fromSelf];
}

/**
 计算文字的大小
 
 @param textAttri 富文本
 @return 计算过的文字宽高
 */
-(CGSize)getCGSizeWithAttriStr:(NSMutableAttributedString *)textAttri{
    float textMaxWidth = CCGetRealFromPt(438);
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = CCGetRealFromPt(36);
    style.maximumLineHeight = CCGetRealFromPt(60);
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.width = ceilf(textSize.width);
    textSize.height = ceilf(textSize.height);// + 1;
    return textSize;
}

/**
 处理气泡显示样式
 
 @param bgButton 气泡btn
 @param fromSelf 是否是自己
 */
-(void)dealWithBgBtn:(UIButton *)bgButton fromSelf:(BOOL)fromSelf{
    UIImage *bgImage = nil;
    UIView * bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    if (fromSelf) {
        bgView.backgroundColor = [UIColor colorWithHexString:@"#ff8e47" alpha:1.f];
    }
    bgView.frame = bgButton.frame;
    //设置所需的圆角位置以及大小
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bgView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | (fromSelf ?UIRectCornerTopLeft:UIRectCornerTopRight) cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bgView.bounds;
    maskLayer.path = maskPath.CGPath;
    bgView.layer.mask = maskLayer;
    bgImage = [self convertViewToImage:bgView];
    [bgButton setBackgroundImage:bgImage forState:UIControlStateDisabled];
    [bgButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    bgButton.userInteractionEnabled = YES;
    bgButton.enabled = NO;
}

/**
 生成一个指定样式的图片，视图转图片
 
 @param v 需要处理的视图
 @return 处理后的图片
 */
-(UIImage*)convertViewToImage:(UIView*)v{
    CGSize s = v.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark - 解析图片消息
//处理msg,得到url
-(NSString *)getUrlWithMessage:(NSString *)msg{
    //------------解析图片地址-------start---------
    //从字符A中分隔成2个元素的数组
    NSArray *getTitleArray = [msg componentsSeparatedByString:@"[img_"];
    //去除前缀
    NSString *url = [NSString stringWithFormat:@"%@", getTitleArray[1]];
    NSArray *arr = [url componentsSeparatedByString:@"]"];
    //去除后缀，得到url
    url = [NSString stringWithFormat:@"%@", arr[0]];
    return url;
}
#pragma mark - 缓存图片
- (void)downloadImage:(NSString *)URL index:(NSIndexPath *)indexPath{
    WS(ws)
    [_photoView sd_setImageWithURL:[NSURL URLWithString:URL] placeholderImage:[UIImage imageNamed:@"picture_loading"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        //判断是否已下载，if down return
        BOOL exist = [[CCChatViewDataSourceManager sharedManager] existImageWithUrl:URL];
        if (exist) {
            return;
        }
        if (error) {
            //加载失败,显示图片加载失败
            UIImage *errorImage = [UIImage imageNamed:@"picture_load_fail"];
            ws.photoView.image = errorImage;
            //缓存图片信息
            [[CCChatViewDataSourceManager sharedManager] setURL:URL withImageSize:errorImage.size];
        }else{
            CGSize size = [self getCGSizeWithImageSize:image.size];
            //缓存图片信息
            [[CCChatViewDataSourceManager sharedManager] setURL:URL withImageSize:size];
        }
        self.reloadIndexPath(indexPath);
    }];
}
//返回一个处理过的图片大小
-(CGSize)getCGSizeWithImageSize:(CGSize)imageSize{
    //先判断图片的宽度和高度哪一个大
    if (imageSize.width > imageSize.height) {
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
@end
