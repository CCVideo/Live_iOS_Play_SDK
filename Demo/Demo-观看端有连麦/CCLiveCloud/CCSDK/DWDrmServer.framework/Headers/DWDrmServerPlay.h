#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>

@interface DWDrmServerPlay : NSObject

/**
 *  @brief 若 server 启动成功，listenPort 为server绑定的端口。
 */
@property (assign, nonatomic, readonly)UInt16 listenPort;

/**
 *  @brief 初始化 DWDrmServer
 *
 *  @param port 指定 drmServer 监听的端口。
 *  若port不为0，则绑定指定端口。若绑定失败，则转由内核分配。
 *
 *  @return 返回一个 DWDrmServer 实例
 */
- (id)initWithListenPort:(UInt16)port;

/**
 *  @brief 启动 server
 *
 *  @return 启动成功返回 YES，否则返回NO。
 */
- (BOOL)start;

/**
 *  @brief 停止 server。
 */
- (void)stop;

@end
