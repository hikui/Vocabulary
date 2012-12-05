//
//  YouMiPush.h
//  YouMiSDK
//
//  Created by  on 12-4-29.
//  Copyright (c) 2012年 YouMi Mobile Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouMiConfig.h"


typedef enum {
    YouMiPushCertCatProduction  = 0,   // 发布模式(默认)
    YouMiPushCertCatDevelopment = 1    // 开发模式
} YouMiPushCertCat;


// Push管理(开发者工具)
// 
// 目前主要是给开发者提供在线web方式推送信息
//
@interface YouMiPush : NSObject

// 设置渠道信息
// 
// 详解:
//     同见YouMiConfig
//
+ (void)setChannelID:(NSInteger)channel description:(NSString *)desc;

// 设置Push证书类型
//
// 详解:
//     YouMiPushCertCatProduction   -> 发布模式
//     YouMiPushCertCatDevelopment  -> 开发模式（默认）
// 补充:
//     当你设置了相应证书类型之后，请在web页面上面上传对应的证书p12文件
//
+ (void)setCertCat:(YouMiPushCertCat)cert;

// 初始化Push设置并处理推送点击后启动操作
// 
// 详解:
//     该方法主要放置于- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//     并把launchOptions参数传递给该方法即可
//
+ (void)handleWithLaunchOptions:(NSDictionary *)launchOptions;

// 处理推送信息
//
// 详解:
//     该方法主要放置于- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
//     并把userInfo传递给该方法即可
//
+ (void)handlePush:(NSDictionary *)userInfo;

// 保存Push设备令牌
// 
// 详解:
//     在- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//     返回设备令牌之后，调用该方法，把deviceToken传递给该方法即可
// 
+ (void)saveDeviceToken:(NSData *)deviceToken;


@end
