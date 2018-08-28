//
//  FileManager.h
//  Test
//
//  Created by cc on 2017/2/24.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (instancetype)sharedInstance;

-(NSMutableDictionary *)plist ;

-(void)saveplist:(NSMutableDictionary *)plist ;

@end
