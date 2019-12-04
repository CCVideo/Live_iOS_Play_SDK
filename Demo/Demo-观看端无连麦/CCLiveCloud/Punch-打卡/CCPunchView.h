//
//  CCPunchView.h
//  CCLiveCloud
//
//  Created by Clark on 2019/11/1.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
//打卡回调
typedef void(^punchBtnClicked)(NSString *_Nullable);
NS_ASSUME_NONNULL_BEGIN

@interface CCPunchView : UIView

@property (nonatomic,copy) void(^commitSuccess)(BOOL);//打开成功/失败

/**
 初始化打卡

 @param dict 打卡数据
 @param punchBlock 打卡回调
 @param isScreenLandScape 是否全屏
 @return self
 */
-(instancetype) initWithDict:(NSDictionary *)dict
                    punchBlock:(punchBtnClicked)punchBlock
               isScreenLandScape:(BOOL)isScreenLandScape;
/**
更新打卡信息

@param dict 是否提交成功
*/
- (void)updateUIWithDic:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
