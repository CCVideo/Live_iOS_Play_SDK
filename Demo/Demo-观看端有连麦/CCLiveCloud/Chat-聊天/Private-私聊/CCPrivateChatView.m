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

@property(nonatomic,strong)UIView                   *topView;
@property(nonatomic,strong)UILabel                  *titleLabel;
@property(nonatomic,strong)UIButton                 *closeButton;
@property(nonatomic,strong)UITableView              *tableView;
@property(nonatomic,strong)NSMutableArray           *dataArray;
@property(nonatomic,copy)  CloseBtnClicked          closeBlock;
@property(nonatomic,copy)  IsResponseBlock          isResponseBlock;
@property(nonatomic,copy)  IsNotResponseBlock       isNotResponseBlock;
@property(nonatomic,strong)NSMutableDictionary      *dataPrivateDic;
@property(nonatomic,copy) NSString                  *currentAnteid;
@property(nonatomic,copy) NSString                  *currentAnteName;
@property(nonatomic,assign)Boolean                  isScreenLandScape;
@property(nonatomic,copy)CheckDotBlock              checkDotBlock;
@property(nonatomic,copy)UIView                     *bottomLine;
@property(nonatomic,copy)UIView                     *topLine;

@end

@implementation CCPrivateChatView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
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

-(UIView *)bottomLine {
    if(!_bottomLine) {
        _bottomLine = [UIView new];
        _bottomLine.backgroundColor = CCRGBColor(221, 221, 221);
    }
    return _bottomLine;
}

-(UIView *)topLine {
    if(!_topLine) {
        _topLine = [UIView new];
        _topLine.backgroundColor = CCRGBColor(221, 221, 221);
    }
    return _topLine;
}

-(void)addSubviews {
    [self addSubview:self.topLine];
    WS(ws)
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(ws);
        make.height.mas_equalTo(1);
    }];
    [self addSubview:self.topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.topLine);
        make.top.mas_equalTo(ws.topLine.mas_bottom);
        make.height.mas_equalTo(CCGetRealFromPt(100));
    }];
    [self.topView addSubview:self.titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.topView);
    }];
    
    [self.topView addSubview:self.closeButton];
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.topView);
        make.right.mas_equalTo(ws.topView).offset(-CCGetRealFromPt(30));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(76), CCGetRealFromPt(76)));
    }];
    
    [self addSubview:self.bottomLine];
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.topView);
        make.top.mas_equalTo(ws.topView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(ws);
        make.top.mas_equalTo(ws.bottomLine.mas_bottom);
    }];
}

-(UIView *)topView {
    if(!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = CCRGBAColor(248,248,248,0.95);
        _topView.layer.shadowColor = CCRGBColor(221,221,221).CGColor;
        _topView.layer.shadowOffset = CGSizeMake(1, 1);
    }
    return _topView;
}

-(UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = CCClearColor;
        _titleLabel.textColor = CCRGBColor(51,51,51);
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_32];
        _titleLabel.text = @"私聊列表";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

-(UIButton *)closeButton {
    if(!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
        _closeButton.contentMode = UIViewContentModeScaleAspectFit;
        [_closeButton addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(void)closeBtnClicked {
    if(self.closeBlock) {
        self.closeBlock();
    }
    [self checkDot];
}

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

-(NSMutableArray *)dataArray {
    if(!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CCGetRealFromPt(26);
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CCGetRealFromPt(26))];
    view.backgroundColor = CCClearColor;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CCGetRealFromPt(141);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Dialogue *privateDialogue = [self.dataArray objectAtIndex:indexPath.row];
    NSString *anteid = nil;
    if([privateDialogue.fromuserid isEqualToString:privateDialogue.myViwerId]) {
        anteid = privateDialogue.touserid;
    } else {
        anteid = privateDialogue.fromuserid;
    }

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
//test 设置头部样式------------start
    UIImageView *headImage = [[UIImageView alloc] init];
    headImage.backgroundColor = CCClearColor;
    headImage.contentMode = UIViewContentModeScaleAspectFit;
    headImage.userInteractionEnabled = NO;
    NSString * str;
    NSString *headImgName;
    if ([privateDialogue.fromuserrole isEqualToString:@"publisher"]) {//主讲
        str = @"lecturer_nor";
        headImgName = @"chatHead_lecturer";
    } else if ([privateDialogue.fromuserrole isEqualToString:@"student"]) {//学生或观众
        str = @"role_floorplan";
        headImgName = @"chatHead_student";
    } else if ([privateDialogue.fromuserrole isEqualToString:@"host"]) {//主持人
        str = @"compere_nor";
        headImgName = @"chatHead_compere";
    } else if ([privateDialogue.fromuserrole isEqualToString:@"unknow"]) {//其他没有角色
        str = @"role_floorplan";
        headImgName = [NSString stringWithFormat:@"用户%d", arc4random_uniform(5) + 1];
    } else if ([privateDialogue.fromuserrole isEqualToString:@"teacher"]) {//助教
        str = @"assistant_nor";
        headImgName = @"chatHead_assistant";
    }
    headImage.image = [UIImage imageNamed:headImgName];
    
    UIImageView * imageid= [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
    [headImage addSubview:imageid];
    [imageid mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headImage);
    }];
//test 设置头部样式-------------end
    NSString *anteName = nil;
    if([privateDialogue.fromuserid isEqualToString:privateDialogue.myViwerId]) {
        anteName = privateDialogue.tousername;
    } else {
        anteName = privateDialogue.fromusername;
    }
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = anteName;
    nameLabel.backgroundColor = CCClearColor;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = [UIFont systemFontOfSize:FontSize_30];
    nameLabel.textColor = CCRGBColor(51,51,51);
    nameLabel.userInteractionEnabled = NO;

    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:privateDialogue.msg y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(102,102,102) range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_26],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];

    UILabel *msgLabel = [UILabel new];
    msgLabel.attributedText = textAttri;
    msgLabel.numberOfLines = 1;
    msgLabel.backgroundColor = CCClearColor;
    msgLabel.userInteractionEnabled = NO;

    UILabel *timeLabel = [UILabel new];
    timeLabel.text = [privateDialogue.time substringToIndex:5];
    timeLabel.backgroundColor = CCClearColor;
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.font = [UIFont systemFontOfSize:FontSize_24];
    timeLabel.textColor = CCRGBColor(153,153,153);
    timeLabel.userInteractionEnabled = NO;

    UIView *footView = [UIView new];
    footView.backgroundColor = CCRGBColor(238,238,238);
    footView.userInteractionEnabled = NO;

    headImage.tag = 1;
    [cell addSubview:headImage];
    nameLabel.tag = 2;
    [cell addSubview:nameLabel];
    msgLabel.tag = 3;
    [cell addSubview:msgLabel];
    timeLabel.tag = 4;
    [cell addSubview:timeLabel];
    footView.tag = 5;
    [cell addSubview:footView];
    
    [headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell).offset(CCGetRealFromPt(30));
        make.centerY.mas_equalTo(cell);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
    }];
    
    UIImageView *idot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatHead_newMessage"]];
    idot.contentMode = UIViewContentModeScaleAspectFit;
    [cell addSubview:idot];
    [idot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.mas_equalTo(headImage);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(20), CCGetRealFromPt(20)));
    }];
    idot.tag = 6;
    idot.hidden = !privateDialogue.isNew;
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headImage.mas_right).offset(CCGetRealFromPt(30));
        make.top.mas_equalTo(cell);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(300), CCGetRealFromPt(90)));
    }];
    
    [msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameLabel);
        make.right.mas_equalTo(cell).offset(-CCGetRealFromPt(50));
        make.bottom.mas_equalTo(cell);
        make.height.mas_equalTo(CCGetRealFromPt(86));
    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell.mas_right).offset(-CCGetRealFromPt(125));
        make.right.mas_equalTo(cell);
        make.top.mas_equalTo(cell);
        make.height.mas_equalTo(CCGetRealFromPt(90));
    }];
    
    [footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(cell);
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(cell).offset(CCGetRealFromPt(30));
        make.right.mas_equalTo(cell).offset(-CCGetRealFromPt(30));
    }];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

-(void)showTableView {
    self.tableView.hidden = NO;
}

-(void)createPrivateChatViewForOne:(NSMutableArray *)dataArrayForOne anteid:(NSString *)anteid anteName:(NSString *)anteName {
    WS(ws)
    _privateChatViewForOne = [[PrivateChatViewForOne alloc] initWithCloseBlock:^{
        if(ws.closeBlock) {
            ws.closeBlock();
        }
        ws.tableView.hidden = NO;
        [self checkDot];
    } ChatClicked:^{
        [ws.privateChatViewForOne removeFromSuperview];
        ws.privateChatViewForOne = nil;
        ws.tableView.hidden = NO;
        [self checkDot];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_privateChatViewForOne) {
        [_privateChatViewForOne removeFromSuperview];
        _privateChatViewForOne = nil;
    }
//    NSLog(@"TableViewCell 被点击！");
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
//    NSLog(@"-------globalDialogue = %@,anteid = %@,anteName = %@",globalDialogue,anteid,anteName);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    UIImageView *headImage = (UIImageView *)[cell viewWithTag:1];
    UIImageView *idot = (UIImageView *)[cell viewWithTag:6];
    idot.hidden = YES;
//    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
//    UILabel *msgLabel = (UILabel *)[cell viewWithTag:3];
//    UILabel *timeLabel = (UILabel *)[cell viewWithTag:4];
//    nameLabel.text = anteName;
//    msgLabel.text = globalDialogue.msg;
//    timeLabel.text = globalDialogue.time;

    NSMutableArray *array = [self.dataPrivateDic objectForKey:anteid];
    
//    for(Dialogue *globalDialogue in array) {
//        NSLog(@"globalDialogue.msg = %@",globalDialogue.msg);
//    }
    //NSLog(@"------createPrivateChatViewForOne   anteid = %@,anteName = %@",anteid,anteName);
    [self createPrivateChatViewForOne:[array copy] anteid:anteid anteName:anteName];
    
//    CCLog(@"111 anteid = %@",globalDialogue.fromuserid);
    
    [self checkDot];
}

-(void)selectByClickHead:(Dialogue *)dialogue {
    if(_privateChatViewForOne) {
        [_privateChatViewForOne removeFromSuperview];
        _privateChatViewForOne = nil;
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
    [self.tableView reloadData];
    
    [self checkDot];
}

-(void)reloadDict:(NSDictionary *)dic anteName:anteName anteid:anteid {
    self.dataPrivateDic = [dic mutableCopy];
//    NSLog(@"---self.dataPrivateDic = %@",self.dataPrivateDic);
    NSArray *array = [self.dataPrivateDic objectForKey:anteid];
//    NSLog(@"---array = %@",array);
    Dialogue *dialogue = [array lastObject];
    BOOL flag = NO;
    for (Dialogue *dia in self.dataArray) {
        //NSLog(@"--- --- dia = %@,dialogue = %@",dia,dialogue);
        if(([dia.fromuserid isEqualToString:dialogue.fromuserid] && [dia.touserid isEqualToString:dialogue.touserid]) || ([dia.fromuserid isEqualToString:dialogue.touserid] && [dia.touserid isEqualToString:dialogue.fromuserid])) {
            [self.dataArray replaceObjectAtIndex:[self.dataArray indexOfObject:dia] withObject:dialogue];
            flag = YES;
            break;
        }
    }
    
//    _currentAnteid = anteid;
//    _currentAnteName = anteName;
    
    if(flag == NO) {
        [self.dataArray addObject:dialogue];
    }
    dialogue.isNew = YES;
    
//    NSLog(@"-----_currentAnteid = %@,anteid = %@,_currentAnteName = %@,anteName = %@",_currentAnteid,anteid,_currentAnteName,anteName);
    
    if(_privateChatViewForOne && [_currentAnteid isEqualToString:anteid] && [_currentAnteName isEqualToString:anteName]) {
        [self.privateChatViewForOne updateDataArray:[array copy]];
        dialogue.isNew = NO;
    }
    
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if(self.dataArray != nil && [self.dataArray count] != 0) {
                NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([self.dataArray count]-1) inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        });
    }
    [self checkDot];
}

-(void)checkDot {
    BOOL flag = NO;
    for (Dialogue *dia in self.dataArray) {
        if(dia.isNew == YES) {
            flag = YES;
            break;
        }
    }

    if(self.checkDotBlock) {
        self.checkDotBlock(flag);
    }
}

-(void)setCheckDotBlock1:(CheckDotBlock)block {
    self.checkDotBlock = block;
}

@end
