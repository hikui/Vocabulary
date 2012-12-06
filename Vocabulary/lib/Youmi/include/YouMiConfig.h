//
//  YouMiConfig.h
//  YouMiSDK
//
//  Created by  on 12-5-2.
//  Copyright (c) 2012年 YouMi Mobile Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YouMiConfig : NSObject

// 设置开发者应用ID
// 
// 详解:
//      前往有米主页:http://www.youmi.net/ 注册一个开发者帐户，同时注册一个应用，获取对应应用的ID
// 
+ (void)setAppID:(NSString *)appid;
+ (NSString *)appID;

// 开发者的安全密钥
// 
// 详解:
//      前往有米主页:http://www.youmi.net/ 注册一个开发者帐户，同时注册一个应用，获取对应应用的安全密钥
// 
+ (void)setAppSecret:(NSString *)secret;
+ (NSString *)appSecret;

// 设置应用发布的渠道号
//
// 详解:
//      该参数主要用于标识应用发布的渠道
// 
// 补充: 
//      如果你发布到App Store可以设置[YouMiConfig setChannelID:100 description:@"App Store"]
//
+ (void)setChannelID:(NSInteger)channel description:(NSString *)desc;
+ (NSInteger)channelID;
+ (NSString *)channelDesc;

// 请求模式
//
// 详解:
//     默认->模拟器@YES 真机器@NO
//   
// 备注:
//     目前该参数暂无使用，可以不需要设置  
// 
+ (void)setIsTesting:(BOOL)flag;
+ (BOOL)isTesting;

// 统计定位请求
// Default:
//      @YES
// 详解:
//      返回是否允许使用GPS定位用户所在的坐标，目前开参数主要用于帮助推送消息的时候选择地区推送
// 
+ (void)setShouldGetLocation:(BOOL)flag;
+ (BOOL)shouldGetLocation;

// 是否允许使用sqlite3来替用户保存一些下载的图片，以便节省用户的流量
// Default:
//      @YES
// 详解:
//      帮助用户节省流量，同时加快广告显示速度
// 
+ (void)setShouldCacheImage:(BOOL)flag;
+ (BOOL)shouldCacheImage;

@end
