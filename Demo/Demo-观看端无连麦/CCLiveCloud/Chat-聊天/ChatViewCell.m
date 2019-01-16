//
//  ChatViewCell.m
//  CCLiveCloud
//
//  Created by 何龙 on 2018/12/12.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "ChatViewCell.h"
#import "Utility.h"
#import "ChatView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+animatedGIF.h"
#import "CellHeight.h"
@interface ChatViewCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView        *smallChatImage;//聊天图片(小图)
@property (nonatomic, strong) UIView             *photoView;//查看大图的容器
@property (nonatomic, strong) UIImageView        *bigChatImage;//聊天图片(大图)
@property (nonatomic, strong) UIScrollView       *scrollView;//用于存放smallChatImage;
@end

#define IMGURL @"[img_"
@implementation ChatViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

//广播消息设置UI
-(void)setBroadcastUI:(NSString *)msg{
    float textMaxWidth = CCGetRealFromPt(560);
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:msg y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(248,129,25) range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.minimumLineHeight = CCGetRealFromPt(34);
    style.maximumLineHeight = CCGetRealFromPt(34);
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_24],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.width = ceilf(textSize.width);
    textSize.height = ceilf(textSize.height);// + 1;
    
    
    UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:bgBtn];
    [bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(CCGetRealFromPt(25) * 2 + textSize.width);
        make.top.mas_equalTo(self).offset(CCGetRealFromPt(30));
        make.bottom.mas_equalTo(self);
    }];
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = CCClearColor;
    contentLabel.textColor = CCRGBColor(51,51,51);
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.userInteractionEnabled = NO;
    [bgBtn addSubview:contentLabel];
    contentLabel.attributedText = textAttri;
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgBtn.mas_centerX);
        make.centerY.mas_equalTo(bgBtn.mas_centerY).offset(-1);
        make.size.mas_equalTo(CGSizeMake(textSize.width, textSize.height + 1));
    }];
    
    bgBtn.enabled = NO;
    bgBtn.layer.cornerRadius = CCGetRealFromPt(4);
    bgBtn.layer.masksToBounds = YES;
    [bgBtn setBackgroundColor:CCRGBColor(237,237,237)];
}

/**
 用户消息UI布局

 @param model 数据模型
 @param input 是否需要键盘输入
 @param indexPath cell的indexPath
 */
-(void)setMessageUI:(Dialogue *)model isInput:(BOOL)input indexPath:(nonnull NSIndexPath *)indexPath{
    //如果用户名为非法字符,用户名和length可能为nil
    if (!model.username.length) {
        model.username = @" ";
    }
    CGFloat height = 0;//计算气泡的高度
    CGFloat width = 0;//计算气泡的宽度
    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];//判断是否是自己发的
    //--------------设置头像---------start-----------------
    UIButton *headBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    headBtn.tag = indexPath.row;
    if(!fromSelf && input) {
        [headBtn addTarget:self action:@selector(headBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    NSString * str;
    UIColor * textColor = [UIColor colorWithHexString:@"#79808b" alpha:1.0f];
    if(StrNotEmpty(model.useravatar)) {
        NSData *data = [NSData  dataWithContentsOfURL:[NSURL URLWithString:model.useravatar]];
        UIImage *image =  [UIImage imageWithData:data];
        [headBtn setBackgroundImage:image forState:UIControlStateNormal];
        if ([model.userrole isEqualToString:@"publisher"]) {//主讲
            str = @"lecturer_nor";
            textColor = [UIColor colorWithHexString:@"#12ad1a" alpha:1.0f];
        } else if ([model.userrole isEqualToString:@"student"]) {//学生或观众
            str = @"role_floorplan";
        } else if ([model.userrole isEqualToString:@"host"]) {//主持人
            str = @"compere_nor";
            textColor = [UIColor colorWithHexString:@"#12ad1a" alpha:1.0f];
            
        } else if ([model.userrole isEqualToString:@"unknow"]) {//其他没有角色
            str = @"role_floorplan";
        } else if ([model.userrole isEqualToString:@"teacher"]) {//助教
            str = @"assistant_nor";
            textColor = [UIColor colorWithHexString:@"#12ad1a" alpha:1.0f];
            
        }
    } else {
        if ([model.userrole isEqualToString:@"publisher"]) {//主讲
            [headBtn setBackgroundImage:[UIImage imageNamed:@"chatHead_lecturer"] forState:UIControlStateNormal];
            str = @"lecturer_nor";
            textColor = [UIColor colorWithHexString:@"#12ad1a" alpha:1.0f];
            
        } else if ([model.userrole isEqualToString:@"student"]) {//学生或观众
            [headBtn setBackgroundImage:[UIImage imageNamed:@"chatHead_student"] forState:UIControlStateNormal];
            str = @"role_floorplan";
            
        } else if ([model.userrole isEqualToString:@"host"]) {//主持人
            [headBtn setBackgroundImage:[UIImage imageNamed:@"chatHead_compere"] forState:UIControlStateNormal];
            str = @"compere_nor";
            textColor = [UIColor colorWithHexString:@"#12ad1a" alpha:1.0f];
            
        } else if ([model.userrole isEqualToString:@"unknow"]) {//其他没有角色
            [headBtn setBackgroundImage:[UIImage imageNamed:@"chatHead_user_five"] forState:UIControlStateNormal];
            str = @"role_floorplan";
            
        } else if ([model.userrole isEqualToString:@"teacher"]) {//助教
            [headBtn setBackgroundImage:[UIImage imageNamed:@"chatHead_assistant"] forState:UIControlStateNormal];
            str = @"assistant_nor";
            textColor = [UIColor colorWithHexString:@"#12ad1a" alpha:1.0f];
            
        }
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
    
    UIImageView * imageid= [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
    [self addSubview:imageid];
    [imageid mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headBtn);
    }];
    if(fromSelf) {
        textColor = [UIColor colorWithHexString:@"#ff6633" alpha:1.0f];
    }
    //--------------设置头像---------end-----------------
    UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:bgBtn];
    
    //-------------------判断是否有图片-------------start-----------
    //Ps:test解析图片地址,之后要更改为匹配字符串[img_url]
    BOOL haveImg = [model.msg containsString:IMGURL];//是否含有图片
    
    CGSize imgSize = CGSizeZero;
    //计算文本高度
    float textMaxWidth = CCGetRealFromPt(438);
    NSString * textAttr = [NSString stringWithFormat:@"%@:%@",model.username,model.msg];
    
    //如果有图片，只显示用户名
    if (haveImg) {
        textAttr = [NSString stringWithFormat:@"%@:", model.username];
    }
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:textAttr y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
    
    //找出特定字符在整个字符串中的位置
    NSRange redRange = NSMakeRange([[textAttri string] rangeOfString:model.username].location, [[textAttri string] rangeOfString:model.username].length+1);
    //修改特定字符的颜色
    //todo userName时特定表情时会崩溃  redRange会显示不确定的大小
    [textAttri addAttribute:NSForegroundColorAttributeName value:textColor range:redRange];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.minimumLineHeight = CCGetRealFromPt(36);
    style.maximumLineHeight = CCGetRealFromPt(60);
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_28],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.width = ceilf(textSize.width);
    textSize.height = ceilf(textSize.height);// + 1;
    //添加消息内容
    height = textSize.height + CCGetRealFromPt(18) * 2;
    
    
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = CCClearColor;
    contentLabel.textColor = CCRGBColor(51,51,51);
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.userInteractionEnabled = NO;
    [bgBtn addSubview:contentLabel];
    contentLabel.attributedText = textAttri;
    
    
    
    //--------------有图片时设置的UI
    if (haveImg) {
        if (!_smallChatImage) {
            [_smallChatImage removeFromSuperview];
        }
        _smallChatImage = [[UIImageView alloc] init];
        _smallChatImage.userInteractionEnabled = YES;
        //为图片添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToPhotoView)];
        _smallChatImage.tag = (long)indexPath.row;
        [_smallChatImage addGestureRecognizer:tap];
        
        //------------解析图片地址-------start---------
        //从字符A中分隔成2个元素的数组
        NSArray *getTitleArray = [model.msg componentsSeparatedByString:IMGURL];
        //去除前缀
        NSString *url = [NSString stringWithFormat:@"%@", getTitleArray[1]];
        NSArray *arr = [url componentsSeparatedByString:@"]"];
        //去除后缀，得到url
        url = [NSString stringWithFormat:@"%@", arr[0]];
        
        //新方法
        [self downloadImage:url index:indexPath];
        //获取图片size,计算高度
        imgSize = [self getCGSizeWithImage:_smallChatImage.image];
        [bgBtn addSubview:_smallChatImage];
        height += imgSize.height;
    }
    //----------------------------------------------------
    //计算气泡的宽度和高度
    width = textSize.width + CCGetRealFromPt(30) + CCGetRealFromPt(20);
    if (imgSize.width > width) {//计算宽度
        width = imgSize.width + CCGetRealFromPt(30) + CCGetRealFromPt(20);
    }
    if (width < CCGetRealFromPt(200) && haveImg) {
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
            height = textSize.height + CCGetRealFromPt(18) * 2;
        if (haveImg) {
            height += imgSize.height;
        }
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
        make.size.mas_equalTo(CGSizeMake(textSize.width, textSize.height + 1));
    }];
    if (haveImg) {
        //重置文字内容的约束
        [contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(bgBtn).offset(CCGetRealFromPt(25));
            make.top.mas_equalTo(bgBtn).offset(5);
            make.size.mas_equalTo(CGSizeMake(textSize.width, textSize.height + 1));
        }];
        //设置smallChatImage的约束
        [_smallChatImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(bgBtn).offset(CCGetRealFromPt(25));
            make.top.mas_equalTo(contentLabel.mas_bottom).offset(5);
            make.size.mas_equalTo(imgSize);
        }];
    }
    
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
-(UIImage*)convertViewToImage:(UIView*)v{
    CGSize s = v.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//将大图重绘至画板
-(NSData*)useImage:(UIImage*)image {
    //实现等比例缩放
    CGFloat hfactor = image.size.width*1.0 / SCREEN_WIDTH;
    CGFloat vfactor = image.size.height*1.0 / SCREEN_WIDTH;
    CGFloat factor = (hfactor>vfactor) ? hfactor : vfactor;
    
    //画布大小
    CGFloat newWith = image.size.width*1.0 / factor;
    CGFloat newHeigth = image.size.height*1.0 / factor;
    CGSize newSize = CGSizeMake(newWith, newHeigth);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newWith, newHeigth)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //图像压缩
    NSData* newImageData = UIImageJPEGRepresentation(newImage, 0.7);
    return newImageData;
}
#pragma mark - headBtnClick

/**
 点击头像添加回调

 @param btn btn
 */
-(void)headBtnClicked:(UIButton *)btn
{
    if (_headBtnClickBlock) {
        _headBtnClickBlock(btn);
    }
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
/**
 图片手势:单击进入大图模式
 */
-(void)pushToPhotoView
{
    if (_hiddenBlock) {
        _hiddenBlock(YES);
    }
//    NSLog(@"%ld", _smallChatImage.tag);
    _smallChatImage.userInteractionEnabled = NO;
    
    self.photoView = [[UIView alloc] initWithFrame:_smallChatImage.frame];
    self.photoView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.95];
    [APPDelegate.window addSubview:self.photoView];
    //设置布局
    //初始化scrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:_smallChatImage.frame];
    self.scrollView.minimumZoomScale = 0.7;
    self.scrollView.maximumZoomScale = 10;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self.photoView addSubview:self.scrollView];

    //初始化imageView
    _bigChatImage = [[UIImageView alloc] initWithFrame:_smallChatImage.frame];
    _bigChatImage.image = _smallChatImage.image;
    _bigChatImage.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.bigChatImage];

    //为视图添加动画
    WS(ws);
    [UIView animateWithDuration:0.3 animations:^{
        ws.photoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT);
        ws.scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT);
        ws.bigChatImage.frame = [ws getSmallFrame];
    }];

    //添加手势
    [self addGestureRecognizer];
}
#pragma mark - 查看大图相关设置
//得到处理过的imageSize
-(CGRect)getSmallFrame
{
    CGSize imgSize = _smallChatImage.image.size;
    CGFloat width = SCREEN_WIDTH / imgSize.width;
    CGFloat height = SCREENH_HEIGHT / imgSize.height;
    CGFloat x = 0;
    CGFloat y = 0;
    //按照宽度算
    if (width < height) {
        imgSize.height = SCREEN_WIDTH / imgSize.width * imgSize.height;
        imgSize.width = SCREEN_WIDTH;
        x = 0;
        y = (SCREENH_HEIGHT - imgSize.height) / 2;
    }else{
        imgSize.width = SCREENH_HEIGHT / imgSize.height * imgSize.width;
        imgSize.height = SCREENH_HEIGHT;
        x = (SCREEN_WIDTH - imgSize.width) / 2;
        y = 0;
    }
    CGRect smallFrame = CGRectMake(x, y, imgSize.width, imgSize.height);
    return smallFrame;
}
#pragma mark - 添加手势
-(void)addGestureRecognizer{
    //添加单击手势，移除视图
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removePhotoView)];
    [self.photoView addGestureRecognizer:tap];
    
    //添加长按手势
    WS(ws);
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:ws action:@selector(longPressAction:)];
    [self.photoView addGestureRecognizer:longPress];
}
#pragma mark - 长按手势
-(void)longPressAction:(UIGestureRecognizer *)recognizer{
    //    //弹出提示窗
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //添加alertAction
    WS(ws);
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //保存图片
        UIImageWriteToSavedPhotosAlbum(ws.smallChatImage.image, nil, nil, nil);
        [ws showSaveSuccess];
    }];
    //添加cancelAction
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:saveAction];
    [alertVC addAction:cancelAction];
    
    [[self getViewController] presentViewController:alertVC animated:YES completion:nil];
}
//单击移除手势
-(void)removePhotoView
{
    __weak typeof (self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.photoView.frame = CGRectZero;
        weakSelf.bigChatImage.frame = CGRectZero;
        weakSelf.scrollView.frame = CGRectZero;
    } completion:^(BOOL finished) {
        [weakSelf.photoView removeFromSuperview];
        [weakSelf.bigChatImage removeFromSuperview];
        [weakSelf.scrollView removeFromSuperview];
        weakSelf.smallChatImage.userInteractionEnabled = YES;
    }];
    if (_hiddenBlock) {
        _hiddenBlock(NO);
    }
}

//弹出保存成功的提示
-(void)showSaveSuccess{
    //弹出提示框
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -50, SCREEN_WIDTH, 50)];
    label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    label.text = @"图片已保存";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    [self.photoView addSubview:label];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        label.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        label.frame = CGRectMake(0, -50, SCREEN_WIDTH, 50);
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}
#pragma mark - scrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.bigChatImage;
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGRect frame = self.bigChatImage.frame;
    
    frame.origin.y = (self.scrollView.frame.size.height - self.bigChatImage.frame.size.height) > 0 ? (self.scrollView.frame.size.height - self.bigChatImage.frame.size.height) * 0.5 : 0;
    frame.origin.x = (self.scrollView.frame.size.width - self.bigChatImage.frame.size.width) > 0 ? (self.scrollView.frame.size.width - self.bigChatImage.frame.size.width) * 0.5 : 0;
    self.bigChatImage.frame = frame;
    
    self.scrollView.contentSize = CGSizeMake(self.bigChatImage.frame.size.width + 30, self.bigChatImage.frame.size.height + 30);
}
#pragma mark - 获取当前控制器
-(UIViewController *)getViewController{
    //获取当前view的superView对应的控制器
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            if (![next isKindOfClass:[UINavigationController class]]) {
                return (UIViewController *)next;;//避免找到NavigationVC
            }
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}
#pragma mark - 缓存图片
- (void)downloadImage:(NSString *)URL index:(NSIndexPath *)indexPath{
    WS(ws)
    [_smallChatImage sd_setImageWithURL:[NSURL URLWithString:URL] placeholderImage:[UIImage imageNamed:@"图片加载中"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            //加载失败,显示图片加载失败
            UIImage *errorImage = [UIImage imageNamed:@"图片加载失败"];
            ws.smallChatImage.image = errorImage;
            //回调，刷新tableView
            if (ws.reloadBlock) {
                ws.reloadBlock(indexPath);
            }
        }else{
            //判断是否已经下载过这张图片
            if ([[CellHeight sharedHeight] getHeightForKey:URL] != 0) {
                ;
            }else{//如果没有下载过这张图片
                //存入高度,并且刷新
                CGSize imageSize = [ws getCGSizeWithImage:image];
                [[CellHeight sharedHeight] setHeight:imageSize.height ForKey:URL];
                //回调，刷新tableView
                if (ws.reloadBlock) {
                    ws.reloadBlock(indexPath);
                }
            }
        }
    }];
}
@end
