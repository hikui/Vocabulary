//  UMOnlineConfig
//  Copyright © 2015-2016 Umeng. All rights reserved.


#import <Foundation/Foundation.h>

#define UMOnlineConfigDidFinishedNotification @"OnlineConfigDidFinishedNotification"

@interface UMOnlineConfig : NSObject
///---------------------------------------------------------------------------------------
/// @name  在线参数：可以动态设定应用中的参数值
///---------------------------------------------------------------------------------------

/** 此方法会检查并下载服务端设置的在线参数,例如可在线更改SDK端发送策略。
 请在[MobClick startWithAppkey:]方法之后调用;
 监听在线参数更新是否完成，可注册UMOnlineConfigDidFinishedNotification通知
 @param .
 @return void.
 */
+ (void)updateOnlineConfigWithAppkey:(NSString *)key;


/** 返回已缓存的在线参数值
 带参数的方法获取某个key的值，不带参数的获取所有的在线参数.
 需要先调用updateOnlineConfig才能使用,如果想知道在线参数是否完成完成，请监听UMOnlineConfigDidFinishedNotification
 @param key
 @return (NSString *) .
 */
+ (NSDictionary *)getConfigParams;
+ (NSString *)getConfigParams:(NSString *)key;

/** 设置是否打印sdk的log信息, 默认NO(不打印log).
 @param value 设置为YES,umeng SDK 会输出log信息可供调试参考. 除非特殊需要，否则发布产品时需改回NO.
 @return void.
 */
+ (void)setLogEnabled:(BOOL)value;

@end
