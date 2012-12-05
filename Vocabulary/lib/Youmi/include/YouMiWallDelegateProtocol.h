//
//  YouMiWallDelegateProtocol.h
//  YouMiSDK
//
//  Created by Layne on 12-01-05.
//  Copyright (c) 2012年 YouMi Mobile Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouMiWallAppModel.h"


// Notifications info key
#define YOUMI_WALL_NOTIFICATION_USER_INFO_FEATURED_APP_KEY      @"Featured App"
#define YOUMI_WALL_NOTIFICATION_USER_INFO_OFFERS_APP_KEY        @"Offers App"
#define YOUMI_WALL_NOTIFICATION_USER_INFO_EARNED_POINTS_KEY     @"Earned Points"
#define YOUMI_WALL_NOTIFICATION_USER_INFO_ERROR_KEY             @"ERROR"


// Featured app
#define YOUMI_FEATURED_APP_DATA_RESPONSE_NOTIFICATION           @"YOUMI_FEATURED_APP_DATA_RESPONSE_NOTIFICATION"            // 请求推荐应用开源数据成功
#define YOUMI_FEATURED_APP_RESPONSE_NOTIFICATION                @"YOUMI_FEATURED_APP_RESPONSE_NOTIFICATION"                 // 请求推荐应用成功

#define YOUMI_FEATURED_APP_DATA_RESPONSE_NOTIFICATION_ERROR     @"YOUMI_FEATURED_APP_DATA_RESPONSE_NOTIFICATION_ERROR"      // 请求推荐应用开源数据失败
#define YOUMI_FEATURED_APP_RESPONSE_NOTIFICATION_ERROR          @"YOUMI_FEATURED_APP_RESPONSE_NOTIFICATION_ERROR"           // 请求推荐应用失败

// Offers   
#define YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION             @"YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION"              // 请求应用列表开源数据成功
#define YOUMI_OFFERS_APP_DATA_MORE_RESPONSE_NOTIFICATION        @"YOUMI_OFFERS_APP_DATA_MORE_RESPONSE_NOTIFICATION"         // 请求应用列表更多开源数据成功
#define YOUMI_OFFERS_RESPONSE_NOTIFICATION                      @"YOUMI_OFFERS_RESPONSE_NOTIFICATION"                       // 请求应用列表成功

#define YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION_ERROR       @"YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION_ERROR"        // 请求应用列表开源数据失败
#define YOUMI_OFFERS_APP_DATA_MORE_RESPONSE_NOTIFICATION_ERROR  @"YOUMI_OFFERS_APP_DATA_MORE_RESPONSE_NOTIFICATION_ERROR"   // 请求应用列表更多开源数据失败
#define YOUMI_OFFERS_RESPONSE_NOTIFICATION_ERROR                @"YOUMI_OFFERS_RESPONSE_NOTIFICATION_ERROR"                 // 请求应用列表失败

// View 
#define YOUMI_WALL_VIEW_OPENED_NOTIFICATION                     @"YOUMI_WALL_VIEW_OPENED_NOTIFICATION"                      // 显示全屏页面
#define YOUMI_WALL_VIEW_CLOSED_NOTIFICATION                     @"YOUMI_WALL_VIEW_CLOSED_NOTIFICATION"                      // 隐藏全屏页面

// Points
#define YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION               @"YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION"                // 查询积分请求成功
#define YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION_ERROR         @"YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION_ERROR"          // 查询积分请求失败


@class YouMiWall;

@protocol YouMiWallDelegate <NSObject>
@optional

#pragma mark Request Featured App Notification Methods
 
// 请求推荐应用开源数据成功
// 
// 详解:
//      推荐应用开源数据请求成功后回调该方法
// 补充:
//      查看YOUMI_FEATURED_APP_DATA_RESPONSE_NOTIFICATION
//
- (void)didReceiveFeaturedAppData:(YouMiWall *)adWall appModel:(YouMiWallAppModel *)appModel;

// 请求推荐应用开源数据失败
// 
// 详解:
//      推荐应用开源数据请求失败后回调该方法
// 补充:
//      查看YOUMI_FEATURED_APP_DATA_RESPONSE_NOTIFICATION_ERROR
//
- (void)didFailToReceiveFeaturedAppData:(YouMiWall *)adWall error:(NSError *)error;

// 请求推荐应用成功
// 
// 详解:
//      推荐应用请求成功后回调该方法
// 补充:
//      查看YOUMI_FEATURED_APP_RESPONSE_NOTIFICATION
//
- (void)didReceiveFeaturedApp:(YouMiWall *)adWall;

// 请求推荐应用失败
// 
// 详解:
//      推荐应用请求失败后回调该方法
// 补充:
//      查看YOUMI_FEATURED_APP_RESPONSE_NOTIFICATION_ERROR
//
- (void)didFailToReceiveFeaturedApp:(YouMiWall *)adWall error:(NSError *)error;

#pragma mark Request Offers Notification Methods

// 请求应用列表开源数据成功
// 
// 详解:
//      应用列表开源数据请求成功后回调该方法
// 补充:
//      查看YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION
//
- (void)didReceiveOffersAppData:(YouMiWall *)adWall offersApp:(NSArray *)apps;

// 请求应用列表更多开源数据成功
// 
// 详解:
//      应用列表更多开源数据请求成功后回调该方法
// 补充:
//      查看YOUMI_OFFERS_APP_DATA_MORE_RESPONSE_NOTIFICATION
//
- (void)didReceiveMoreOffersAppData:(YouMiWall *)adWall offersApp:(NSArray *)apps;

// 请求应用列表开源数据失败
// 
// 详解:
//      应用列表开始数据请求失败后回调该方法
// 补充:
//      查看YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION_ERROR
//
- (void)didFailToReceiveOffersAppData:(YouMiWall *)adWall error:(NSError *)error;

// 请求应用列表更多开源数据失败
// 
// 详解:
//      应用列表更多开源数据请求失败后回调该方法
// 补充:
//      查看YOUMI_OFFERS_APP_DATA_MORE_RESPONSE_NOTIFICATION_ERROR
//
- (void)didFailToReceiveMoreOffersAppData:(YouMiWall *)adWall error:(NSError *)error;

// 请求应用列表成功
// 
// 详解:
//      应用列表请求成功后回调该方法
// 补充:
//      查看YOUMI_OFFERS_RESPONSE_NOTIFICATION
//
- (void)didReceiveOffers:(YouMiWall *)adWall;

// 请求应用列表失败
// 
// 详解:
//      应用列表请求失败后回调该方法
// 补充:
//      查看YOUMI_OFFERS_RESPONSE_NOTIFICATION_ERROR
//
- (void)didFailToReceiveOffers:(YouMiWall *)adWall error:(NSError *)error;

#pragma mark Screen View Notification Methods

// 显示全屏页面
// 
// 详解:
//      全屏页面显示完成后回调该方法
// 补充:
//      查看YOUMI_WALL_VIEW_OPENED_NOTIFICATION
//
- (void)didShowWallView:(YouMiWall *)adWall;

// 隐藏全屏页面
// 
// 详解:
//      全屏页面隐藏完成后回调该方法
// 补充:
//      查看YOUMI_WALL_VIEW_CLOSED_NOTIFICATION
//
- (void)didDismissWallView:(YouMiWall *)adWall;

#pragma mark Request User Account Notification Methods

// 积分记录
extern NSString *const kOneAccountRecordOrderIDOpenKey;     // 订单号
extern NSString *const kOneAccountRecordUserIDOpenKey;      // 用户标示符，查看YouMiWall的 @property userID;
extern NSString *const kOneAccountRecordStoreIDOpenKey;     // 广告标示符
extern NSString *const kOneAccountRecordNameOpenKey;        // 安装的应用名称
extern NSString *const kOneAccountRecordPoinstsOpenKey;     // 获得的积分[NSNumber]
extern NSString *const kOneAccountRecordChannelOpenKey;     // 渠道号，查看YouMiWall的 @property channelID;
extern NSString *const kOneAccountRecordTimeStampOpenKey;   // 安装记录GMT时间[NSString]

// 查询积分情况成功
// @info 里面包含积分记录的NSDictionary
// 
// 详解:
//      积分查询请求成功后回调该方法
// 补充:
//      查看YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION
// 
- (void)didReceiveEarnedPoints:(YouMiWall *)adWall info:(NSArray *)info;

// 查询积分情况失败
// 
// 详解:
//      积分查询请求失败后回调该方法
// 补充:
//      查看YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION_ERROR
//
- (void)didFailToReceiveEarnedPoints:(YouMiWall *)adWall error:(NSError *)error;

@end
    