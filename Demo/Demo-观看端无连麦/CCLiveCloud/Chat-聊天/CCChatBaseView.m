//
//  CCChatBaseView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/1/21.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCChatBaseView.h"
#import "CCChatContentView.h"//输入框
#import "CCPublicChatModel.h"//公聊数据模型
#import "CCChatBaseCell.h"//公聊cell
#import "CCChatViewDataSourceManager.h"//聊天
#import "MJRefresh.h"//下拉刷新
@interface CCChatBaseView ()<CCChatContentViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) BOOL                input;//是否有输入文本框
@property (nonatomic, strong) UITableView         * publicTableView;//公聊tableView
@property (nonatomic, strong) CCChatContentView   * inputView;//输入框视图
@property (nonatomic, strong) NSMutableDictionary * privateChatDict;//私聊字典
@property (nonatomic, assign) BOOL                privateHidden;//是否隐藏私聊视图
@property (nonatomic, copy)   PublicChatBlock     publicChatBlock;//公聊回调
@property (nonatomic, strong) UILabel             * freshLabel;//刷新提示文字
@property (nonatomic, assign) BOOL                 keyboardShow;
@end

@implementation CCChatBaseView

-(instancetype)initWithPublicChatBlock:(PublicChatBlock)block isInput:(BOOL)input{
    self = [super init];
    if (self) {
        self.publicChatBlock = block;
        self.input = input;
        [self initUI];
        if(self.input) {
            [self addObserver];
        }
    }
    return self;
}
#pragma mark - 设置UI布局
-(void)initUI{
    WS(weakSelf)
    if(self.input) {
        //输入框
        self.inputView = [[CCChatContentView alloc] init];
        [self addSubview:self.inputView];
        self.inputView.delegate = self;
        NSInteger tabheight = IS_IPHONE_X?178:110;
        [_inputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.right.and.left.mas_equalTo(self);
            make.height.mas_equalTo(CCGetRealFromPt(tabheight));
        }];
        //聊天回调
        self.inputView.sendMessageBlock = ^{
            [weakSelf chatSendMessage];
        };
        
        //公聊视图
        [self addSubview:self.publicTableView];
        [_publicTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.left.mas_equalTo(self);
            make.bottom.mas_equalTo(self.inputView.mas_top);
        }];
        //私聊视图
        //添加私聊视图
        [APPDelegate.window addSubview:self.ccPrivateChatView];
        // 835 私聊视图高度
        self.ccPrivateChatView.frame = CGRectMake(0, SCREENH_HEIGHT, SCREEN_WIDTH, CCGetRealFromPt(835));
        self.privateHidden = YES;
//        [self.ccPrivateChatView hiddenPrivateViewForOne:YES];
    } else {
        [self addSubview:self.publicTableView];
        [_publicTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
}
#pragma mark - 懒加载
-(UITableView *)publicTableView {
    if(!_publicTableView) {
        _publicTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _publicTableView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];
        _publicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _publicTableView.delegate = self;
        _publicTableView.dataSource = self;
        _publicTableView.showsVerticalScrollIndicator = NO;
        _publicTableView.estimatedRowHeight = 0;
        _publicTableView.estimatedSectionHeaderHeight = 0;
        _publicTableView.estimatedSectionFooterHeight = 0;
//        [_publicTableView registerClass:[ChatViewCell class] forCellReuseIdentifier:@"CellChatView"];
        if (@available(iOS 11.0, *)) {
            _publicTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _publicTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        [_publicTableView.mj_header beginRefreshing];
    }
    return _publicTableView;
}

/**
 下拉刷新新数据
 */
-(void)loadNewData{
    if (self.input == NO) {
        [self.publicTableView.mj_header endRefreshing];
        return;
    }
    
    
    
    if ([CCChatViewDataSourceManager sharedManager].publicChatArray.count > self.publicChatArray.count) {
        NSMutableArray *arr = [CCChatViewDataSourceManager sharedManager].publicChatArray;
        NSInteger selfCount = self.publicChatArray.count;
        NSInteger insertCount = arr.count - selfCount;
        if (insertCount == 0) return;
        insertCount = insertCount > 10 ? 10 : insertCount;//判断未展示的消息数据是否大于10条
        //加载10条数据
        for (NSInteger i = arr.count - selfCount; i > arr.count - selfCount - insertCount; i--) {
            [self.publicChatArray insertObject:arr[i-1] atIndex:0];
        }
        //        NSLog(@"刷新了%d条数据,总条数%d, 目前条数%d", insertCount, arr.count, self.publicChatArray.count);
        if (self.keyboardShow == YES) {
            return;
        }
        [self.publicTableView reloadData];
        [self.publicTableView.mj_header endRefreshing];
    }else{
//        NSLog(@"没有更多数据了");
        [self.publicTableView.mj_header endRefreshing];
    }
}
//公聊数组
-(NSMutableArray *)publicChatArray {
    if(!_publicChatArray) {
        _publicChatArray = [[NSMutableArray alloc] init];
    }
    return _publicChatArray;
}
//初始化私聊界面
-(CCPrivateChatView *)ccPrivateChatView {
    if(!_ccPrivateChatView) {
//        NSLog(@"创建私聊");
        WS(ws)
        _ccPrivateChatView = [[CCPrivateChatView alloc] initWithCloseBlock:^{
            [UIView animateWithDuration:0.25f animations:^{
                ws.ccPrivateChatView.frame = CGRectMake(0, SCREENH_HEIGHT, SCREEN_WIDTH, CCGetRealFromPt(835));
            } completion:^(BOOL finished) {
                if(ws.ccPrivateChatView.privateChatViewForOne) {
                    [ws.ccPrivateChatView.privateChatViewForOne removeFromSuperview];
                    ws.ccPrivateChatView.privateChatViewForOne = nil;
                }
            }];
        } isResponseBlock:^(CGFloat y) {
            [UIView animateWithDuration:0.25f animations:^{
                ws.ccPrivateChatView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH, IS_IPHONE_X ? CCGetRealFromPt(835) + 90 - y + kScreenBottom:CCGetRealFromPt(835)-y);;
            } completion:^(BOOL finished) {
            }];
        } isNotResponseBlock:^{
            //todo 防止隐藏的私聊视图接到键盘通知导致消息弹起，回调前判断当前是否有私聊视图
            if (ws.ccPrivateChatView.privateChatViewForOne && ws.ccPrivateChatView.frame.origin.y < SCREENH_HEIGHT) {
                [UIView animateWithDuration:0.25f animations:^{
                    ws.ccPrivateChatView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH, IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835));;
                } completion:^(BOOL finished) {
                }];
            }
        }  dataPrivateDic:[self.privateChatDict copy] isScreenLandScape:NO];
    }
    return _ccPrivateChatView;
}
//私聊字典
-(NSMutableDictionary *)privateChatDict {
    if(!_privateChatDict) {
        _privateChatDict = [[NSMutableDictionary alloc] init];
    }
    return _privateChatDict;
}
#pragma mark - 添加通知
-(void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(privateChat:)
                                                 name:@"private_Chat"
                                               object:nil];
}
#pragma mark - 实现通知
- (void) privateChat:(NSNotification*) notification
{
    //私聊发送消息回调
    NSDictionary *dic = [notification object];
    if(self.privateChatBlock) {
        self.privateChatBlock(dic[@"anteid"],dic[@"str"]);
    }
}
#pragma mark - 移除通知
-(void)removeObserver {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"private_Chat"
                                                  object:nil];
}

#pragma mark - inputView deleaget输入键盘的代理
//键盘将要出现
-(void)keyBoardWillShow:(CGFloat)height endEditIng:(BOOL)endEditIng{
    self.keyboardShow = YES;

    //防止图片和键盘弹起冲突
    if (endEditIng == YES) {
        [self endEditing:YES];
        return;
    }

    NSInteger selfHeight = self.frame.size.height - height;
//    if (selfHeight>0) {
        NSInteger contentHeight = selfHeight>CCGetRealFromPt(110)?(-height):(CCGetRealFromPt(110)-self.frame.size.height);
        [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.left.equalTo(self);
            make.bottom.equalTo(self.mas_bottom).offset(contentHeight);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        [_publicTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.right.left.equalTo(self);
            make.bottom.equalTo(self.inputView.mas_top);
        }];
//    }

    [UIView animateWithDuration:0.25f animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
//                [self.publicTableView setContentOffset:CGPointMake(0, self.publicTableView.contentSize.height -self.publicTableView.bounds.size.height) animated:YES];
//        if (self.publicChatArray != nil && [self.publicChatArray count] != 0 ) {
//            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.publicChatArray.count - 1) inSection:0];
//            if ([self.publicTableView cellForRowAtIndexPath:indexPathLast] == nil) {
//                return;//防止刷新过快，数组越界
//            }
//            [self.publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        }

    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.keyboardShow = NO;
    });
}
//隐藏键盘
-(void)hiddenKeyBoard{
    self.keyboardShow = NO;
    NSInteger tabheight = IS_IPHONE_X ?178:110;
    [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.and.left.and.bottom.mas_equalTo(self);
        make.height.mas_equalTo(CCGetRealFromPt(tabheight));
    }];
    
    [_publicTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.and.left.mas_equalTo(self);
        make.bottom.mas_equalTo(self.inputView.mas_top);
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}
#pragma mark - TableView Delegate And TableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellId = [NSString stringWithFormat:@"cellID%ld",(long)indexPath.row];
    //TODO return;
    if ([self.publicChatArray count] - 1 < (long)indexPath.row || !self.publicChatArray.count) {
        return [[UITableViewCell alloc] init];//防止数组越界
    }
    CCPublicChatModel *model = [self.publicChatArray objectAtIndex:indexPath.row];
    CCChatBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[CCChatBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
    }
    //判断消息方是否是自己
    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];
    //聊天审核-------------如果消息状态码为1,不显示此消息,状态栏可能没有
    if (model.status && [model.status isEqualToString:@"1"] && !fromSelf){
        cell.hidden = YES;
        return cell;
    }
    
    //加载cell
    WS(ws)
    if (model.typeState == RadioState) {//广播消息
        //加载广播消息
        [cell setRadioModel:model];
    }else if (model.typeState == TextState){//纯文本消息
        cell.smallImageView.image = nil;
        //加载纯文本cell
        [cell setTextModel:model isInput:self.input indexPath:indexPath];
//        NSLog(@"数据是%@",model.msg);
    }else if(model.typeState == ImageState){//图片cell
//        cell.smallImageView.hidden = NO;

        //加载图片cell
        [cell setImageModel:model isInput:self.input indexPath:indexPath];
//        NSLog(@"数据是%@",model.msg);

    }
    cell.headBtnClick = ^(UIButton * _Nonnull btn) {
        [ws headBtnClicked:btn];
    };
    return cell;
}
//cell行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.publicChatArray count] - 1 < (long)indexPath.row || !self.publicChatArray.count) {
        return 0;//防止数组越界
    }
    CCPublicChatModel *model = [self.publicChatArray objectAtIndex:indexPath.row];
    if (model.typeState == RadioState) {//广播消息
        return model.cellHeight;
    }
    //判断消息方是否是自己
    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];
    //聊天审核 如果消息状态码为1,不显示此消息,状态可能没有
    if (model.status && [model.status isEqualToString:@"1"] && !fromSelf) {
        return 0;
    }
    return model.cellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    NSLog(@"聊天数%zd",self.publicChatArray.count);
    return [self.publicChatArray count];
}
#pragma mark - 公有调用方法
//reload
-(void)reloadPublicChatArray:(NSMutableArray *)array{
    //    NSLog(@"array = %@",array);
    self.publicChatArray = [array mutableCopy];
    //    NSLog(@"self.publicChatArray = %@",self.publicChatArray);
    if (self.keyboardShow == YES) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.publicTableView reloadData];
        
        if (self.publicChatArray != nil && [self.publicChatArray count] != 0 ) {
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.publicChatArray.count - 1) inSection:0];
            [self.publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

/**
 添加一个聊天数组(直播公聊如果每秒钟发送消息过多，会调用这个方法)

 @param array 聊天数组
 */
-(void)addPublicChatArray:(NSMutableArray *)array{
    if([array count] == 0) return;
    //让每秒钟发送消息超过10条时，取最新的十条
//    if (array.count > 10 && self.input == YES ) {
////        NSInteger count = array.count;
//        NSRange range = NSMakeRange(0, array.count - 10);
//        [array removeObjectsInRange:range];
////        NSLog(@"每秒钟数据%d个,加载最新10条, 目前消息数%lu", count, self.publicChatArray.count);
//    }
    
    NSInteger preIndex = [self.publicChatArray count];
    [self.publicChatArray addObjectsFromArray:[array mutableCopy]];
    NSInteger bacIndex = [self.publicChatArray count];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for(NSInteger row = preIndex + 1;row <= bacIndex;row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(row-1) inSection:0];
        [indexPaths addObject: indexPath];
    }
    if (self.keyboardShow == YES) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.publicTableView reloadData];
        [self.publicTableView setContentOffset:CGPointMake(0, self.publicTableView.contentSize.height -self.publicTableView.bounds.size.height) animated:YES];
        //防止越界
//        NSIndexPath *lastIndexPath = [indexPaths lastObject];
//        if ((long)lastIndexPath.row > self.publicChatArray.count) {
//            return;
//        }
////        [self.publicTableView beginUpdates];
////        [self.publicTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
////        [self.publicTableView endUpdates];
//        if (indexPaths != nil && [indexPaths count] != 0 ) {
//            [self.publicTableView scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        }
    });
}

/**
 添加一条新消息    Ps:接收到一条观看直播公聊消息时，调用此方法

 @param object 一条聊天消息
 */
-(void)addPublicChat:(id)object{
    //当前cell数量大于60时，加载最新20条，下拉刷新从单例数组中取
//    if (self.publicChatArray.count > 60) {
//        NSRange range =NSMakeRange(0, self.publicChatArray.count - 20);
//        [self.publicChatArray removeObjectsInRange:range];
////        NSLog(@"count大于60,返回最新20条,目前消息条数%lu", self.publicChatArray.count);
//    }
    [self.publicChatArray addObject:object];
//    NSLog(@"publicCount = %ld", self.publicChatArray.count);
    if (self.keyboardShow == YES) {
        return;
    }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.publicChatArray.count - 1) inSection:0];
//            NSLog(@"indexPath = %ld", (long)indexPath.row);
            [self.publicTableView reloadData];
//            NSLog(@"%@", [self.publicTableView cellForRowAtIndexPath:indexPath]);
            if (indexPath != nil) {
                [self.publicTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        });
}
//聊天审核
-(void)reloadStatusWithIndexPaths:(NSMutableArray *)arr publicArr:(NSMutableArray *)publicArr{
    NSArray *reloadArr = (NSArray *)[arr mutableCopy];
    NSIndexPath *indexPath = reloadArr[0];
//    NSLog(@"idnexPath.row = %ld, public.count = %ld", indexPath.row, self.publicChatArray.count);
    NSInteger rowCount = [self.publicTableView numberOfRowsInSection:0];
    NSInteger reloadRow = indexPath.row + 1;
    if (reloadRow <= publicArr.count - rowCount) {
//        NSLog(@"不需要刷新cell");
        return;
//    }else if(reloadRow > rowCount){
//        NSInteger newIntger = reloadRow + rowCount - publicArr.count;
//        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:newIntger inSection:0];
//        reloadArr = [NSArray arrayWithObject:insertIndexPath];
//        NSLog(@"需要刷新cell，刷新第%ld行", newIntger);
    }
    [self.publicChatArray removeAllObjects];
    self.publicChatArray = [publicArr mutableCopy];
    if (self.keyboardShow == YES) {
        return;
    }
    [self.publicTableView reloadData];
//    [self.publicTableView reloadRowsAtIndexPaths:reloadArr withRowAnimation:UITableViewRowAnimationNone];
    dispatch_async(dispatch_get_main_queue(), ^{
        //判断当前行数是否是最后一行，如果是,刷新至最后一行
        NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.publicChatArray.count - 1) inSection:0];
        [self.publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];;
    });
}
//刷新图片
-(void)reloadStatusWithIndexPath:(NSIndexPath *)indexPath publicArr:(NSMutableArray *)publicArr{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.publicTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        //判断当前行数是否是最后一行，如果是,刷新至最后一行
        NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.publicChatArray.count - 1) inSection:0];
        if (indexPath.row == indexPathLast.row) {
            [self.publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];;
        }
    });
}
#pragma mark - 私有方法
//发送公聊信息
-(void)chatSendMessage{
    NSString *str = _inputView.plainText;
    if(str == nil || str.length == 0) {
        return;
    }
    
    if(self.publicChatBlock) {
        self.publicChatBlock(str);
    }
    
    _inputView.textView.text = nil;
    [_inputView.textView resignFirstResponder];
}
#pragma mark - 点击头像
//点击头像事件
-(void)headBtnClicked:(UIButton *)sender {
    //移除新消息提醒
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"remove_newPrivateMsg" object:self];
    
    self.privateHidden = NO;
    self.ccPrivateChatView.hidden = NO;
    self.ccPrivateChatView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH,IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835));
    
    [self.ccPrivateChatView selectByClickHead:[self.publicChatArray objectAtIndex:sender.tag]];
    [APPDelegate.window bringSubviewToFront:self.ccPrivateChatView];
//    [self.ccPrivateChatView hiddenPrivateViewForOne:NO];
}

- (void)reloadPrivateChatDict:(NSMutableDictionary *)dict anteName:anteName anteid:anteid {
    [self.ccPrivateChatView reloadDict:[dict mutableCopy] anteName:anteName anteid:anteid];
}

//点击私聊按钮
-(void)privateChatBtnClicked {
    self.privateHidden = NO;
    self.ccPrivateChatView.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^{
        self.ccPrivateChatView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH, IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835));
    } completion:^(BOOL finished) {
    }];
//    [self.ccPrivateChatView hiddenPrivateViewForOne:NO];
}
-(void)dealloc{
    [self removeObserver];
//    NSLog(@"%s", __func__);
}
@end
