//
//  CCProxy.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/25.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCProxy.h"

@interface CCProxy()
@property (nonatomic, weak) id weakObject;
@end

@implementation CCProxy

-(instancetype)initWithWeakObject:(id)obj{
    _weakObject = obj;
    return self;
}
+(instancetype)proxyWithWeakObject:(id)obj{
    return [[CCProxy alloc] initWithWeakObject:obj];
}
/**
 * 消息转发，让_weakObject响应事件
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _weakObject;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_weakObject respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}
@end
