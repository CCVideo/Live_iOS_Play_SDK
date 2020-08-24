//
//  CCDownloadViewController.m
//  CCLiveCloud
//
//  Created by Apple on 2020/4/26.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "CCDownloadViewController.h"
#import "CCcommonDefine.h"
#import <CCSDK/OfflinePlayBack.h>
#import "CCDownloadUtility.h"
#import "CCDownloadSessionManager+file.h"
#import "MyTableViewCell.h"
#import "AddUrlViewController.h"
#import "OfflinePlayBackViewController.h"
#import "LoadingView.h"
#import "Reachability.h"
#import "CCProxy.h"
#import "TextFieldUserInfo.h"

@interface CCDownloadViewController ()<UITableViewDelegate,UITableViewDataSource,CCDownloadSessionDelegate>

@property(nonatomic,strong)UIBarButtonItem              * leftBarBtn;//返回按钮
@property(nonatomic,strong)UIBarButtonItem              * rightBarBtn;//添加下载地址
@property(nonatomic,strong)UITableView                  * tableView;//下载列表
@property(nonatomic,strong)CCDownloadModel              * downloadModel;//下载对象模型
@property(nonatomic,strong)OfflinePlayBack              * offlinePlayBack;//解压
@property(nonatomic,strong)LoadingView                  * loadingView;//加载视图

@property(nonatomic,strong)NSTimer                      * timer;//定时器
@property(nonatomic,assign)BOOL                           isNetwork;//网络状态


@end

@implementation CCDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserverObjC];//监听通知
    self.offlinePlayBack = [[OfflinePlayBack alloc] init];
    [CCDownloadSessionManager manager].delegate = self;//下载代理
    [self setupUI];//创建UI
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];
       self.navigationItem.leftBarButtonItem=self.leftBarBtn;
       self.navigationItem.rightBarButtonItem=self.rightBarBtn;
       [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"38404b" alpha:1.0f],NSForegroundColorAttributeName,[UIFont systemFontOfSize:FontSize_34],NSFontAttributeName,nil]];
       [self.navigationController.navigationBar setBackgroundImage:
        [self createImageWithColor:CCRGBColor(255,255,255)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
       [self.navigationController.navigationBar setShadowImage:[UIImage new]];
       [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    ///开启网络状态监听定时器
    [self startTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopTimer];
}

-(void)addUrlClicked {
    
    AddUrlViewController *addUrlViewController = [[AddUrlViewController alloc]initWithAddUrlBlock:^(NSString *url) {
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
        
#pragma mark- 创建下载链接
    
        if ([[CCDownloadSessionManager manager] checkLocalResourceWithUrl:url]) {//是否已经创建

            CCDownloadModel * model = [[CCDownloadSessionManager manager]downLoadingModelForURLString:url];
            if (model.state == CCDownloadStateRunning || model.state == CCDownloadStateCompleted) {
                return ;
            }
            [[CCDownloadSessionManager manager] resumeWithDownloadModel:model];
            
        } else {//创建下载链接
            NSArray *array = [url componentsSeparatedByString:@"/"];
            NSString * fileName = array.lastObject;
            fileName = [fileName substringToIndex:(fileName.length - 4)];
            self.downloadModel = [CCDownloadSessionManager createDownloadModelWithUrl:url FileName:fileName MimeType:@"ccr" AndOthersInfo:nil];
            [[CCDownloadSessionManager manager] startWithDownloadModel:self.downloadModel];
            
            [self.tableView reloadData];
        }
        
    }];
    [self.navigationController pushViewController:addUrlViewController animated:YES];
}
#pragma mark- CCDownloadSessionDelegate
// 更新下载进度
- (void)downloadModel:(CCDownloadModel *)downloadModel didUpdateProgress:(CCDownloadProgress *)progress {
    //进度
//    NSLog(@"进度是%f,%f,--------%lld %lld",progress.speed,progress.progress,progress.totalBytesWritten,progress.totalBytesExpectedToWrite);
    
    MyTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[[CCDownloadSessionManager manager].downloadModelList indexOfObject:downloadModel] inSection:0]];
    
    cell.informationLabel.text = [NSString stringWithFormat:@"下载中%.2f%@/s",[CCDownloadUtility calculateFileSizeInUnit:downloadModel.progress.speed],[CCDownloadUtility calculateUnit:downloadModel.progress.speed]];
    cell.progressLabel.text = [NSString stringWithFormat:@"%.2fMB\t / %.2fMB\t （%.2f%%）",downloadModel.progress.totalBytesWritten/MB,downloadModel.progress.totalBytesExpectedToWrite/MB,((float)downloadModel.progress.totalBytesWritten/(float)downloadModel.progress.totalBytesExpectedToWrite) * 100];
    [cell updateUIWithAlreadyDownLoadSize:downloadModel.progress.totalBytesWritten totalSize:downloadModel.progress.totalBytesExpectedToWrite];
    
}

// 更新下载状态
- (void)downloadModel:(CCDownloadModel *)downloadModel error:(NSError *)error{
    MyTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[[CCDownloadSessionManager manager].downloadModelList indexOfObject:downloadModel] inSection:0]];
    
    if (downloadModel.state == CCDownloadStateFailed) {//下载失败
        cell.informationLabel.text = @"文件处理失败\t请重新下载";
        cell.downloadImageView.image = [UIImage imageNamed:@"error"];
        cell.progressView.backgroundColor = CCRGBColor(255,0,23);
    } else if (downloadModel.state == CCDownloadStateCompleted) {//下载完成
        WS(weakSelf)
        cell.informationLabel.text = @"下载完成\t解压中";
        [cell updateUIToFull];
        cell.progressView.backgroundColor = CCRGBColor(35,161,236);
        NSString *str = [downloadModel.filePath substringToIndex:downloadModel.filePath.length - 4];
        
        dispatch_queue_t t = dispatch_queue_create("HDOfflive", NULL);
        
        dispatch_async(t, ^{
            downloadModel.decompressionState = 1;
            int zipDec = [weakSelf.offlinePlayBack DecompressZipWithDec:downloadModel.filePath dir:str];
            NSLog(@"解压码是%d,,,,路径是%@",zipDec,downloadModel.filePath);
            if (zipDec == 0) {
                [[CCDownloadSessionManager manager] decompressionFinish:downloadModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.informationLabel.text = @"解压完成\t可播放";
                    cell.downloadImageView.image = [UIImage imageNamed:@"play"];
                });

            } else {
                downloadModel.decompressionState = 3;
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.informationLabel.text = @"解压失败\t请重新下载";
                });
            }
            
        });
       
    }
//    [self.tableView reloadData];
}

#pragma mark - tableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CCGetPxFromPt(250);
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    CCDownloadSessionManager * manager = [CCDownloadSessionManager manager];
    CCDownloadModel * model = manager.downloadModelList[indexPath.row];
//    dispatch_async(dispatch_get_main_queue(), ^{
    if (model.state == CCDownloadStateRunning) {
     
        [manager suspendWithDownloadModel:model];
        cell.informationLabel.text = @"暂停下载";
        cell.downloadImageView.image = [UIImage imageNamed:@"pause"];
        cell.progressView.backgroundColor = CCRGBColor(35,161,236);
    } else if (model.state == CCDownloadStateSuspended) {
        //没有网络不允许点击
        if (_isNetwork == NO) return;
        [manager resumeWithDownloadModel:model];
        cell.downloadImageView.image = [UIImage imageNamed:@"downloading"];
        cell.progressView.backgroundColor = CCRGBColor(0,203,64);
        cell.informationLabel.text =  [NSString stringWithFormat:@"下载中%.2f%@/s",[CCDownloadUtility calculateFileSizeInUnit:model.progress.speed],[CCDownloadUtility calculateUnit:model.progress.speed]];
    } else if (model.state == CCDownloadStateFailed) {
    
        cell.informationLabel.text = @"文件处理失败\t请重新下载";
        cell.downloadImageView.image = [UIImage imageNamed:@"error"];
        cell.progressView.backgroundColor = CCRGBColor(255,0,23);
        [[CCDownloadSessionManager manager] resumeWithDownloadModel:model];
    } else if (model.state == CCDownloadStateCompleted) {
//        cell.informationLabel.text = @"解压完成\t可播放";
        [cell updateUIToFull];
        cell.downloadImageView.image = [UIImage imageNamed:@"play"];
        if (model.decompressionState != 2) {
            
            if (model.decompressionState == 1) {
                //NSLog(@"没有解压完成,请先解压");
            }else if (model.decompressionState == 0){
                NSString *str = [model.filePath substringToIndex:model.filePath.length - 4];
                
                dispatch_queue_t t = dispatch_queue_create("HDOfflive", NULL);
                
                dispatch_async(t, ^{
                    model.decompressionState = 1;
                    int zipDec = [self.offlinePlayBack DecompressZipWithDec:model.filePath dir:str];
                    //NSLog(@"解压码是%d,,,,路径是%@",zipDec,model.filePath);
                    if (zipDec == 0) {
                        [[CCDownloadSessionManager manager] decompressionFinish:model];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.informationLabel.text = @"解压完成\t可播放";
                        });
                        
                    } else {
                        model.decompressionState = 3;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.informationLabel.text = @"解压失败\t请重新下载";
                        });
                    }
                    
                });
            }else{

            }
            return;
        }
        cell.progressView.backgroundColor = CCRGBColor(35,161,236);
        [self showLoadingView];
        OfflinePlayBackViewController *offlinePlayBackVC = [[OfflinePlayBackViewController alloc] initWithDestination:model.filePath];
        
        offlinePlayBackVC.fileName = model.fileName;
        [UIApplication sharedApplication].idleTimerDisabled=YES;
        offlinePlayBackVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:offlinePlayBackVC animated:YES completion:^{
            [_loadingView removeFromSuperview];
            _loadingView = nil;
        }];
        
    } else {
        cell.informationLabel.text = @"文件处理失败\t请重新下载";
        cell.downloadImageView.image = [UIImage imageNamed:@"error"];
        cell.progressView.backgroundColor = CCRGBColor(255,0,23);
        
    }
//});
//    [self.tableView reloadData];
}
/**
 添加正在登录提示视图
 */
-(void)showLoadingView{
    _loadingView = [[LoadingView alloc] initWithLabel:@"" centerY:NO];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}

//删除动作
#pragma mark- 删除下载
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

        [[CCDownloadSessionManager manager] deleteWithDownloadModel:[CCDownloadSessionManager manager].downloadModelList[indexPath.row]];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];

}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [CCDownloadSessionManager manager].downloadModelList.count;
}

#pragma mark- cell里面的下载相关
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CCDownloadModel * model = [CCDownloadSessionManager manager].downloadModelList[indexPath.row];
    NSString *identifier = model.fileName;
    
//    NSLog(@"%lld=------%f",model.progress.totalBytesWritten, model.progress.progress);
    
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        if(indexPath.row % 2) {
            [cell setBackgroundColor:[UIColor clearColor]];
        } else {
            [cell setBackgroundColor:CCRGBColor(242,242,242)];
        }
    }
    cell.fileNameLabel.text = model.fileName;

    if(indexPath.row % 2) {
        [cell setBackgroundColor:[UIColor clearColor]];
    } else {
        [cell setBackgroundColor:CCRGBColor(242,242,242)];
    }

    [cell updateUIWithAlreadyDownLoadSize:model.progress.totalBytesWritten totalSize:model.progress.totalBytesExpectedToWrite];
    if (model.state == 0) {//CCDownloadStateNone,未下载 或 下载删除了
//        [[CCDownloadSessionManager manager] resumeWithDownloadModel:model];
    } else if (model.state == 1) {//CCDownloadStateReadying,等待下载
        
    } else if (model.state == 2) {//CCDownloadStateRunning,正在下载
//        [[CCDownloadSessionManager manager] resumeWithDownloadModel:model];
        if (_isNetwork == NO) {
            CCDownloadSessionManager * manager = [CCDownloadSessionManager manager];
            [manager suspendWithDownloadModel:model];
            cell.informationLabel.text = @"网络异常\t下载失败\t请重试";
            cell.downloadImageView.image = [UIImage imageNamed:@"error"];
            cell.progressView.backgroundColor = CCRGBColor(255,0,23);
        }else {
            cell.informationLabel.text = [NSString stringWithFormat:@"下载中%.2f%@/s",[CCDownloadUtility calculateFileSizeInUnit:model.progress.speed],[CCDownloadUtility calculateUnit:model.progress.speed]];
            cell.downloadImageView.image = [UIImage imageNamed:@"downloading"];
            cell.progressView.backgroundColor = CCRGBColor(0,203,64);
        }
    } else if (model.state == 3) {//CCDownloadStateSuspended,下载暂停
        if (_isNetwork == NO) {
            CCDownloadSessionManager * manager = [CCDownloadSessionManager manager];
            [manager suspendWithDownloadModel:model];
            cell.informationLabel.text = @"网络异常\t下载失败\t请重试";
            cell.downloadImageView.image = [UIImage imageNamed:@"error"];
            cell.progressView.backgroundColor = CCRGBColor(255,0,23);
        }else {

            cell.informationLabel.text = @"暂停下载";
            cell.downloadImageView.image = [UIImage imageNamed:@"pause"];
            cell.progressView.backgroundColor = CCRGBColor(35,161,236);
            [cell updateUIWithAlreadyDownLoadSize:model.progress.totalBytesWritten totalSize:model.progress.totalBytesExpectedToWrite];
        }
    } else if (model.state == 4) {//CCDownloadStateCompleted,下载完成
        if (model.decompressionState == 2) {
            cell.informationLabel.text = @"解压完成\t可播放";

        } else {
            if (model.decompressionState == 1) {
                cell.informationLabel.text = @"下载完成,解压中";
            }else if (model.decompressionState == 0) {
                cell.informationLabel.text = @"点击解压";
            }else{
                cell.informationLabel.text = @"解压失败";
            }

        }
        cell.downloadImageView.image = [UIImage imageNamed:@"play"];
        [cell updateUIToFull];
        cell.progressLabel.text = [NSString stringWithFormat:@"%.2fMB\t / %.2fMB\t （100.00%%）",model.progress.totalBytesWritten/MB,model.progress.totalBytesExpectedToWrite/MB];
        cell.progressView.backgroundColor = CCRGBColor(35,161,236);

    } else if (model.state == 5) {//CCDownloadStateFailed,下载失败
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.informationLabel.text = @"文件处理失败\t请重新下载";
            cell.downloadImageView.image = [UIImage imageNamed:@"error"];
            cell.progressView.backgroundColor = CCRGBColor(255,0,23);
            cell.progressLabel.text = [NSString stringWithFormat:@"%.2fMB\t / %.2fMB",model.progress.totalBytesWritten/MB,model.progress.totalBytesExpectedToWrite/MB];
        });
    }

    return cell;
}


#pragma mark Notification
-(void)addObserverObjC {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)removeObserverObjC {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                        name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                        name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                        name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

- (void)appWillEnterBackgroundNotification {
}
- (void)applicationDidBecomeActiveNotification {
    //每次回到前台，把所有正在下载中的任务，手动开始一遍
    CCDownloadSessionManager * manager = [CCDownloadSessionManager manager];
    for (CCDownloadModel * model in manager.downloadModelList) {
        if (model.state == CCDownloadStateRunning) {
            [manager suspendWithDownloadModel:model];

            //因为暂停方法是异步的，如果立马调用恢复下载的方法，是有问题的，这里延迟一会执行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [manager resumeWithDownloadModel:model];
//                [self.tableView reloadData];
            });
        }
    }

}
- (void)appWillEnterForegroundNotification {

   
}

#pragma mark - 创建UI
-(void)setupUI
{
    self.title = @"回放离线播放";
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(self.view);
    }];
    
}

//开始播放
-(void)startTimer {
    [self stopTimer];
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:weakObject selector:@selector(timerfunc) userInfo:nil repeats:YES];//打卡倒计时
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timer forMode:NSRunLoopCommonModes];
}
//停止播放
-(void) stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

///定时器回调
- (void)timerfunc
{
    BOOL isNetwork = [self isExistenceNetwork];
    _isNetwork = isNetwork;
    if (isNetwork == NO) { //无网络暂停定时器并提示网络已断开
        //NSLog(@"网络已断开");
    }else {
        //NSLog(@"网络正常");
    }
    [self.tableView reloadData];
}

#pragma mark - 懒加载
//左侧返回Btn
-(UIBarButtonItem *)leftBarBtn {
    if(_leftBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}
//右侧扫描按钮
-(UIBarButtonItem *)rightBarBtn {
    if(_rightBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"local_play_add"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _rightBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(addButtonClick)];
    }
    return _rightBarBtn;
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

#pragma mark - 事件处理
/**
 点击返回按钮
 */
-(void)onSelectVC {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 * 添加按钮
 */
-(void)addButtonClick
{
    AddUrlViewController *addUrlViewController = [[AddUrlViewController alloc]initWithAddUrlBlock:^(NSString *url) {
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
        
    #pragma mark- 创建下载链接

        if ([[CCDownloadSessionManager manager] checkLocalResourceWithUrl:url]) {//是否已经创建

            CCDownloadModel * model = [[CCDownloadSessionManager manager]downLoadingModelForURLString:url];
            if (model.state == CCDownloadStateRunning || model.state == CCDownloadStateCompleted) {
                return ;
            }
            [[CCDownloadSessionManager manager] resumeWithDownloadModel:model];
            
        } else {//创建下载链接
            NSArray *array = [url componentsSeparatedByString:@"/"];
            NSString * fileName = array.lastObject;
            fileName = [fileName substringToIndex:(fileName.length - 4)];
            self.downloadModel = [CCDownloadSessionManager createDownloadModelWithUrl:url FileName:fileName MimeType:@"ccr" AndOthersInfo:nil];
            [[CCDownloadSessionManager manager] startWithDownloadModel:self.downloadModel];
            
            [self.tableView reloadData];
        }
        
    }];
    [self.navigationController pushViewController:addUrlViewController animated:YES];
}

/**
 color转image

 @param color color
 @return image
 */
- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)dealloc {
    [self stopTimer];
    [self removeObserverObjC];
}

/**
 *    @brief    判断当前是否有网络
 *    @return   是否有网
 */
-(BOOL)isExistenceNetwork{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:{
            isExistenceNetwork = NO;
            break;
        }
        case ReachableViaWiFi:{
            isExistenceNetwork = YES;
            break;
        }
        case ReachableViaWWAN:{
            isExistenceNetwork = YES;
            break;
        }
    }
    return isExistenceNetwork;
}

@end
