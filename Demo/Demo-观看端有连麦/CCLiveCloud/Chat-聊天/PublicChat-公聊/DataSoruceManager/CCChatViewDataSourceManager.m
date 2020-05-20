//
//  CCChatViewDataSourceManager.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/21.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCChatViewDataSourceManager.h"
#import "Utility.h"

@interface CCChatViewDataSourceManager ()

/*
 缓存过的图片信息保存在这里
 key为图片的url
 value为图片的size,格式为width_height,使用时用"_"隔开
 */
@property (nonatomic, strong) NSMutableDictionary *downloadDic;

@end
#define IMGURL @"[img_"
@implementation CCChatViewDataSourceManager

+(CCChatViewDataSourceManager *)sharedManager{
    static CCChatViewDataSourceManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedManager) {
            _sharedManager = [[self alloc] init];
        }
    });
    return _sharedManager;
}
#pragma mark - 处理数据
//加载历史聊天数据时,调用此方法
-(void)initWithPublicArray:(NSArray *)objectArr
                   userDic:(nonnull NSMutableDictionary *)userDic
                  viewerId:(nonnull NSString *)viewerId
                   groupId:(nonnull NSString *)groupId{
//    NSLog(@"待处理数量 = %ld", objectArr.count);
    for(NSDictionary *dic in objectArr) {
        //通过groupId过滤数据------
        NSString *msgGroupId = dic[@"groupId"];
        CCPublicChatModel *model = [[CCPublicChatModel alloc] init];
        //判断是否自己or消息的groupId为空or是否是本组聊天信息
        if ([groupId isEqualToString:@""] || !msgGroupId || [msgGroupId isEqualToString:@""] || [groupId isEqualToString:msgGroupId]) {
            model.userid = dic[@"userId"];
            model.fromuserid = dic[@"userId"];
            model.username = dic[@"userName"];
            model.fromusername = dic[@"userName"];
            model.userrole = dic[@"userRole"];
            model.fromuserrole = dic[@"userRole"];
            NSString * str = dic[@"content"];
            if ([str containsString:@"[uri_"]) {
                str = [str stringByReplacingOccurrencesOfString:@"[uri_" withString:@""];
                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
                model.msg = str;
            } else {
                model.msg = dic[@"content"];
            }
            model.useravatar = dic[@"userAvatar"];
            model.time = dic[@"time"];
            model.myViwerId = viewerId;
            model.status = dic[@"status"];
            model.chatId = dic[@"chatId"];
            
            if([userDic objectForKey:model.userid] == nil) {
                [userDic setObject:dic[@"userName"] forKey:model.userid];
            }
        [self dealWithModel:model];//处理model
            [self.publicChatArray addObject:model];
        }
    }
}
#pragma mark - 加载直播回放历史聊天数据

/**
 处理直播历史回放的聊天数据
 如果消息数量过大，需要耗费一段时间,判断数量是否过大
 过大时默认先返回60条，其余聊天数据放至异步加载.

 @param objectArr 历史聊天数据
 @param groupId groupId
 */
-(void)initWithPlayBackChatArray:(NSArray *)objectArr groupId:(NSString *)groupId{
//    NSLog(@"待处理数量 = %ld", objectArr.count);
    //1000为数据条数
    if (objectArr.count > 1000) {
        //字符串的截取
        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(1, 60)];
        NSArray *firstarr = [objectArr objectsAtIndexes:indexSet];
//        NSLog(@"先处理数量 = %ld", [firstarr count]);
        //先处理前60条
        [self dealWithPlayBackChatArr:firstarr groupId:groupId];
        
        //后处理的数据,放在异步执行
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSIndexSet *indexs = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(60, objectArr.count - 60)];
            NSArray *secArr = [objectArr objectsAtIndexes:indexs];
//            NSLog(@"后处理数量 = %ld", [secArr count]);
            [self dealWithPlayBackChatArr:secArr groupId:groupId];
        });
    }else{
        [self dealWithPlayBackChatArr:objectArr groupId:groupId];
    }
    
}
//处理聊天数据
-(void)dealWithPlayBackChatArr:(NSArray *)objectArr groupId:(NSString *)groupId{
    for(NSDictionary *dic in objectArr) {
        //通过groupId过滤数据------
        NSString *msgGroupId = dic[@"groupId"];
        CCPublicChatModel *model = [[CCPublicChatModel alloc] init];
        //判断是否自己or消息的groupId为空or是否是本组聊天信息
        if ([groupId isEqualToString:@""] || !msgGroupId || [msgGroupId isEqualToString:@""] || [groupId isEqualToString:msgGroupId]) {
            model.userid = dic[@"userId"];
            model.fromuserid = dic[@"userId"];
            model.username = dic[@"userName"];
            model.fromusername = dic[@"userName"];
            model.userrole = dic[@"userRole"];
            model.fromuserrole = dic[@"userRole"];
            NSString * str = dic[@"content"];
            if ([str containsString:@"[uri_"]) {
                str = [str stringByReplacingOccurrencesOfString:@"[uri_" withString:@""];
                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
                model.msg = str;
            } else {
                model.msg = dic[@"content"];
            }
            model.useravatar = dic[@"userAvatar"];
            model.time = dic[@"time"];
            model.status = dic[@"status"];
            model.chatId = dic[@"chatId"];
            
            [self dealWithModel:model];//处理model
            [self.publicChatArray addObject:model];
        }
    }
}
//收到公聊时，调用此方法
//返回一个处理过的数组,交给tableView去渲染
-(void)addPublicChat:(NSDictionary *)dic
             userDic:(nonnull NSMutableDictionary *)userDic
            viewerId:(nonnull NSString *)viewerId
             groupId:(nonnull NSString *)groupId
          danMuBlock:(nonnull InsertDanMuBlock)block{
//    if (self.publicChatArray.count > 300) {
//        NSMutableArray *arr = [NSMutableArray array];
//        for(NSInteger i = self.publicChatArray.count - 60; i < self.publicChatArray.count; ++i){
//            [arr addObject:self.publicChatArray[i]];
//        }
//        [self removeData];
//        self.publicChatArray = [arr mutableCopy];
//        NSLog(@"count大于300,返回最新60条");
//        return;
//    }
    
    NSString *msgGroupId = dic[@"groupId"];
    if ([groupId isEqualToString:@""] || [msgGroupId isEqualToString:@""] || [groupId isEqualToString:msgGroupId] || !msgGroupId) {
        CCPublicChatModel *model = [[CCPublicChatModel alloc] init];
        model.userid = dic[@"userid"];
        model.fromuserid = dic[@"userid"];
        model.username = dic[@"username"];
        model.fromusername = dic[@"username"];
        model.userrole = dic[@"userrole"];
        model.fromuserrole = dic[@"userrole"];
        NSString * str = dic[@"msg"];
        if ([str containsString:@"[uri_"]) {
            str = [str stringByReplacingOccurrencesOfString:@"[uri_" withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
            model.msg = str;
        } else {
            model.msg = dic[@"msg"];
        }
        model.useravatar = dic[@"useravatar"];
        model.time = dic[@"time"];
        model.myViwerId = viewerId;
        model.status = dic[@"status"];
        model.chatId = dic[@"chatId"];
        
        
        //如果用户名为非法字符,用户名和length可能为nil
        if (!model.username.length) {
            model.username = @" ";
        }
        if([userDic objectForKey:model.userid] == nil) {
            [userDic setObject:dic[@"username"] forKey:model.userid];
        }
        /*   添加弹幕回调    */
        [self inserDanMuBlock:block WithModel:model];
        /*  处理消息  */
        [self dealWithModel:model];
        [self.publicChatArray addObject:model];
    }
}
//添加广播消息
-(void)addRadioMessage:(NSDictionary *)dic{
    CCPublicChatModel *model = [[CCPublicChatModel alloc] init];
    model.msg = [NSString stringWithFormat:@"系统消息：%@",dic[@"value"][@"content"]];
    
    //设置广播消息UI布局
    model.typeState = RadioState;
    
    //计算广播行高,并返回cellheight;
    model.cellHeight = [self getRadioCellHeightWith:model];
    [self.publicChatArray addObject:model];
}
#pragma mark - 处理model
-(void)dealWithModel:(CCPublicChatModel *)model{
    
    //处理消息头像和文本
    [self dealIconAndTextColorWith:model];
    
    //判断是否有图片
    BOOL haveImg = [model.msg containsString:IMGURL];//是否含有图片
    if (haveImg) {//如果有图片，
        NSString *url = [self getUrlWithMessage:model.msg];
        model.msg = url;
        model.typeState = ImageState;
        model.cellHeight = [self getImageCellHeightWith:model];
//        model.imageSize = CGSizeMake(50, 50);
//        model.textSize = CGSizeZero;
//        model.cellHeight = 80;
    }else{//纯文本消息
        model.cellHeight = [self getTextCellHeightWith:model];
        model.typeState = TextState;
        model.imageSize = CGSizeMake(0, 0);
    }
}
#pragma mark - 添加弹幕消息

/**
 添加弹幕消息

 @param block 弹幕回调
 @param model 消息模型
 */
-(void)inserDanMuBlock:(InsertDanMuBlock)block WithModel:(CCPublicChatModel *)model {
    if (model == nil) {
        return;
    }
    //判断消息方是否是自己
    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];
    BOOL haveImg = [model.msg containsString:IMGURL];//是否含有图片
    //聊天审核-------------如果消息状态码为1,不显示此消息,状态栏可能没有
    /*  没有图片的消息和没有通过聊天审核的消息添加弹幕消息   */
    if (!haveImg){
        if (model.status && [model.status isEqualToString:@"1"] && !fromSelf){
            return;
        }else{
            //弹幕回调
            block(model);
        }
    }
}
#pragma mark - 解析图片消息
//处理msg,得到url
-(NSString *)getUrlWithMessage:(NSString *)msg{
    //------------解析图片地址-------start---------
    //从字符A中分隔成2个元素的数组
    NSArray *getTitleArray = [msg componentsSeparatedByString:IMGURL];
    //去除前缀
    NSString *url = [NSString stringWithFormat:@"%@", getTitleArray[1]];
    NSArray *arr = [url componentsSeparatedByString:@"]"];
    //去除后缀，得到url
    url = [NSString stringWithFormat:@"%@", arr[0]];
    return url;
}
#pragma mark - 处理头像和字体颜色

-(void)dealIconAndTextColorWith:(CCPublicChatModel *)model{
    NSString * str;
    NSString *colorWithHexString = @"#79808b";
    NSString *headImageName = @"";
    if(StrNotEmpty(model.useravatar) && [model.useravatar containsString:@"http"]) {
        if ([model.userrole isEqualToString:@"publisher"]) {//主讲
            str = @"lecturer_nor";
            colorWithHexString = @"#12ad1a";
        } else if ([model.userrole isEqualToString:@"student"]) {//学生或观众
            str = @"role_floorplan";
        } else if ([model.userrole isEqualToString:@"host"]) {//主持人
            str = @"compere_nor";
            colorWithHexString = @"#12ad1a";
        } else if ([model.userrole isEqualToString:@"unknow"]) {//其他没有角色
            str = @"role_floorplan";
        } else if ([model.userrole isEqualToString:@"teacher"]) {//助教
            str = @"assistant_nor";
            colorWithHexString = @"#12ad1a";
        } else{
            str = @"role_floorplan";
        }
    } else {
        if ([model.userrole isEqualToString:@"publisher"]) {//主讲
            headImageName = @"chatHead_lecturer";
            str = @"lecturer_nor";
            colorWithHexString = @"#12ad1a";
        } else if ([model.userrole isEqualToString:@"student"]) {//学生或观众
            headImageName = @"chatHead_student";
            str = @"role_floorplan";
            
        } else if ([model.userrole isEqualToString:@"host"]) {//主持人
            headImageName = @"chatHead_compere";
            str = @"compere_nor";
            colorWithHexString = @"#12ad1a";
        } else if ([model.userrole isEqualToString:@"unknow"]) {//其他没有角色
            headImageName = @"chatHead_user_five";
            str = @"role_floorplan";
            
        } else if ([model.userrole isEqualToString:@"teacher"]) {//助教
            headImageName = @"chatHead_assistant";
            str = @"assistant_nor";
            colorWithHexString = @"#12ad1a";
        } else {
            headImageName = @"chatHead_user_five";
            str = @"role_floorplan";
        }
    }
    //设置model的头像，头像标示，文本颜色
    model.headImgName = headImageName;
    model.headTag = str;
    model.textColorHexing = colorWithHexString;
}
#pragma mark - 计算行高
//计算广播行高
-(CGFloat)getRadioCellHeightWith:(CCPublicChatModel *)model{
    //返回广播消息的cell高度
    float textMaxWidth = CCGetRealFromPt(560);
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:model.msg y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(248,129,25) range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.minimumLineHeight = CCGetRealFromPt(34);
    style.maximumLineHeight = CCGetRealFromPt(34);
    style.lineBreakMode = UILineBreakModeWordWrap;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_24],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.height = ceilf(textSize.height);// + 1;
    model.textSize = textSize;
    return textSize.height + CCGetRealFromPt(18) * 2 + CCGetRealFromPt(30);
}
//计算纯文本行高
-(CGFloat)getTextCellHeightWith:(CCPublicChatModel *)model{
    CGFloat height;
    //计算文本高度
    //todo  用户名为特殊字符时，算不出redRange
    if (!model.username.length) {
        model.username = @"_";
    }
    float textMaxWidth = CCGetRealFromPt(438);
    NSString * textAttr = [NSString stringWithFormat:@"%@:%@",model.username,model.msg];
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:textAttr y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
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
    textSize.height = ceilf(textSize.height);// + 1;
    //添加消息内容
    height = textSize.height + CCGetRealFromPt(18) * 2;
    //计算气泡的宽度和高度
    if(height < CCGetRealFromPt(80)) {//计算高度
        height = CCGetRealFromPt(80) + 20;
    } else {
        height = textSize.height + CCGetRealFromPt(18) * 2 + 20;
    };
    model.textSize = textSize;
    return height;
}
//计算图片行高
-(CGFloat)getImageCellHeightWith:(CCPublicChatModel *)model{
    CGFloat height;
    CGSize imgSize = CGSizeZero;
    //计算文本高度
    float textMaxWidth = CCGetRealFromPt(438);
    NSString * textAttr = [NSString stringWithFormat:@"%@:",model.username];
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:textAttr y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
    
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
    textSize.height = ceilf(textSize.height);// + 1;
    //添加消息内容
    height = textSize.height + CCGetRealFromPt(18) * 2;
    //计算图片的高度
    //判断是否下载过,如果下载过，计算图片高度
    if ([[self.downloadDic allKeys] containsObject:[NSString stringWithFormat:@"%@", model.msg]]) {
        //解析保存的图片大小
        NSString *size = self.downloadDic[[NSString stringWithFormat:@"%@", model.msg]];
        NSArray *getSizeArray = [size componentsSeparatedByString:@"_"];
        //去除前缀
        imgSize.width = [[getSizeArray firstObject] floatValue];
        imgSize.height = [[getSizeArray lastObject] floatValue];
    }else{
        UIImage *image = [UIImage imageNamed:@"picture_loading"];
        imgSize = image.size;
    }
    height += imgSize.height;
    //计算气泡的宽度和高度
    if(height < CCGetRealFromPt(80)) {//计算高度
        height = CCGetRealFromPt(80) + 20;
    } else {
        height = textSize.height + CCGetRealFromPt(18) * 2 + 20 + imgSize.height;
    };
    model.imageSize = imgSize;
    model.textSize = textSize;
    return height;
}
//判断是否已经下载过这张图片
-(BOOL)existImageWithUrl:(NSString *)url{
    if ([[self.downloadDic allKeys] containsObject:[NSString stringWithFormat:@"%@", url]]){
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - 私聊图片
/**
 添加一个私聊下载过的图片

 @param url 图片链接
 @param size 图片的大小
 */
-(void)setURL:(NSString *)url withImageSize:(CGSize)size{
    [self.downloadDic setObject:[NSString stringWithFormat:@"%lf_%lf", size.width, size.height] forKey:url];
}
-(CGSize)getImageSizeWithMsg:(NSString *)msg{
    NSString *url = [self getUrlWithMessage:msg];
    CGSize imgSize;
    if ([[self.downloadDic allKeys] containsObject:url]) {//如果下载过这张图片
        //解析保存的图片大小
        NSString *size = self.downloadDic[[NSString stringWithFormat:@"%@", url]];
        NSArray *getSizeArray = [size componentsSeparatedByString:@"_"];
        //去除前缀
        imgSize.width = [[getSizeArray firstObject] floatValue];
        imgSize.height = [[getSizeArray lastObject] floatValue];
        return imgSize;
    }else{
//        NSLog(@"没有下载过这张图片");
        imgSize.width = 20.f;
        imgSize.height = 20.f;
        return imgSize;
    }
}
#pragma mark - 更新对应indexPath的行高
-(void)updateCellHeightWithIndexPath:(NSIndexPath *)indexPath imageSize:(CGSize)imageSize{
    if (self.publicChatArray.count == 0) {
        return;
    }
    CCPublicChatModel *model = [self.publicChatArray objectAtIndex: indexPath.row];
    model.imageSize = [self getCGSizeWithImageSize:imageSize];
    CGFloat cellHeight;
    cellHeight = model.textSize.height + CCGetRealFromPt(18) * 2 + model.imageSize.height;
    //计算气泡的宽度和高度
    if(cellHeight < CCGetRealFromPt(80)) {//计算高度
        cellHeight = CCGetRealFromPt(80) + 20;
    } else {
        cellHeight = model.textSize.height + CCGetRealFromPt(18) * 2 + 20 + model.imageSize.height;
    };
    model.cellHeight = cellHeight;
    //更新公聊数组状态
    [self.publicChatArray replaceObjectAtIndex:indexPath.row withObject:model];
    if (self.delegate) {//更新这一行
        [self.delegate updateIndexPath:indexPath chatArr:self.publicChatArray];
    }
    //将下载好的图片信息存储到downDic中
    
    [self.downloadDic setObject:[NSString stringWithFormat:@"%lf_%lf", model.imageSize.width, model.imageSize.height] forKey:model.msg];
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
#pragma mark - 清理缓存
-(void)removeData{
    if (self.publicChatArray != nil) {
        [self.publicChatArray removeAllObjects];
    }
//    [self.downloadDic removeAllObjects];
}
#pragma mark - 懒加载
//公聊数组
-(NSMutableArray *)publicChatArray{
    if (!_publicChatArray) {
        _publicChatArray = [NSMutableArray array];
    }
    return _publicChatArray;
}
//图片下载dic
-(NSMutableDictionary *)downloadDic{
    if (!_downloadDic) {
        _downloadDic = [NSMutableDictionary dictionary];
    }
    return _downloadDic;
}
@end
