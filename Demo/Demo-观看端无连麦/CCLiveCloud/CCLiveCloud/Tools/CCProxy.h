//
//  CCProxy.h
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/25.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCProxy : NSProxy

-(instancetype)initWithWeakObject:(id)obj;
+(instancetype)proxyWithWeakObject:(id)obj;
@end

NS_ASSUME_NONNULL_END
