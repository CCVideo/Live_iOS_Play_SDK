//
//  DownLoadViewController.m
//  Test
//
//  Created by cc on 2017/2/10.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "DownLoadViewController.h"
#import "TextFieldUserInfo.h"
#import "OfflinePlayBackVC.h"
#import "Download.h"
#import "SSZipArchive/SSZipArchive.h"
#import "AddUrlViewController.h"
#import "MyTableViewCell.h"
#import "LoadingView.h"
#import "FileManager.h"

@interface DownLoadViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,NSURLSessionDelegate,SSZipArchiveDelegate>

@property(nonatomic,strong)UITableView          *tableView;
@property(nonatomic,  copy)NSString             *alreadyDownloadPath; // 已经下载下来的数据存放的位置。
@property(nonatomic,  copy)NSString             *downloadedPlistPath; // 正在下载进度信息保存的路径
@property(nonatomic,  copy)NSString             *tempStr; // 临时文件路径
@property(nonatomic,strong)NSMutableArray       *taskArr;
@property(nonatomic,strong)NSMutableArray       *nameArr;
@property(nonatomic,strong)LoadingView          *loadingView;
@property(nonatomic,assign)BOOL                 enterbackground;

@end

@implementation DownLoadViewController

- (long long) fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
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

//设置样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CCGetPxFromPt(250);
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Download *download = self.taskArr[indexPath.row];
    [download cancel];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *plist = [[FileManager sharedInstance]plist];
        if (download.downloadType == DOWNLOAD_FINISH_AVAILABLE || download.downloadType == DOWNLOAD_FINISH_NOTAVAILABLE) {
            // 如果已经下载完成，则在已下载的地址里删除。
            NSString *path1 = [self.alreadyDownloadPath stringByAppendingString:download.fileName];
            [[NSFileManager defaultManager] removeItemAtPath:path1 error:nil];
            NSString *fileName = [self SSZipArchiveToDirectoryName:download.fileName];
            NSString *path2 = [self.alreadyDownloadPath stringByAppendingString:fileName];
            [[NSFileManager defaultManager] removeItemAtPath:path2 error:nil];
        }else if(StrNotEmpty(download.tempName)) {
            // 如果任务存在，但是尚未下载完成，则在临时文件夹内删除。
            NSString *path = [self.tempStr stringByAppendingString:download.tempName];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        SaveToUserDefaults(download.downLoadUrl, @(0));
        [self.nameArr removeObject:download.fileName];
        [plist removeObjectForKey:download.downLoadUrl];
        [[FileManager sharedInstance]saveplist:plist];
        // 从下载任务数组中移除
        [self.taskArr removeObject:download];
        
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    });
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

-(void)addUrlClicked {
    WS(ws)
    AddUrlViewController *addUrlViewController = [[AddUrlViewController alloc]initWithAddUrlBlock:^(NSString *url) {
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

        NSMutableDictionary *plist = [[FileManager sharedInstance]plist];
        NSMutableDictionary *tempDic = [plist objectForKey:url];
        if (tempDic) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"下载链接已存在" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                Download *download = [[Download alloc] init];
                
                download.downLoadUrl = url;
                NSArray *array = [url componentsSeparatedByString:@"/"];
                download.fileName = [self fileNameToSave:[array lastObject]];

                download.alreadyDownLoadSize = 0;
                download.downloadType = DOWNLOAD_LOADING;
                download.date = [NSDate date];
            
                NSDate *currentDate = [NSDate date];
                //用于格式化NSDate对象
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                //设置格式：zzz表示时区
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
                //NSDate转NSString
                download.insertDateStr = [dateFormatter stringFromDate:currentDate];
            
                [dic setObject:download.insertDateStr forKey:@"insertDateStr"];
                [dic setObject:download.downLoadUrl forKey:@"downLoadUrl"];
                [dic setObject:download.fileName forKey:@"fileName"];
                [dic setObject:[NSString stringWithFormat:@"%lld",download.alreadyDownLoadSize] forKey:@"alreadyDownLoadSize"];
                [dic setObject:[NSString stringWithFormat:@"%d",download.downloadType] forKey:@"downloadType"];
                SaveToUserDefaults(download.downLoadUrl, @(0));
                [plist setObject:dic forKey:download.downLoadUrl];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[FileManager sharedInstance]saveplist:plist];
                    [ws.nameArr addObject:download.fileName];
                    [ws.taskArr addObject:download];
                    [ws.tableView reloadData];
                });
            }
        }];
    [self.navigationController pushViewController:addUrlViewController animated:YES];
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

- (NSMutableArray *)nameArr{
    if (!_nameArr) {
        _nameArr = [[NSMutableArray alloc] init];
    }
    return _nameArr;
}

- (NSString *)fileNameToSave:(NSString *)fileName {
    NSString *name = fileName;
    for(int i = 0;i < INT_MAX;i++) {
        if(i == 0) {
            if([self.nameArr indexOfObject:name] == NSNotFound) {
                return name;
            }
        } else {
            name = [NSString stringWithFormat:@"%@(%d)",fileName,i];
            if([self.nameArr indexOfObject:name] == NSNotFound) {
                return name;
            }
        }
    }
    return name;
}

- (NSArray *)taskArr{
    if (!_taskArr) {
        _taskArr = [[NSMutableArray alloc] init];
        NSMutableDictionary *plist = [[FileManager sharedInstance]plist];
        for (NSString *url in [plist allKeys]) {
            NSDictionary *dic = [plist objectForKey:url];
            Download *download = [[Download alloc] init];
            download.downLoadUrl = [dic objectForKey:@"downLoadUrl"];
            download.fileName = [dic objectForKey:@"fileName"];
            download.tempName = [dic objectForKey:@"tempName"];
            download.alreadyDownLoadSize = [[dic objectForKey:@"alreadyDownLoadSize"] longLongValue];
            download.totalSize = [[dic objectForKey:@"totalSize"] longLongValue];
            download.downloadType = [[dic objectForKey:@"downloadType"] intValue];
            download.date = [NSDate date];
            download.insertDateStr = [dic objectForKey:@"insertDateStr"];
            [self.nameArr addObject:download.fileName];
            [_taskArr addObject:download];
        }
    }
    return _taskArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enterbackground = NO;
    [self addObserverObjC];
    WS(ws)
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
        make.left.right.bottom.top.mas_equalTo(ws.view);
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.taskArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Download *download = self.taskArr[indexPath.row];

    NSString *identifier = download.insertDateStr;
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
        return cell;
    }

    if(indexPath.row % 2) {
        [cell setBackgroundColor:[UIColor clearColor]];
    } else {
        [cell setBackgroundColor:CCRGBColor(242,242,242)];
    }
    [cell updateUIWithAlreadyDownLoadSize:download.alreadyDownLoadSize totalSize:download.totalSize];
    
    download.loadingBlock = ^(long long alreadyDownLoadSize,long long totalSize,NSString *speed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(download.downloadType == DOWNLOAD_PAUSE) {
                cell.informationLabel.text = @"暂停下载";
                cell.downloadImageView.image = [UIImage imageNamed:@"pause"];
                cell.progressView.backgroundColor = CCRGBColor(35,161,236);
            } else if (download.downloadType == DOWNLOAD_LOADING) {
                cell.informationLabel.text = [NSString stringWithFormat:@"下载中\t%@",speed];
                cell.downloadImageView.image = [UIImage imageNamed:@"downloading"];
                cell.progressView.backgroundColor = CCRGBColor(0,203,64);
            }
            [cell updateUIWithAlreadyDownLoadSize:alreadyDownLoadSize totalSize:totalSize];
            cell.progressLabel.text = [NSString stringWithFormat:@"%.2fMB\t / %.2fMB\t （%.2f%%）",alreadyDownLoadSize/MB,totalSize/MB,((float)alreadyDownLoadSize/(float)totalSize) * 100];
        });
    };
    __block Download *blockDownload = download;
    __block MyTableViewCell *blockCell = cell;
    download.complet = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.informationLabel.text = @"下载完成\t解压中";
            cell.downloadImageView.image = [UIImage imageNamed:@"play"];
            [cell updateUIToFull];
            cell.progressLabel.text = [NSString stringWithFormat:@"%.2fMB\t / %.2fMB\t （100.00%%）",download.totalSize/MB,download.totalSize/MB];
            cell.progressView.backgroundColor = CCRGBColor(35,161,236);
//            NSLog(@"enterbackground = %d",self.enterbackground);
            if(self.enterbackground == NO) {
                [self SSZipArchiveAction:blockDownload myTableViewCell:blockCell];
            } else {
                cell.informationLabel.text = @"下载完成\t请点击解压";
            }
        });
    };
    download.error = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.informationLabel.text = @"下载失败";
            cell.downloadImageView.image = [UIImage imageNamed:@"error"];
            if(download.totalSize <= 0) {
                cell.progressLabel.text = [NSString stringWithFormat:@"0.00MB\t / --\t （0.00%%）"];
            } else {
            cell.progressLabel.text = [NSString stringWithFormat:@"%.2fMB\t / %.2fMB\t （%.2f%%）",download.alreadyDownLoadSize/MB,download.totalSize/MB,((float)download.alreadyDownLoadSize/(float)download.totalSize) * 100];
            }
            cell.progressView.backgroundColor = CCRGBColor(255,0,23);
        });
    };
    cell.fileNameLabel.text = [download.fileName stringByRemovingPercentEncoding];
    if(download.totalSize <= 0) {
        cell.progressLabel.text = [NSString stringWithFormat:@"0.00MB\t / --\t （0.00%%）"];
    } else {
        cell.progressLabel.text = [NSString stringWithFormat:@"%.2fMB\t / %.2fMB\t （%.2f%%）",download.alreadyDownLoadSize/MB,download.totalSize/MB,((float)download.alreadyDownLoadSize/(float)download.totalSize) * 100];
    }
    
    if (download.downloadType == DOWNLOAD_PAUSE) {
        cell.informationLabel.text = @"暂停下载";
        cell.downloadImageView.image = [UIImage imageNamed:@"pause"];
        cell.progressView.backgroundColor = CCRGBColor(35,161,236);
    } else if (download.downloadType == DOWNLOAD_LOADING) {
        cell.informationLabel.text = [NSString stringWithFormat:@"下载中\t%@",@"0 KB/s"];
        cell.downloadImageView.image = [UIImage imageNamed:@"downloading"];
        cell.progressView.backgroundColor = CCRGBColor(0,203,64);
        [download start];
    } else if(download.downloadType == DOWNLOAD_FINISH_NOTAVAILABLE) {
        cell.informationLabel.text = @"下载完成\t解压中";
        [cell updateUIToFull];
        cell.downloadImageView.image = [UIImage imageNamed:@"play"];
        cell.progressView.backgroundColor = CCRGBColor(35,161,236);

        [self SSZipArchiveAction:download myTableViewCell:cell];

    } else if(download.downloadType == DOWNLOAD_FINISH_AVAILABLE) {
        cell.informationLabel.text = @"下载完成\t可播放";
        [cell updateUIToFull];
        cell.downloadImageView.image = [UIImage imageNamed:@"play"];
        cell.progressView.backgroundColor = CCRGBColor(35,161,236);
    } else if(download.downloadType == DOWNLOADD_ERROR) {
        cell.informationLabel.text = @"下载失败";
        cell.downloadImageView.image = [UIImage imageNamed:@"error"];
        cell.progressView.backgroundColor = CCRGBColor(255,0,23);
    } else if(download.downloadType == DOWNLOAD_FINISH_ZIPARCHIVE_ERROR) {
        cell.informationLabel.text = @"文件处理失败\t请重新下载";
        cell.downloadImageView.image = [UIImage imageNamed:@"error"];
        cell.progressView.backgroundColor = CCRGBColor(255,0,23);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MyTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    Download *download = self.taskArr[indexPath.row];
    if (download.downloadType == DOWNLOAD_PAUSE) {
        download.downloadType = DOWNLOAD_LOADING;
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.informationLabel.text = [NSString stringWithFormat:@"下载中\t%@",@"0 KB/s"];
            cell.downloadImageView.image = [UIImage imageNamed:@"downloading"];
            cell.progressView.backgroundColor = CCRGBColor(0,203,64);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [download start];
            });
        });
    } else if (download.downloadType == DOWNLOAD_LOADING) {
        download.downloadType = DOWNLOAD_PAUSE;
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.informationLabel.text = @"暂停下载";
            cell.downloadImageView.image = [UIImage imageNamed:@"pause"];
            cell.progressView.backgroundColor = CCRGBColor(35,161,236);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [download suspended];
            });
        });
    } else if(download.downloadType == DOWNLOAD_FINISH_NOTAVAILABLE) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([cell.informationLabel.text isEqualToString:@"下载完成\t请点击解压"]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self SSZipArchiveAction:download myTableViewCell:cell];
                });
            }
            cell.informationLabel.text = @"下载完成\t解压中";
            cell.downloadImageView.image = [UIImage imageNamed:@"play"];
            cell.progressView.backgroundColor = CCRGBColor(35,161,236);
            [cell updateUIToFull];
        });
    } else if(download.downloadType == DOWNLOAD_FINISH_AVAILABLE) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.informationLabel.text = @"下载完成\t可播放";
            cell.downloadImageView.image = [UIImage imageNamed:@"play"];
            cell.progressView.backgroundColor = CCRGBColor(35,161,236);
            [cell updateUIToFull];
            
            NSString *fileName = [self SSZipArchiveToDirectoryName:download.fileName];
            NSString *destination = [self.alreadyDownloadPath stringByAppendingString:fileName];
            OfflinePlayBackVC *offlinePlayBackVC = [[OfflinePlayBackVC alloc] initWithDestination:destination];
            [UIApplication sharedApplication].idleTimerDisabled=YES;
            [self presentViewController:offlinePlayBackVC animated:YES completion:nil];
        });
        
    } else if(download.downloadType == DOWNLOADD_ERROR) {
        download.downloadType = DOWNLOAD_LOADING;
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.downloadImageView.image = [UIImage imageNamed:@"downloading"];
            cell.progressView.backgroundColor = CCRGBColor(0,203,64);
            cell.informationLabel.text = [NSString stringWithFormat:@"下载中\t%@",@"0 KB/s"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [download start];
            });
        });
    } else if(download.downloadType == DOWNLOAD_FINISH_ZIPARCHIVE_ERROR) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.informationLabel.text = @"文件处理失败\t请重新下载";
            cell.downloadImageView.image = [UIImage imageNamed:@"error"];
            cell.progressView.backgroundColor = CCRGBColor(255,0,23);
        });
    }
    
    NSMutableDictionary *plist = [[FileManager sharedInstance]plist];
    NSMutableDictionary *dicItem = [plist objectForKey:download.downLoadUrl];
    if(dicItem) {
        [dicItem setObject:[NSString stringWithFormat:@"%d",download.downloadType] forKey:@"downloadType"];
        [[FileManager sharedInstance]saveplist:plist];
    }
}

-(void)SSZipArchiveAction:(Download *)download myTableViewCell:(MyTableViewCell *)cell {
    WS(ws)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *plist = [[FileManager sharedInstance]plist];
        NSMutableDictionary *dicItem = [plist objectForKey:download.downLoadUrl];
        
        NSString *srcPath = [ws.alreadyDownloadPath stringByAppendingString:download.fileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:srcPath]) {
            download.downloadType = DOWNLOAD_FINISH_ZIPARCHIVE_ERROR;
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.informationLabel.text = @"文件处理失败\t请重新下载";
                cell.downloadImageView.image = [UIImage imageNamed:@"error"];
                cell.progressView.backgroundColor = CCRGBColor(255,0,23);
            });
            NSString *msg = [NSString stringWithFormat:@"%@文件处理错误，请重新下载",download.fileName];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else if(dicItem) {
            NSString *fileName = [self SSZipArchiveToDirectoryName:download.fileName];
            NSString *destination = [ws.alreadyDownloadPath stringByAppendingString:fileName];
//            NSTimeInterval startLoadingTime = [[NSDate date] timeIntervalSince1970];
//            NSLog(@"---startLoadingTime = %f",startLoadingTime);
            [SSZipArchive unzipFileAtPath:srcPath toDestination:destination];
//            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//            NSLog(@"---time - startLoadingTime = %f",time - startLoadingTime);
            download.downloadType = DOWNLOAD_FINISH_AVAILABLE;
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.informationLabel.text = @"下载完成\t可播放";
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:srcPath error:nil];
                SaveToUserDefaults(download.downLoadUrl, @(0));
            });
        }
        
        [dicItem setObject:[NSString stringWithFormat:@"%d",download.downloadType] forKey:@"downloadType"];
        // 将此字典更新至plist文件中
        [plist setObject:dicItem forKey:download.downLoadUrl];
        // 更新数据库
        [[FileManager sharedInstance]saveplist:plist];
    });
}

-(NSString *)SSZipArchiveToDirectoryName:(NSString *)zipname {
    NSArray *array = [zipname componentsSeparatedByString:@".ccr"];
    NSString *fileName = nil;
    if([array count] == 1) {
        fileName = [array firstObject];
    } else {
        fileName = [[array firstObject] stringByAppendingString:[array lastObject]];
    }
    return fileName;
}

// 懒加载获取几个地址路径
// 已经下载的路径
- (NSString *)alreadyDownloadPath{
    if (_alreadyDownloadPath == nil) {
        _alreadyDownloadPath = [NSString stringWithFormat:@"%@/Library/%@/", NSHomeDirectory(),@"Download"];
        // 在相应的路径创建对应的文件夹
        [[NSFileManager defaultManager] createDirectoryAtPath:_alreadyDownloadPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _alreadyDownloadPath;
}

// 判断本地的Download.plist文件中是否存在该下载
- (BOOL)existTaskWithUrl:(NSString *)str{
    NSMutableDictionary *dic = [[FileManager sharedInstance]plist];
    if ([dic objectForKey:str]) {
        return YES;
    }
    return NO;
}

// 临时文件夹
- (NSString *)tempStr{
    return [NSString stringWithFormat:@"%@/%@/", NSHomeDirectory(), @"tmp"];
}

-(void)dealloc {
    [self removeObserverObjC];
}

- (void)appWillEnterBackgroundNotification {
    self.enterbackground = YES;
}

- (void)appWillEnterForegroundNotification {
    self.enterbackground = NO;
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.tableView reloadData];
    });
}

#pragma mark Notification
-(void)addObserverObjC {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)removeObserverObjC {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}


@end


