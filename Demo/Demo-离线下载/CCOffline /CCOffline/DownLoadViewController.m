//
//  DownLoadViewController.m
//  CCOffline
//
//  Created by Clark on 2019/5/8.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "DownLoadViewController.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>
#import "AddUrlViewController.h"
#import "CCDownloadSessionManager+file.h"
#import "MyTableViewCell.h"
#import "CCSDK/OfflinePlayBack.h"
#import "CCDownloadUtility.h"
#import "OfflinePlayBackViewController.h"
@interface DownLoadViewController ()<UITableViewDelegate,UITableViewDataSource,CCDownloadSessionDelegate>
@property(nonatomic,strong)UITableView          *tableView;
@property(nonatomic,strong)CCDownloadModel * downloadModel;//下载对象模型
@property(nonatomic,strong)OfflinePlayBack          *offlinePlayBack;//解压


@end

@implementation DownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserverObjC];//监听通知
    self.offlinePlayBack = [[OfflinePlayBack alloc] init];
    [CCDownloadSessionManager manager].delegate = self;//下载代理
    [self setupUI];//创建UI
}


-(void)addUrlClicked {
    
    AddUrlViewController *addUrlViewController = [[AddUrlViewController alloc]initWithAddUrlBlock:^(NSString *url) {
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
        
#pragma mark- 创建下载链接
    
        if ([[CCDownloadSessionManager manager] checkLocalResourceWithUrl:url]) {//是否已经创建

            CCDownloadModel * model = [[CCDownloadSessionManager manager]downLoadingModelForURLString:url];
            if (model.state == DWDownloadStateRunning || model.state == DWDownloadStateCompleted) {
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
    if (downloadModel.state == DWDownloadStateFailed) {//下载失败
        cell.informationLabel.text = @"文件处理失败\t请重新下载";
        cell.downloadImageView.image = [UIImage imageNamed:@"error"];
        cell.progressView.backgroundColor = CCRGBColor(255,0,23);
    } else if (downloadModel.state == DWDownloadStateCompleted) {//下载完成
        WS(weakSelf)
        cell.informationLabel.text = @"下载完成\t解压中";
        [cell updateUIToFull];
        cell.downloadImageView.image = [UIImage imageNamed:@"play"];
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
    
   
    if (model.state == DWDownloadStateRunning) {
        [manager suspendWithDownloadModel:model];
        cell.informationLabel.text = @"暂停下载";
        cell.downloadImageView.image = [UIImage imageNamed:@"pause"];
        cell.progressView.backgroundColor = CCRGBColor(35,161,236);
    } else if (model.state == DWDownloadStateSuspended) {
        [manager resumeWithDownloadModel:model];
        cell.downloadImageView.image = [UIImage imageNamed:@"downloading"];
        cell.progressView.backgroundColor = CCRGBColor(0,203,64);
        cell.informationLabel.text =  [NSString stringWithFormat:@"下载中%.2f%@/s",[CCDownloadUtility calculateFileSizeInUnit:model.progress.speed],[CCDownloadUtility calculateUnit:model.progress.speed]];
    } else if (model.state == DWDownloadStateFailed) {
        cell.informationLabel.text = @"文件处理失败\t请重新下载";
        cell.downloadImageView.image = [UIImage imageNamed:@"error"];
        cell.progressView.backgroundColor = CCRGBColor(255,0,23);
        [[CCDownloadSessionManager manager] resumeWithDownloadModel:model];
    } else if (model.state == DWDownloadStateCompleted) {
//        cell.informationLabel.text = @"解压完成\t可播放";
        [cell updateUIToFull];
        cell.downloadImageView.image = [UIImage imageNamed:@"play"];
        if (model.decompressionState != 2) {
            
            if (model.decompressionState == 1) {
                NSLog(@"没有解压完成,请先解压");
            }else if (model.decompressionState == 0){
                NSString *str = [model.filePath substringToIndex:model.filePath.length - 4];
                
                dispatch_queue_t t = dispatch_queue_create("HDOfflive", NULL);
                
                dispatch_async(t, ^{
                    model.decompressionState = 1;
                    int zipDec = [self.offlinePlayBack DecompressZipWithDec:model.filePath dir:str];
                    NSLog(@"解压码是%d,,,,路径是%@",zipDec,model.filePath);
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

            }
            
            
            return;
        }
        cell.progressView.backgroundColor = CCRGBColor(35,161,236);
        OfflinePlayBackViewController *offlinePlayBackVC = [[OfflinePlayBackViewController alloc] initWithDestination:model.filePath];
        [UIApplication sharedApplication].idleTimerDisabled=YES;
        [self presentViewController:offlinePlayBackVC animated:YES completion:nil];
        
    } else {
        cell.informationLabel.text = @"文件处理失败\t请重新下载";
        cell.downloadImageView.image = [UIImage imageNamed:@"error"];
        cell.progressView.backgroundColor = CCRGBColor(255,0,23);
        
    }
//});
//    [self.tableView reloadData];
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
        cell.informationLabel.text = [NSString stringWithFormat:@"下载中%.2f%@/s",[CCDownloadUtility calculateFileSizeInUnit:model.progress.speed],[CCDownloadUtility calculateUnit:model.progress.speed]];
        cell.downloadImageView.image = [UIImage imageNamed:@"downloading"];
        cell.progressView.backgroundColor = CCRGBColor(0,203,64);
    } else if (model.state == 3) {//CCDownloadStateSuspended,下载暂停
        cell.informationLabel.text = @"暂停下载";
        cell.downloadImageView.image = [UIImage imageNamed:@"pause"];
        cell.progressView.backgroundColor = CCRGBColor(35,161,236);
        [cell updateUIWithAlreadyDownLoadSize:model.progress.totalBytesWritten totalSize:model.progress.totalBytesExpectedToWrite];
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
        });
    }

    return cell;
}

-(void)dealloc {
    [self removeObserverObjC];
}

- (void)appWillEnterBackgroundNotification {
}
- (void)applicationDidBecomeActiveNotification {
    //每次回到前台，把所有正在下载中的任务，手动开始一遍
    CCDownloadSessionManager * manager = [CCDownloadSessionManager manager];
    for (CCDownloadModel * model in manager.downloadModelList) {
        if (model.state == DWDownloadStateRunning) {
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


- (void)setupUI {
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,102,51)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.view.backgroundColor = CCRGBColor(250, 250, 250);
    
    UIBarButtonItem *addUrlButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addUrlClicked)];
    self.navigationItem.rightBarButtonItem = addUrlButton;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CCGetRealFromPt(178), CCGetRealFromPt(34))];
    [label setTextColor:[UIColor whiteColor]];
    label.font = [UIFont systemFontOfSize:FontSize_34];
    label.text = @"回放离线播放";
    
    self.navigationItem.titleView = label;
    
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(self.view);
    }];
}



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

//设置样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;

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


@end
