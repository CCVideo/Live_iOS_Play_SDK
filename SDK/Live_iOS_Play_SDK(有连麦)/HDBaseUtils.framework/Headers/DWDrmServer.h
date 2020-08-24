#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>

@interface DWDrmServer : NSObject

/**
 *  @brief 若 server 启动成功，listenPort 为server绑定的端口。
 */
@property (assign, nonatomic, readonly)UInt16 listenPort;

/*!
 * @method
 * @abstract 初始化DWDrmServer
 * @discussion 初始化DWDrmServer
 * @param port 指定drmServer监听的端口
 * @result 返回一个DWDrmServer实例
 */
-(id)initWithListenPort:(UInt16)port;

/*!
 * @method
 * @abstract 启动server
 * @discussion 启动server
 * @result 启动成功返回YES，否则返回NO
 */
-(BOOL)start;

/*!
 * @method
 * @abstract 停止server
 * @discussion 停止server
 */
-(void)stop;

/*!
 * @method
 * @abstract 重启server
 * @discussion 建议在app回到前台时调用，不需要调用stop/start方法了
 */
-(void)reStartSocket;

@end
