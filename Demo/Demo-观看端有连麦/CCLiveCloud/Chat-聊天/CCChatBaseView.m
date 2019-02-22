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
@interface CCChatBaseView ()<CCChatContentViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) BOOL                input;//是否有输入文本框
@property (nonatomic, strong) UITableView         * publicTableView;//公聊tableView
@property (nonatomic, strong) CCChatContentView   * inputView;//输入框视图
@property (nonatomic, strong) NSMutableDictionary * privateChatDict;//私聊字典
@property (nonatomic, assign) BOOL                privateHidden;//是否隐藏私聊视图
@property (nonatomic, copy)   PublicChatBlock     publicChatBlock;//公聊回调
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
    }
    return _publicTableView;
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
                self.ccPrivateChatView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH, IS_IPHONE_X ? CCGetRealFromPt(835) + 90 - y + kScreenBottom:CCGetRealFromPt(835)-y);;
            } completion:^(BOOL finished) {
            }];
        } isNotResponseBlock:^{
            [UIView animateWithDuration:0.25f animations:^{
                self.ccPrivateChatView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH, IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835));;
            } completion:^(BOOL finished) {
            }];
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
    //防止图片和键盘弹起冲突
    if (endEditIng == YES) {
        [self endEditing:YES];
        return;
    }
    [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.and.left.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-height);
        make.height.mas_equalTo(CCGetRealFromPt(110));
    }];
    
    [_publicTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.and.left.mas_equalTo(self);
        make.bottom.mas_equalTo(self.inputView.mas_top);
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.publicChatArray != nil && [self.publicChatArray count] != 0 ) {
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.publicChatArray.count - 1) inSection:0];
            [self.publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}
//隐藏键盘
-(void)hiddenKeyBoard{
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
    static NSString *CellId = @"DefaultBaseCellIdentifier";
    if ([self.publicChatArray count] - 1 < (long)indexPath.row) {
        return nil;//防止数组越界
    }
    CCPublicChatModel *model = [self.publicChatArray objectAtIndex:indexPath.row];
    CCChatBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[CCChatBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        }else{
            for(UIView *cellView in cell.subviews){
                [cellView removeFromSuperview];
            }
        }
        //判断消息方是否是自己
        BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];
        //聊天审核-------------如果消息状态码为1,不显示此消息,状态栏可能没有
        if (model.status && [model.status isEqualToString:@"1"] && !fromSelf){
            cell.hidden = YES;
            return cell;
        }
//    dispatch_async(dispatch_get_main_queue(), ^{
    
        //加载cell
        WS(ws)
        if (model.typeState == RadioState) {//广播消息
            //加载广播消息
            [cell setRadioModel:model];
        }else if (model.typeState == TextState){//纯文本消息
            //加载纯文本cell
            [cell setTextModel:model isInput:self.input indexPath:indexPath];
            cell.headBtnClick = ^(UIButton * _Nonnull btn) {
                [ws headBtnClicked:btn];
            };
        }else if(model.typeState == ImageState){//图片cell
            //加载图片cell
            [cell setImageModel:model isInput:self.input indexPath:indexPath];
        }
//    });
    return cell;
}
//cell行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CCPublicChatModel *model = [self.publicChatArray objectAtIndex:indexPath.row];
    //判断消息方是否是自己
    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];
    //聊天审核 如果消息状态码为1,不显示此消息,状态可能没有
    if (model.status && [model.status isEqualToString:@"1"] && !fromSelf) {
        return 0;
    }
    return model.cellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.publicChatArray count];
}
#pragma mark - 公有调用方法
//reload
-(void)reloadPublicChatArray:(NSMutableArray *)array{
    //    NSLog(@"array = %@",array);
    self.publicChatArray = [array mutableCopy];
    //    NSLog(@"self.publicChatArray = %@",self.publicChatArray);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.publicTableView reloadData];
        
        if (self.publicChatArray != nil && [self.publicChatArray count] != 0 ) {
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.publicChatArray.count - 1) inSection:0];
            [self.publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}
//添加新消息
-(void)addPublicChatArray:(NSMutableArray *)array{
    if([array count] == 0) return;
    
    NSInteger preIndex = [self.publicChatArray count];
    [self.publicChatArray addObjectsFromArray:[array mutableCopy]];
    NSInteger bacIndex = [self.publicChatArray count];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for(NSInteger row = preIndex + 1;row <= bacIndex;row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(row-1) inSection:0];
        [indexPaths addObject: indexPath];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.publicTableView reloadData];
        [self.publicTableView beginUpdates];
        [self.publicTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.publicTableView endUpdates];
        if (indexPaths != nil && [indexPaths count] != 0 ) {
            [self.publicTableView scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}
//添加一条新消息
-(void)addPublicChat:(NSMutableArray *)array{
    [self.publicChatArray addObject:[array lastObject]];
//    NSLog(@"publicCount = %ld", self.publicChatArray.count);
    //添加消息过快,异步刷新混乱。
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.publicChatArray.count - 1) inSection:0];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);//创建信号量
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
//            NSLog(@"indexPath = %ld", (long)indexPath.row);
            [self.publicTableView reloadData];
            //如果数据刷新过快,用insertRowsAtIndexPath这个方法会导致刷新崩溃。
//            [self.publicTableView beginUpdates];
//            [self.publicTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            [self.publicTableView endUpdates];
            if (indexPath != nil) {
                [self.publicTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);  //等待
    });
}
//聊天审核
-(void)reloadStatusWithIndexPaths:(NSMutableArray *)arr publicArr:(NSMutableArray *)publicArr{
    [self.publicChatArray removeAllObjects];
    self.publicChatArray = [publicArr mutableCopy];
    NSArray *reloadArr = (NSArray *)[arr mutableCopy];
    [self.publicTableView reloadRowsAtIndexPaths:reloadArr withRowAnimation:UITableViewRowAnimationNone];
    dispatch_async(dispatch_get_main_queue(), ^{
        //判断当前行数是否是最后一行，如果是,刷新至最后一行
        NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:(self.publicChatArray.count - 1) inSection:0];
        [self.publicTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];;
    });
}
//刷新图片
-(void)reloadStatusWithIndexPath:(NSIndexPath *)indexPath publicArr:(NSMutableArray *)publicArr{
//    [self.publicChatArray removeAllObjects];
//    self.publicChatArray = [publicArr mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.publicTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    NSString *str = _inputView.chatTextField.text;
    if(str == nil || str.length == 0) {
        return;
    }
    
    if(self.publicChatBlock) {
        self.publicChatBlock(str);
    }
    
    _inputView.chatTextField.text = nil;
    [_inputView.chatTextField resignFirstResponder];
}
#pragma mark - 点击头像
//点击头像事件
-(void)headBtnClicked:(UIButton *)sender {
    //移除新消息提醒
    [[NSNotificationCenter defaultCenter] postNotificationName:@"remove_newPrivateMsg" object:self];
    
    self.privateHidden = NO;
    self.ccPrivateChatView.hidden = NO;
    self.ccPrivateChatView.frame = CGRectMake(0, CCGetRealFromPt(462)+SCREEN_STATUS, SCREEN_WIDTH,IS_IPHONE_X ? CCGetRealFromPt(835) + 90:CCGetRealFromPt(835));
    
    [self.ccPrivateChatView selectByClickHead:[self.publicChatArray objectAtIndex:sender.tag]];
    [APPDelegate.window bringSubviewToFront:self.ccPrivateChatView];
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
}
-(void)dealloc{
    [self removeObserver];
//    NSLog(@"移除聊天视图");
}
@end
