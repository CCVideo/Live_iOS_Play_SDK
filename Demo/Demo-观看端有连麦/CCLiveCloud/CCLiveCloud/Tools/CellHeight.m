//
//  CellHeight.m
//  CCLiveCloud
//
//  Created by 何龙 on 2018/12/29.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CellHeight.h"

@interface CellHeight ()

@property (nonatomic, strong) NSMutableDictionary *dic;

@end

static CellHeight *_cellHeight;
@implementation CellHeight

+(CellHeight *)sharedHeight{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cellHeight = [[CellHeight alloc] init];
        _cellHeight.dic = [NSMutableDictionary dictionary];
    });
    return _cellHeight;
}
//存入高度
-(void)setHeight:(CGFloat)height ForKey:(NSString *)url{
    [_cellHeight.dic setValue:[NSString stringWithFormat:@"%lf", height] forKey:url];
}
//取出高度
-(CGFloat)getHeightForKey:(NSString *)url{
    //判断当前url是否已存储,如果已存储,返回高度,否则返回0
    if([[_cellHeight.dic allKeys] containsObject:url])
    {
        CGFloat height = [_cellHeight.dic[url] floatValue];
        return height;
    }else{
        return 0;
    }
}
//清空字典
-(void)removeAllKeys{
    [_cellHeight.dic removeAllObjects];
}
@end
