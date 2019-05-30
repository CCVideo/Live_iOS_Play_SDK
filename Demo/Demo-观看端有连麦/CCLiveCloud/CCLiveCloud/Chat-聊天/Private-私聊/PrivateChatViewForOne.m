//
//  CCPrivateChatView.m
//  NewCCDemo
//
//  Created by cc on 2016/12/7.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "PrivateChatViewForOne.h"
//#import "PrivateDialogue.h"
#import "Dialogue.h"
#import "UIImage+Extension.h"
#import "Utility.h"
//#import "CCPush/CCPushUtil.h"
#import "InformationShowView.h"
#import "CCPrivateChatViewCell.h"
#import "CCChatViewDataSourceManager.h"

@interface PrivateChatViewForOne()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,strong)UIView                   *topView;//顶部视图
@property(nonatomic,strong)UILabel                  *titleLabel;//标题文本
@property(nonatomic,strong)UIButton                 *closeButton;//关闭按钮
@property(nonatomic,strong)UIButton                 *returnButton;//返回按钮
@property(nonatomic,strong)UITableView              *tableView;//私聊tableView
@property(nonatomic,strong)UIView                   *contentView;//输入框视图
@property(nonatomic,strong)UIButton                 *rightView;//右侧表情按钮

@property(nonatomic,strong)UIView                   *emojiView;//表情输入视图
@property(nonatomic,assign)CGRect                   keyboardRect;//键盘
@property(nonatomic,copy)  NSString                 *viewerId;//viewerId
@property(nonatomic,copy)  NSString                 *anteid;//私聊id
@property(nonatomic,copy)  NSString                 *anteName;//私聊昵称

@property(nonatomic,copy)  CloseBtnClicked          closeBlock;//关闭回调
@property(nonatomic,copy)  ChatIcBtnClicked         chatBlock;//聊天回调
@property(nonatomic,copy)  IsResponseBlock          isResponseBlock;//回复回调
@property(nonatomic,copy)  IsNotResponseBlock       isNotResponseBlock;//不回复回调
@property(nonatomic,strong)NSMutableArray           *dataArrayForOne;//私聊数组数组

@property(nonatomic,assign)Boolean                  isScreenLandScape;//是否是全屏
@property(nonatomic, copy)UIView                    *bottomLine;//底部视图
@property(nonatomic, copy)UIView                    *topLine;//顶部分界线
@property(nonatomic,strong)InformationShowView      *informationView;//提示视图

@end

@implementation PrivateChatViewForOne

/**
 私聊界面初始化方法
 
 @param closeBlock 关闭回调
 @param chatBlock 聊天回调
 @param isResponseBlock 回复回调
 @param isNotResponseBlock 不回复回调
 @param dataArrayForOne 私聊数据数组
 @param anteid 私聊id
 @param anteName 私聊昵称
 @param isScreenLandScape 是否是全屏
 @return self
 */
-(instancetype)initWithCloseBlock:(CloseBtnClicked)closeBlock ChatClicked:(ChatIcBtnClicked)chatBlock isResponseBlock:(IsResponseBlock)isResponseBlock isNotResponseBlock:(IsNotResponseBlock)isNotResponseBlock dataArrayForOne:(NSMutableArray *)dataArrayForOne anteid:(NSString *)anteid anteName:(NSString *)anteName isScreenLandScape:(BOOL)isScreenLandScape {
    self = [super init];
    if(self) {
//        NSLog(@"创建私聊forOne");
        self.isScreenLandScape = isScreenLandScape;
        self.anteid = anteid;
        self.anteName = anteName;
        self.dataArrayForOne = dataArrayForOne;
        self.closeBlock = closeBlock;
        self.chatBlock = chatBlock;
        self.isResponseBlock = isResponseBlock;
        self.isNotResponseBlock = isNotResponseBlock;
        
        self.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.f];
        [self addSubviews];
        [self addObserver];
    }

    return self;
}
//底部分界线
-(UIView *)bottomLine {
    if(!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = CCRGBColor(221, 221, 221);
    }
    return _bottomLine;
}
//顶部分界线
-(UIView *)topLine {
    if(!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = CCRGBColor(221, 221, 221);
    }
    return _topLine;
}

/**
 视图销毁
 */
-(void)dealloc {
    [self removeObserver];//移除通知
//    NSLog(@"移除私聊forOne");
}
#pragma mark - 设置UI布局

/**
 UI布局
 */
-(void)addSubviews {
    //添加顶部分界线
    [self addSubview:self.topLine];
    WS(ws)
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(ws);
        make.height.mas_equalTo(1);
    }];
    //添加顶部视图
    [self addSubview:self.topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.topLine);
        make.top.mas_equalTo(ws.topLine.mas_bottom);
        make.height.mas_equalTo(CCGetRealFromPt(100));
    }];
    //添加顶部标题
    [self.topView addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(ws.topView);
        make.left.mas_equalTo(ws.topView).offset(CCGetRealFromPt(100));
        make.right.mas_equalTo(ws.topView).offset(-CCGetRealFromPt(100));
    }];
    //添加关闭按钮
    [self.topView addSubview:self.closeButton];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.topView);
        make.right.mas_equalTo(ws.topView).offset(-CCGetRealFromPt(30));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(76), CCGetRealFromPt(76)));
    }];
    //添加返回按钮
    [self.topView addSubview:self.returnButton];
    [_returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.topView);
        make.left.mas_equalTo(ws.topView).offset(CCGetRealFromPt(30));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(76), CCGetRealFromPt(76)));
    }];
    //添加底部分界线
    [self addSubview:self.bottomLine];
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.topView);
        make.top.mas_equalTo(ws.topView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    //添加输入视图
    [self addSubview:self.contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws);
        make.bottom.mas_equalTo(ws).offset(-CCGetRealFromPt(4));
        make.height.mas_equalTo(CCGetRealFromPt(90));
    }];
    //添加输入框
    [self.contentView addSubview:self.chatTextField];
    [_chatTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        if(!ws.isScreenLandScape) {
            make.top.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(10));
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(20));
            make.right.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(20));
            make.height.mas_equalTo(CCGetRealFromPt(70));
        } else {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(1134), CCGetRealFromPt(84)));
        }
    }];
    //添加私聊视图
    [self addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws);
        make.top.mas_equalTo(ws.bottomLine.mas_bottom);
        make.bottom.mas_equalTo(ws.contentView.mas_top);
    }];
    
    //刷新消息，回到最后一行
    if([self.dataArrayForOne count] >= 1){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self layoutIfNeeded];
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([self.dataArrayForOne count]-1) inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
    
    //添加手势，单击退出键盘
    UITapGestureRecognizer *hideTextBoardTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleInformationTap)];
    [self addGestureRecognizer:hideTextBoardTap];
}


/**
 退出键盘
 */
-(void)dealSingleInformationTap {
    [self endEditing:YES];
}
//返回按钮
-(UIButton *)returnButton {
    if(!_returnButton) {
        _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_returnButton setImage:[UIImage imageNamed:@"nav_ic_back_nor"] forState:UIControlStateNormal];
        _returnButton.contentMode = UIViewContentModeScaleAspectFit;
        [_returnButton addTarget:self action:@selector(returnBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _returnButton;
}
//关闭按钮
-(UIButton *)closeButton {
    if(!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
        _closeButton.contentMode = UIViewContentModeScaleAspectFit;
        [_closeButton addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

/**
 点击关闭按钮
 */
-(void)closeBtnClicked {
    [_chatTextField resignFirstResponder];
    if(self.closeBlock) {
        self.closeBlock();//关闭回调
    }
}

/**
 点击返回按钮
 */
-(void)returnBtnClicked {
    [_chatTextField resignFirstResponder];
//    [self removeFromSuperview];
    if(self.chatBlock) {
        self.chatBlock();//聊天回调
    }
}

/**
 移除提示视图
 */
-(void)informationViewRemove {
    [_informationView removeFromSuperview];
    _informationView = nil;
}
//顶部视图
-(UIView *)topView {
    if(!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = CCRGBAColor(248,248,248,0.96);
        _topView.layer.shadowColor = CCRGBColor(221,221,221).CGColor;
        _topView.layer.shadowOffset = CGSizeMake(1, 1);
    }
    return _topView;
}
//顶部标题
-(UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.backgroundColor = CCClearColor;
        _titleLabel.textColor = CCRGBColor(51,51,51);
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_32];
        _titleLabel.text = _anteName;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

//tableView
-(UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

/**
 更新私聊数据

 @param dataArray 更新私聊数据
 */
-(void)updateDataArray:(NSMutableArray *)dataArray {
    _dataArrayForOne = dataArray;
    
    if([self.dataArrayForOne count] >= 1){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([self.dataArrayForOne count]-1) inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
}
#pragma mark - tableViewDataSource Delegate
//设置footer行高
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CCGetRealFromPt(26);
}
//设置footer视图
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CCGetRealFromPt(26))];
    view.backgroundColor = CCClearColor;
    return view;
}
//计算行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Dialogue *dialog = [_dataArrayForOne objectAtIndex:indexPath.row];
    BOOL haveImage = [dialog.msg containsString:@"[img_"];
    if (haveImage) {
        CGSize imageSize = [[CCChatViewDataSourceManager sharedManager] getImageSizeWithMsg:dialog.msg];
        return imageSize.height + 40;
    }
    //设置文字最大宽度
    float textMaxWidth = CCGetRealFromPt(438);
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:dialog.msg y:-8];
    //计算行高
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
    CGFloat height = textSize.height + CCGetRealFromPt(18) * 2;
    height = height < CCGetRealFromPt(80)?CCGetRealFromPt(80):height;//设置最低高度
    return height + CCGetRealFromPt(36);
}
//设置cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PrivateCellChatView";
    
    CCPrivateChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CCPrivateChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    } else {
//        for(UIView *cellView in cell.subviews){
//            [cellView removeFromSuperview];
//        }
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //设置cel的样式
    Dialogue *model = [_dataArrayForOne objectAtIndex:indexPath.row];
    [cell setModel:model WithIndexPath:indexPath];
//    [self initCell:cell indexPath:indexPath];
    WS(weakSelf)
    cell.reloadIndexPath = ^(NSIndexPath * _Nonnull indexPath) {
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        //判断当前行数是否是最后一行，如果是,刷新至最后一行
        NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.dataArrayForOne.count - 1) inSection:0];
        if (indexPath.row == indexPathLast.row) {
            [self.tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];;
        }
    };
    return cell;
}

///**
// 生成一个指定样式的图片，视图转图片
//
// @param v 需要处理的视图
// @return 处理后的图片
// */
//-(UIImage*)convertViewToImage:(UIView*)v{
//    CGSize s = v.bounds.size;
//    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
//    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
//    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}
//返回Section数目
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//返回cell总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArrayForOne count];
}
//点击cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEditing:YES];
}
#pragma mark - 设置cell的布局

///**
// 初始化头像的布局
//
// @param cell cell
// @param fromSelf 是否是自己
// @param fromuserrole 身份
// @return 头像
// */
//-(UIImageView *)addHeadView:(UITableViewCell *)cell mySelf:(BOOL)fromSelf fromuserrole:(NSString *)fromuserrole{
//    UIImageView *head = [[UIImageView alloc] init];
//    head.backgroundColor = CCClearColor;
//    head.contentMode = UIViewContentModeScaleAspectFit;
//    head.userInteractionEnabled = NO;
//    //设置头像的图片
//    //处理图片
//    NSArray *arr = [self dealWithFromuserrole:fromuserrole];
//    head.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", arr[1]]];
//    
//    UIImageView * imageid= [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", arr[0]]]];
//    [head addSubview:imageid];
//    [imageid mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(head);
//    }];
//    //设置头像的图片-----end
//    [cell addSubview:head];
//    if(fromSelf) {//消息方是自己,头像居右
//        [head mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(cell).offset(-CCGetRealFromPt(30));
//            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(20));
//            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
//        }];
//    } else {//消息方不是自己，头像居左
//        [head mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(cell).offset(CCGetRealFromPt(30));
//            make.top.mas_equalTo(cell).offset(CCGetRealFromPt(20));
//            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80),CCGetRealFromPt(80)));
//        }];
//    }
//    return head;
//}
//
///**
// 根据身份处理图片
// 
// @param fromuserrole fromuserrole description
// */
//-(NSArray *)dealWithFromuserrole:(NSString *)fromuserrole{
//    NSString * str;//身份标识
//    NSString *headImgName;//头像名称
//    if ([fromuserrole isEqualToString:@"publisher"]) {//主讲
//        str = @"lecturer_nor";
//        headImgName = @"chatHead_lecturer";
//    } else if ([fromuserrole isEqualToString:@"student"]) {//学生或观众
//        str = @"role_floorplan";
//        headImgName = @"chatHead_student";
//    } else if ([fromuserrole isEqualToString:@"host"]) {//主持人
//        str = @"compere_nor";
//        headImgName = @"chatHead_compere";
//    } else if ([fromuserrole isEqualToString:@"unknow"]) {//其他没有角色
//        str = @"role_floorplan";
//        headImgName = [NSString stringWithFormat:@"用户%d", arc4random_uniform(5) + 1];
//    } else if ([fromuserrole isEqualToString:@"teacher"]) {//助教
//        str = @"assistant_nor";
//        headImgName = @"chatHead_assistant";
//    }
//    NSArray *arr = [NSArray arrayWithObjects:str, headImgName, nil];
//    return arr;
//}
////设置cell样式
//-(void)initCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
//    Dialogue *dialog = [_dataArrayForOne objectAtIndex:indexPath.row];
//    BOOL fromSelf = [dialog.fromuserid isEqualToString:dialog.myViwerId];
//    //添加head
//    UIImageView *head = [self addHeadView:cell mySelf:fromSelf fromuserrole:dialog.fromuserrole];
//    
//    //设置气泡
//    UIButton *bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cell addSubview:bgButton];
//    
//    //判断是否有图片
//    BOOL haveImg = [dialog.msg containsString:@"[img_"];
//    if (haveImg) {
//        dialog.msg = @"[图片]";
//    }
//    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:dialog.msg y:-8];
//    CGSize textSize = [self getCGSizeWithAttriStr:textAttri];
//    //计算label的高度
//    CGFloat height = textSize.height + CCGetRealFromPt(18) * 2;
//    UILabel *contentLabel = [UILabel new];
//    contentLabel.numberOfLines = 0;
//    contentLabel.backgroundColor = CCClearColor;
//    contentLabel.textAlignment = NSTextAlignmentLeft;
//    contentLabel.userInteractionEnabled = NO;
//    contentLabel.attributedText = textAttri;
//    [bgButton addSubview:contentLabel];
//    if(fromSelf) {
//        contentLabel.textColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.f];
//    }else{
//        contentLabel.textColor = [UIColor colorWithHexString:@"#1e1f21" alpha:1.f];
//    }
//    float width = textSize.width + CCGetRealFromPt(30) + CCGetRealFromPt(20);
//    height = height < CCGetRealFromPt(60)?CCGetRealFromPt(60):(textSize.height + CCGetRealFromPt(18) * 2);
//    [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        if(fromSelf){//判断是否是自己
//            make.right.mas_equalTo(head.mas_left).offset(-CCGetRealFromPt(22));
//        }else{
//            make.left.mas_equalTo(head.mas_right).offset(CCGetRealFromPt(22));
//        }
//        make.top.mas_equalTo(head);
//        make.size.mas_equalTo(CGSizeMake(width, height));
//    }];
//    [bgButton layoutIfNeeded];
//    //设置contentLabel的约束
//    float offset = fromSelf?CCGetRealFromPt(20):CCGetRealFromPt(30);
//    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(bgButton).offset(offset);
//        make.centerY.mas_equalTo(bgButton).offset(-1);
//        make.size.mas_equalTo(CGSizeMake(textSize.width, textSize.height + 1));
//    }];
//    //处理气泡显示样式
//    [self dealWithBgBtn:bgButton fromSelf:fromSelf];
//}
//
///**
// 计算文字的大小
//
// @param textAttri 富文本
// @return 计算过的文字宽高
// */
//-(CGSize)getCGSizeWithAttriStr:(NSMutableAttributedString *)textAttri{
//    float textMaxWidth = CCGetRealFromPt(438);
//    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    style.minimumLineHeight = CCGetRealFromPt(36);
//    style.maximumLineHeight = CCGetRealFromPt(60);
//    style.alignment = NSTextAlignmentLeft;
//    style.lineBreakMode = NSLineBreakByCharWrapping;
//    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],NSParagraphStyleAttributeName:style};
//    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
//    
//    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
//                                              options:NSStringDrawingUsesLineFragmentOrigin
//                                              context:nil].size;
//    textSize.width = ceilf(textSize.width);
//    textSize.height = ceilf(textSize.height);// + 1;
//    return textSize;
//}
//
///**
// 处理气泡显示样式
//
// @param bgButton 气泡btn
// @param fromSelf 是否是自己
// */
//-(void)dealWithBgBtn:(UIButton *)bgButton fromSelf:(BOOL)fromSelf{
//    UIImage *bgImage = nil;
//    UIView * bgView = [[UIView alloc] init];
//    bgView.backgroundColor = [UIColor whiteColor];
//    if (fromSelf) {
//        bgView.backgroundColor = [UIColor colorWithHexString:@"#ff8e47" alpha:1.f];
//    }
//    bgView.frame = bgButton.frame;
//    //设置所需的圆角位置以及大小
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bgView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | (fromSelf ?UIRectCornerTopLeft:UIRectCornerTopRight) cornerRadii:CGSizeMake(10, 10)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = bgView.bounds;
//    maskLayer.path = maskPath.CGPath;
//    bgView.layer.mask = maskLayer;
//    bgImage = [self convertViewToImage:bgView];
//    [bgButton setBackgroundImage:bgImage forState:UIControlStateDisabled];
//    [bgButton setBackgroundImage:bgImage forState:UIControlStateNormal];
//    bgButton.userInteractionEnabled = YES;
//    bgButton.enabled = NO;
//}
#pragma mark - 键盘将要返回
//键盘将要返回时
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(!StrNotEmpty([_chatTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]])) {//如果消息为空,弹出提示
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:ALERT_EMPTYMESSAGE];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        //2.0秒后移除弹窗视图
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(informationViewRemove) userInfo:nil repeats:NO];
        return YES;
    }
    [self chatSendMessage];
    return YES;
}

/**
 发送聊天
 */
-(void)chatSendMessage {
    NSString *str = _chatTextField.text;
    if(str == nil || str.length == 0) {
        return;
    }
    //初始化发送的消息，anteid,接收人的id;str,发送的消息
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_anteid forKey:@"anteid"];
    [dic setObject:str forKey:@"str"];
    
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"private_Chat" object:dic];
    
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}
#pragma mark - 添加通知
-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.chatTextField isFirstResponder]) {
        return;
    }
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
//    CGFloat x = _keyboardRect.size.width;
//    NSLog(@"键盘高度是  %d",(int)y);
//    NSLog(@"键盘宽度是  %d",(int)x);
    WS(ws)
//    NSLog(@"PrivateChatViewForOne isResponseBlock");
    if(ws.isResponseBlock) {
        ws.isResponseBlock(y);
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    //todo 多个人发送私聊，公聊中点击某个人头像，然后公聊发送消息，回调用此方法，导致发送公聊，私聊列表弹出。
    //初步判断，内存泄露，没有及时释放某个1V1私聊，导致走了这个回调
//    NSLog(@"私聊显示:%d", self.hidden?1:0);
    if(self.isNotResponseBlock) {
        self.isNotResponseBlock();
    }
}

#pragma mark - 懒加载
//输入视图
-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = CCRGBAColor(171,179,189,0.30);
    }
    return _contentView;
}
//聊天输入框
-(CustomTextField *)chatTextField {
    if(!_chatTextField) {
        _chatTextField = [[CustomTextField alloc] init];
        _chatTextField.delegate = self;
        _chatTextField.placeholder = PRIVATE_PLACEHOLDER;
         _chatTextField.layer.cornerRadius = CCGetRealFromPt(35);
        [_chatTextField addTarget:self action:@selector(chatTextFieldChange) forControlEvents:UIControlEventEditingChanged];
        _chatTextField.rightView = self.rightView;
    }
    return _chatTextField;
}

/**
 输入内容改变
 */
-(void)chatTextFieldChange {
    if(_chatTextField.text.length > 300) {
        _chatTextField.text = [_chatTextField.text substringToIndex:300];
    }
}
//右侧视图
-(UIButton *)rightView {
    if(!_rightView) {
        _rightView = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightView.frame = CGRectMake(0, 0, 40, 40);
        _rightView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightView.backgroundColor = CCClearColor;
        //        [_rightView setBackgroundImage:[UIImage imageNamed:@"face_nov"] forState:UIControlStateNormal];
        [_rightView setImage:[UIImage imageNamed:@"face_nov"] forState:UIControlStateNormal];
        [_rightView setImage:[UIImage imageNamed:@"face_hov"] forState:UIControlStateSelected];
        [_rightView addTarget:self action:@selector(faceBoardClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightView;
}
//点击表情按钮
- (void)faceBoardClick {
    BOOL selected = !_rightView.selected;
    _rightView.selected = selected;
    
    if(selected) {
        [_chatTextField setInputView:self.emojiView];
    } else {
        [_chatTextField setInputView:nil];
    }
    
    [_chatTextField becomeFirstResponder];
    [_chatTextField reloadInputViews];
}
//表情视图
-(UIView *)emojiView {
    if(!_emojiView) {
        if(_keyboardRect.size.width == 0 || _keyboardRect.size.height ==0) {
            _keyboardRect = CGRectMake(0, 0, SCREEN_WIDTH, 271);
        }
        _emojiView = [[UIView alloc] initWithFrame:_keyboardRect];
        _emojiView.backgroundColor = CCRGBColor(242,239,237);
        
        CGFloat faceIconSize = CCGetRealFromPt(60);
        CGFloat xspace = (_keyboardRect.size.width - FACE_COUNT_CLU * faceIconSize) / (FACE_COUNT_CLU + 1);
        CGFloat yspace = (_keyboardRect.size.height - 26 - FACE_COUNT_ROW * faceIconSize) / (FACE_COUNT_ROW + 1);
        
        for (int i = 0; i < FACE_COUNT_ALL; i++) {
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.tag = i + 1;
            
            [faceButton addTarget:self action:@selector(faceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            //            计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = (i % FACE_COUNT_CLU + 1) * xspace + (i % FACE_COUNT_CLU) * faceIconSize;
            CGFloat y = (i / FACE_COUNT_CLU + 1) * yspace + (i / FACE_COUNT_CLU) * faceIconSize;
            
            faceButton.frame = CGRectMake(x, y, faceIconSize, faceIconSize);
            faceButton.backgroundColor = CCClearColor;
            [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%02d", i+1]]
                        forState:UIControlStateNormal];
            faceButton.contentMode = UIViewContentModeScaleAspectFit;
            [_emojiView addSubview:faceButton];
        }
        //删除键
        UIButton *button14 = (UIButton *)[_emojiView viewWithTag:14];
        UIButton *button20 = (UIButton *)[_emojiView viewWithTag:20];
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        back.contentMode = UIViewContentModeScaleAspectFit;
        [back setImage:[UIImage imageNamed:@"chat_btn_facedel"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        [_emojiView addSubview:back];
        
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(button14);
            make.centerY.mas_equalTo(button20);
        }];
    }
    return _emojiView;
}
//点击删除键
- (void) backFace {
    NSString *inputString = _chatTextField.text;
    if ( [inputString length] > 0) {
        NSString *string = nil;
        NSInteger stringLength = [inputString length];
        if (stringLength >= FACE_NAME_LEN) {
            string = [inputString substringFromIndex:stringLength - FACE_NAME_LEN];
            NSRange range = [string rangeOfString:FACE_NAME_HEAD];
            if ( range.location == 0 ) {
                string = [inputString substringToIndex:[inputString rangeOfString:FACE_NAME_HEAD options:NSBackwardsSearch].location];
            } else {
                string = [inputString substringToIndex:stringLength - 1];
            }
        }
        else {
            string = [inputString substringToIndex:stringLength - 1];
        }
        _chatTextField.text = string;
    }
}
//点击某个表情按钮
- (void)faceButtonClicked:(id)sender {
    NSInteger i = ((UIButton*)sender).tag;
    
    NSMutableString *faceString = [[NSMutableString alloc]initWithString:_chatTextField.text];
    [faceString appendString:[NSString stringWithFormat:@"[em2_%02d]",(int)i]];
    _chatTextField.text = faceString;
}

@end
