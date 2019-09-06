//
//  CCPrivateChatView.m
//  NewCCDemo
//
//  Created by cc on 2016/12/7.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCPrivateChatView.h"
//#import "PrivateDialogue.h"
#import "Dialogue.h"
#import "Utility.h"

@interface CCPrivateChatView()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UIView                   *topView;//顶部视图
@property(nonatomic,strong)UILabel                  *titleLabel;//顶部标题
@property(nonatomic,strong)UIButton                 *closeButton;//关闭按钮
@property(nonatomic,strong)UITableView              *tableView;//私聊tableView
@property(nonatomic,strong)NSMutableArray           *dataArray;//私聊数据数组
@property(nonatomic,copy)  CloseBtnClicked          closeBlock;//关闭回调
@property(nonatomic,copy)  IsResponseBlock          isResponseBlock;//回复回调
@property(nonatomic,copy)  IsNotResponseBlock       isNotResponseBlock;//不回复回调
@property(nonatomic,strong)NSMutableDictionary      *dataPrivateDic;//私聊字典
@property(nonatomic,copy) NSString                  *currentAnteid;//当前的私聊id
@property(nonatomic,copy) NSString                  *currentAnteName;//当前的私聊名称
@property(nonatomic,assign)Boolean                  isScreenLandScape;//是否是全屏
@property(nonatomic,copy)CheckDotBlock              checkDotBlock;//新消息标记
@property(nonatomic,copy)UIView                     *bottomLine;//底部分界线
@property(nonatomic,copy)UIView                     *topLine;//顶部分界线
//@property(nonatomic,assign)BOOL                     hiddenPrivateForOne;//隐藏私聊视图
@end

@implementation CCPrivateChatView


/**
 初始化方法

@param closeBlock 关闭按钮
@param isResponseBlock 回复回调
@param isNotResponseBlock 不回复回调
@param dataPrivateDic 私聊字典
@param isScreenLandScape 是否是全屏
@return self
*/
-(instancetype)initWithCloseBlock:(CloseBtnClicked)closeBlock isResponseBlock:(IsResponseBlock)isResponseBlock isNotResponseBlock:(IsNotResponseBlock)isNotResponseBlock dataPrivateDic:(NSMutableDictionary *)dataPrivateDic isScreenLandScape:(BOOL)isScreenLandScape{
    self = [super init];
    if(self) {
        self.isScreenLandScape = isScreenLandScape;
        self.dataPrivateDic = dataPrivateDic;
        self.closeBlock = closeBlock;
        self.isResponseBlock = isResponseBlock;
        self.isNotResponseBlock = isNotResponseBlock;
        self.backgroundColor = CCRGBAColor(250,250,250,0.96);
        [self addSubviews];
    }
    return self;
}
#pragma mark - 设置UI布局
-(void)dealloc{
//    NSLog(@"销毁私聊");
}
/**
 设置UI布局
 */
-(void)addSubviews {
    //添加顶部分界线
    [self addSubview:self.topLine];
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(1);
    }];
    //添加顶部视图
    [self addSubview:self.topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.topLine);
        make.top.mas_equalTo(self.topLine.mas_bottom);
        make.height.mas_equalTo(CCGetRealFromPt(100));
    }];
    [self.topView addSubview:self.titleLabel];
    //添加顶部文字
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.topView);
    }];
    //添加关闭按钮
    [self.topView addSubview:self.closeButton];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView);
        make.right.mas_equalTo(self.topView).offset(-CCGetRealFromPt(30));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(76), CCGetRealFromPt(76)));
    }];
    //添加底部分界线
    [self addSubview:self.bottomLine];
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.topView);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    //私聊视图
    [self addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.top.mas_equalTo(self.bottomLine.mas_bottom);
    }];
}
#pragma mark - 懒加载
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
//顶部视图
-(UIView *)topView {
    if(!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = CCRGBAColor(248,248,248,0.95);
        _topView.layer.shadowColor = CCRGBColor(221,221,221).CGColor;
        _topView.layer.shadowOffset = CGSizeMake(1, 1);
    }
    return _topView;
}
//顶部标题
-(UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = CCClearColor;
        _titleLabel.textColor = CCRGBColor(51,51,51);
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_32];
        _titleLabel.text = PRIVATE_LIST;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
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
    if(self.closeBlock) {
        self.closeBlock();//关闭按钮回调
    }
    [self checkDot];
}
//私聊视图tableView
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
//聊天数据数组
-(NSMutableArray *)dataArray {
    if(!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
#pragma mark - tableViewDataSource Delegate
//footer高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CCGetRealFromPt(26);
}
//设置footer视图
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CCGetRealFromPt(26))];
    view.backgroundColor = CCClearColor;
    return view;
}
//返回高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CCGetRealFromPt(141);
}
//返回行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}
//设置cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Dialogue *privateDialogue = [self.dataArray objectAtIndex:indexPath.row];

    static NSString *identifier = @"PrivateChatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
    } else {
        for(UIView *cellView in cell.subviews){
            [cellView removeFromSuperview];
        }
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //设置cell样式
    [self initCell:cell WithModel:privateDialogue];
    return cell;
}
#pragma mark - 设置cell的样式
/**
 设置头像视图

 @param fromuserrole 头像的身份
 @param tag 头像视图标记
 @return 头像视图
 */
-(UIImageView *)createHeadImage:(NSString *)fromuserrole tag:(NSInteger)tag{
    UIImageView *headImage = [[UIImageView alloc] init];
    headImage.backgroundColor = CCClearColor;
    headImage.contentMode = UIViewContentModeScaleAspectFit;
    headImage.userInteractionEnabled = NO;
    NSString * str;
    NSString * headImgName;
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
    } else {
        str = @"role_floorplan";
        headImgName = [NSString stringWithFormat:@"用户%d", arc4random_uniform(5) + 1];
    }
    headImage.image = [UIImage imageNamed:headImgName];
    //头像的标识
    UIImageView * imageid= [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
    [headImage addSubview:imageid];
    [imageid mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headImage);
    }];
    headImage.tag = tag;//设置头像标记
    return headImage;
}

/**
 设置昵称

 @param privateDialogue model
 @param tag 视图标记
 @return 昵称Label
 */
-(UILabel *)createNameLabel:(Dialogue *)privateDialogue tag:(NSInteger)tag{
    NSString *anteName = nil;
    if([privateDialogue.fromuserid isEqualToString:privateDialogue.myViwerId]) {
        anteName = privateDialogue.tousername;
    } else {
        anteName = privateDialogue.fromusername;
    }
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = anteName;
    nameLabel.backgroundColor = CCClearColor;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = [UIFont systemFontOfSize:FontSize_30];
    nameLabel.textColor = CCRGBColor(51,51,51);
    nameLabel.userInteractionEnabled = NO;
    nameLabel.tag = tag;
    return nameLabel;
}

/**
 消息label

 @param privateDialogue model
 @param tag 消息视图标记
 @return 消息视图
 */
-(UILabel *)createMsgLabel:(Dialogue *)privateDialogue tag:(NSInteger)tag{
    NSString *msg = privateDialogue.msg;
    BOOL haveImage = [privateDialogue.msg containsString:@"[img_"];
    if (haveImage) {
        msg = @"[图片]";
    }
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:msg y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(102,102,102) range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    
    UILabel *msgLabel = [[UILabel alloc] init];
    msgLabel.attributedText = textAttri;
    msgLabel.numberOfLines = 1;
    msgLabel.backgroundColor = CCClearColor;
    msgLabel.userInteractionEnabled = NO;
    msgLabel.tag = tag;
    return msgLabel;
}

/**
 时间文本显示

 @param privateDialogue model
 @param tag 视图标记
 @return 时间Label
 */
-(UILabel *)createTimeLabel:(Dialogue *)privateDialogue tag:(NSInteger)tag{
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = [privateDialogue.time substringToIndex:5];
    timeLabel.backgroundColor = CCClearColor;
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.font = [UIFont systemFontOfSize:FontSize_24];
    timeLabel.textColor = CCRGBColor(153,153,153);
    timeLabel.userInteractionEnabled = NO;
    timeLabel.tag = tag;
    return timeLabel;
}

/**
 设置cell的样式

 @param cell cell
 @param privateDialogue 私聊数据
 */
-(void)initCell:(UITableViewCell *)cell WithModel:(Dialogue *)privateDialogue{
    //添加头像
    UIImageView *headImage = [self createHeadImage:privateDialogue.fromuserrole tag:1];
    [cell addSubview:headImage];
    [headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell).offset(CCGetRealFromPt(30));
        make.centerY.mas_equalTo(cell);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
    }];
    //添加nameLabel
    UILabel *nameLabel = [self createNameLabel:privateDialogue tag:2];
    [cell addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headImage.mas_right).offset(CCGetRealFromPt(30));
        make.top.mas_equalTo(cell);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(300), CCGetRealFromPt(90)));
    }];
    //添加消息Label
    UILabel *msgLabel = [self createMsgLabel:privateDialogue tag:3];
    [cell addSubview:msgLabel];
    [msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameLabel);
        make.right.mas_equalTo(cell).offset(-CCGetRealFromPt(50));
        make.bottom.mas_equalTo(cell);
        make.height.mas_equalTo(CCGetRealFromPt(86));
    }];
    //添加timeLabel
    UILabel *timeLabel = [self createTimeLabel:privateDialogue tag:4];
    [cell addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell.mas_right).offset(-CCGetRealFromPt(125));
        make.right.mas_equalTo(cell);
        make.top.mas_equalTo(cell);
        make.height.mas_equalTo(CCGetRealFromPt(90));
    }];
    //添加footerView
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = CCRGBColor(238,238,238);
    footView.userInteractionEnabled = NO;
    footView.tag = 5;
    [cell addSubview:footView];
    [footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(cell);
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(cell).offset(CCGetRealFromPt(30));
        make.right.mas_equalTo(cell).offset(-CCGetRealFromPt(30));
    }];
    //设置新消息标识
    UIImageView *idot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatHead_newMessage"]];
    idot.contentMode = UIViewContentModeScaleAspectFit;
    [cell addSubview:idot];
    [idot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.mas_equalTo(headImage);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(20), CCGetRealFromPt(20)));
    }];
    idot.tag = 6;
    idot.hidden = !privateDialogue.isNew;
}
#pragma mark - 显示tableView
/**
 显示tableView
 */
-(void)showTableView {
    self.tableView.hidden = NO;
}

/**
 创建一个私聊对话视图
 
 @param dataArrayForOne 1对1 对话聊天数组
 @param anteid 私聊id
 @param anteName 私聊名称
 */
-(void)createPrivateChatViewForOne:(NSMutableArray *)dataArrayForOne anteid:(NSString *)anteid anteName:(NSString *)anteName {
    WS(ws)
    _privateChatViewForOne = [[PrivateChatViewForOne alloc] initWithCloseBlock:^{
        if(ws.closeBlock) {
            ws.closeBlock();
        }
        ws.tableView.hidden = NO;
        [ws checkDot];
    } ChatClicked:^{
        [ws.privateChatViewForOne removeFromSuperview];
//        ws.privateChatViewForOne = nil;
        ws.tableView.hidden = NO;
        [ws checkDot];
    } isResponseBlock:^(CGFloat y) {
        if(ws.isResponseBlock) {
            ws.isResponseBlock(y);
        }
    } isNotResponseBlock:^{
        if(ws.isNotResponseBlock) {
            ws.isNotResponseBlock();
        }
    } dataArrayForOne:[dataArrayForOne copy] anteid:anteid anteName:anteName isScreenLandScape:_isScreenLandScape];
    
    [self addSubview:self.privateChatViewForOne];
    self.tableView.hidden = YES;
    [_privateChatViewForOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws);
    }];
    _currentAnteid = anteid;
    _currentAnteName = anteName;
}
//点击某个cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_privateChatViewForOne) {
        [_privateChatViewForOne removeFromSuperview];
//        _privateChatViewForOne = nil;
    }
    Dialogue *globalDialogue = [self.dataArray objectAtIndex:indexPath.row];
    globalDialogue.isNew = NO;
    
    NSString *anteName = nil;
    NSString *anteid = nil;
    
    if([globalDialogue.fromuserid isEqualToString:globalDialogue.myViwerId]) {
        anteid = globalDialogue.touserid;
        anteName = globalDialogue.tousername;
    } else {
        anteid = globalDialogue.fromuserid;
        anteName = globalDialogue.fromusername;
    }
    //点击后隐藏新消息标识
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *idot = (UIImageView *)[cell viewWithTag:6];
    idot.hidden = YES;

    NSMutableArray *array = [self.dataPrivateDic objectForKey:anteid];
    
    [self createPrivateChatViewForOne:[array copy] anteid:anteid anteName:anteName];
    
    [self checkDot];
}


/**
 点击头像按钮

 @param dialogue 私聊数据模型
 */
-(void)selectByClickHead:(Dialogue *)dialogue {
    if(_privateChatViewForOne) {
        [_privateChatViewForOne removeFromSuperview];
//        _privateChatViewForOne = nil;
    }
    NSString *anteName = nil;
    NSString *anteid = nil;
    if([dialogue.fromuserid isEqualToString:dialogue.myViwerId]) {
        anteid = dialogue.touserid;
        anteName = dialogue.tousername;
    } else {
        anteid = dialogue.fromuserid;
        anteName = dialogue.fromusername;
    }
    NSMutableArray *array = [self.dataPrivateDic objectForKey:anteid];
    [self createPrivateChatViewForOne:[array mutableCopy] anteid:anteid anteName:anteName];
    
    for (Dialogue *dia in self.dataArray) {
        dia.isNew = NO;
    }
    [self.tableView reloadData];//更新tableView数据源
    
    [self checkDot];//检测是否是新消息
}


/**
 更新私聊字典

 @param dic 更新的字典
 */
-(void)reloadDict:(NSDictionary *)dic anteName:anteName anteid:anteid {
    self.dataPrivateDic = [dic mutableCopy];
    NSArray *array = [self.dataPrivateDic objectForKey:anteid];
    Dialogue *dialogue = [array lastObject];
    BOOL flag = NO;//设置标识
    for (Dialogue *dia in self.dataArray) {
        if(([dia.fromuserid isEqualToString:dialogue.fromuserid] && [dia.touserid isEqualToString:dialogue.touserid]) || ([dia.fromuserid isEqualToString:dialogue.touserid] && [dia.touserid isEqualToString:dialogue.fromuserid])) {
            [self.dataArray replaceObjectAtIndex:[self.dataArray indexOfObject:dia] withObject:dialogue];
            flag = YES;
            break;
        }
    }
    
    if(flag == NO) {
        [self.dataArray addObject:dialogue];
    }
    dialogue.isNew = YES;
    
    if(_privateChatViewForOne && [_currentAnteid isEqualToString:anteid] && [_currentAnteName isEqualToString:anteName]) {
        [self.privateChatViewForOne updateDataArray:[array copy]];
        dialogue.isNew = NO;
    }
    //处理聊天数据
    if([self.dataArray count] >= 1){
        [_dataArray sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
            Dialogue *dialogue1 = (Dialogue *)obj1;
            Dialogue *dialogue2 = (Dialogue *)obj2;
            
            if([dialogue1.time compare:dialogue2.time] == NSOrderedDescending) {
                return NSOrderedAscending;
            } else if([dialogue1.time compare:dialogue2.time] == NSOrderedAscending) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        //刷新tableView
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if(self.dataArray != nil && [self.dataArray count] != 0) {
                NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([self.dataArray count]-1) inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        });
    }
    [self checkDot];//检测是否是新消息
}

/**
 检测是否是新消息
 */
-(void)checkDot {
    /*   旧版本回调的消息标识回调        */
//    BOOL flag = NO;
//    for (Dialogue *dia in self.dataArray) {
//        if(dia.isNew == YES) {
//            flag = YES;
//            return;
//        }
//    }
//    if(self.checkDotBlock) {
//        self.checkDotBlock(flag);//新消息标识回调
//    }
    /*  新版本menuView新私聊消息回调   */
    int i = 0;
    for (Dialogue *dia in self.dataArray) {
        if (dia.isNew == NO) {
            i++;//判断i最终是否和dataArray count是否相等
        }
    }
    if (i == [self.dataArray count]) {
        //发送通知，移除新消息视图
        [[NSNotificationCenter defaultCenter] postNotificationName:@"remove_newPrivateMsg" object:self];
    }
}

/**
 设置标识回调

 @param block 标示回调
 */
-(void)setCheckDotBlock1:(CheckDotBlock)block {
    self.checkDotBlock = block;
}
/**
 隐藏或显示私聊视图
 
 @param hidden 是否隐藏
 */
-(void)hiddenPrivateViewForOne:(BOOL)hidden{
//    self.hiddenPrivateForOne = hidden;
}
-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    //todo 横竖屏旋转时私聊视图frame被更改
    CGRect rect = [UIScreen mainScreen].bounds;
    CGFloat width = rect.size.width > rect.size.height ? rect.size.height : rect.size.width;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835));
//    NSLog(@"私聊视图的frame:%@", self);
}
@end
