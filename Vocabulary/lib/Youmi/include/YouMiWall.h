//
//  YouMiWall.h
//  YouMiSDK
//
//  Created by Layne on 12-01-05.
//  Copyright (c) 2012年 YouMi Mobile Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouMiWallDelegateProtocol.h"


typedef enum {
    YouMiWallAnimationTransitionNone,  // no animation
    YouMiWallAnimationTransitionZoomIn,
    YouMiWallAnimationTransitionZoomOut,
    YouMiWallAnimationTransitionFade,
    YouMiWallAnimationTransitionPushFromBottom,
    YouMiWallAnimationTransitionPushFromTop
} YouMiWallAnimationTransition;


@interface YouMiWall : NSObject

// 开发者应用ID
// 
// 详解:
//      前往有米主页:http://www.youmi.net/ 注册一个开发者帐户，同时注册一个应用，获取对应应用的ID
// 
@property(nonatomic, copy)                      NSString    *appID;

// 开发者的安全密钥
// 
// 详解:
//      前往有米主页:http://www.youmi.net/ 注册一个开发者帐户，同时注册一个应用，获取对应应用的安全密钥
// 
@property(nonatomic, copy)                      NSString    *appSecret;

// 应用的版本信息
// Default:
//      @"Bundle version"
// 详解:
//      返回开发者自己应用的版本信息
// 补充:
//      返回的版本号需要使用浮点的类型,比如版本为1.0或者1.2等，目前服务器不支持1.1.1等版本的形式，有效低位版本只有一位，可以为1.12等
//
@property(nonatomic, copy)                      NSString    *appVersion;

// 应用发布的渠道号
// Default:
//      @1
// 详解:
//      该参数主要给先推广该应用的时候，打包的渠道号
// 
@property(nonatomic, assign)                    NSInteger   channelID;

// 用户ID
// Default:
//      @MD5(UDID)
// 详解:
//      该标示符主要用于跟踪用户的安装情况，以便记录用户安装应用获得的积分情况
// 补充:
//      该属性适应于有积分应用
// 
@property(nonatomic,copy)                      NSString    *userID;

// 委托
// 
// 详解:
//      主要用于跟踪回调方法
// 
@property(nonatomic, assign)                                id<YouMiWallDelegate> delegate;


// SDK Version
// 
+ (NSString *)sdkVersion;

// 统计定位请求
// Default:
//      @YES
// 详解:
//      返回是否允许使用GPS定位用户所在的坐标，主要是为了帮助开发者了解自己应用的分布情况，同时帮助精准投放广告需要
//      [默认定位以帮助开发者了解自己软件精确投放广告]
// 
+ (void)setShouldGetLocation:(BOOL)flag;

// 是否允许使用sqlite3来替用户保存一些下载的图片，以便节省用户的流量
// Default:
//      @YES
// 详解:
//      帮助用户节省流量，同时加快广告显示速度
// 
+ (void)setShouldCacheImage:(BOOL)flag;

// 实例方法
// 
+ (YouMiWall *)wallWithAppID:(NSString *)appID withAppSecret:(NSString *)appSecret;
- (id)initWithAppID:(NSString *)appID withAppSecret:(NSString *)appSecret;

// Featured App

// 请求推荐应用的开源数据
// 参数->rewarded @YES 有积分模式  @NO 无积分模式
//
// 详解:
//      通过获取推荐应用的开源数据，你可以组织推荐显示界面。记住配合userInstallFeaturedApp:使用
// 补充:
//      1.有积分模式: 应用本身采用积分激励下载模式
//      2.无积分模式: 应用本身无积分激励模式，适应于应用交叉推广
// 
// 回调:
//      1.成功->didReceiveFeaturedAppData:appModel: 或 YOUMI_FEATURED_APP_DATA_RESPONSE_NOTIFICATION
//      2.失败->didFailToReceiveFeaturedAppData:error: 或 YOUMI_FEATURED_APP_DATA_RESPONSE_NOTIFICATION_ERROR
// 
- (void)requestFeaturedAppData:(BOOL)rewarded;

// 请求推荐应用的开源数据
//
// 详解:
//      当你使用requestFeaturedAppData:请求推荐应用开源数据后，如果用户单击对应的应用，你需要回调该方法
//      后台在接收到该回调信息后，会记录该点击情况，并打开相应的应用下载页面（比如跳转到App Store）
// 
- (void)userInstallFeaturedApp:(YouMiWallAppModel *)appModel;

// 请求推荐应用
// 参数->rewarded @YES 有积分模式  @NO 无积分模式
//
// 详解:
//      使用该方法请求的推荐应用为默认的Web页面，你需要通过使用showFeaturedApp或showFeaturedApp:来显示界面
// 补充:
//      1.有积分模式: 应用本身采用积分激励下载模式
//      2.无积分模式: 应用本身无积分激励模式，适应于应用交叉推广
// 
// 回调:
//      1.成功->didReceiveFeaturedApp: 或 YOUMI_FEATURED_APP_RESPONSE_NOTIFICATION
//      2.失败->didFailToReceiveFeaturedApp:error: 或 YOUMI_FEATURED_APP_RESPONSE_NOTIFICATION_ERROR
// 
- (void)requestFeaturedApp:(BOOL)rewarded;

// 显示推荐应用
//
// 详解:
//      调用该方法之前确认requestFeaturedApp:请求推荐应用成功
// 
// 回调:
//      1.成功->didShowWallView: 或 YOUMI_WALL_VIEW_OPENED_NOTIFICATION
//      2.失败->didDismissWallView: 或 YOUMI_WALL_VIEW_CLOSED_NOTIFICATION
// 
- (BOOL)showFeaturedApp;

// 显示推荐应用
//
// 详解:
//      该方法和showFeaturedApp作用相同，只是该方法可以控制显示全屏页面的动画效果
// 
// 回调:
//      同上
// 
- (BOOL)showFeaturedApp:(YouMiWallAnimationTransition)transition;


// Offers

// 请求应用列表开源数据
// 参数->rewarded @YES 有积分模式  @NO 无积分模式
//
// 详解:
//      使用该方法请求的是应用列表的开始数据，可以使用这些开源数据来组织界面。记住配合userInstallOffersApp:使用
// 补充:
//      1.有积分模式: 应用本身采用积分激励下载模式
//      2.无积分模式: 应用本身无积分激励模式，适应于应用交叉推广
// 
// 回调:
//      1.成功->didReceiveOffersAppData:offersApp: 或 YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION
//      2.失败->didFailToReceiveOffersAppData:error: 或 YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION_ERROR
// 
- (void)requestOffersAppData:(BOOL)rewarded;    // default offers app count @10

// 请求应用列表开源数据
// 参数->rewarded @YES 有积分模式  @NO 无积分模式
//
// 详解:
//      该方法和requestOffersAppData:作用相同，都是请求应用列表开源数据，只是该方法多了|pageCount|参数，用于指定请求的页面的应用个数
// 补充:
//      1.有积分模式: 应用本身采用积分激励下载模式
//      2.无积分模式: 应用本身无积分激励模式，适应于应用交叉推广
//
// 回调:
//      同上
// 
- (void)requestOffersAppData:(BOOL)rewarded pageCount:(NSUInteger)count;

// 请求更多应用列表的开源数据
//
// 详解:
//      该方法和requestOffersAppData:或requestOffersAppData:pageCount:配合使用，用于请求下一页的的源数据
// 补充:
//      1.该方法主要是用于请求非重复的数据，如果你多次使用requestOffersAppData:或requestOffersAppData:pageCount:方法得到的开源应用数据
//        有可能是重复的。
//      2.配合userInstallOffersApp:方法使用
// 
// 回调:
//      1.成功->didReceiveMoreOffersAppData:offersApp: 或 YOUMI_OFFERS_APP_DATA_MORE_RESPONSE_NOTIFICATION
//      2.失败->didFailToReceiveMoreOffersAppData:error: 或 YOUMI_OFFERS_APP_DATA_MORE_RESPONSE_NOTIFICATION_ERROR
// 
- (void)requestMoreOffersAppData;  // next page wiht |pageCount| app

// 应用列表开源数据点击回调方法
//
// 详解:
//      当用户点击了你使用requestOffersAppData:,requestOffersAppData:pageCount或requestMoreOffersAppData请求的开源数据后，
//      回调该方法，可以告知后台记录点击事件并打开跳转链接
// 
- (void)userInstallOffersApp:(YouMiWallAppModel *)appModel;

// 请求应用列表
// 参数->rewarded @YES 有积分模式  @NO 无积分模式
//
// 详解:
//      使用该方法请求的应用列表为默认的Web页面，你需要通过使用showOffers或showOffers:来显示界面
// 补充:
//      1.有积分模式: 应用本身采用积分激励下载模式
//      2.无积分模式: 应用本身无积分激励模式，适应于应用交叉推广
// 
// 回调:
//      1.成功->didReceiveOffers: 或 YOUMI_OFFERS_RESPONSE_NOTIFICATION
//      2.失败->didFailToReceiveOffers:error: 或 YOUMI_OFFERS_RESPONSE_NOTIFICATION_ERROR
// 
- (void)requestOffers:(BOOL)rewarded;

// 显示应用列表
//
// 详解:
//      调用该方法之前确认requestOffers:请求应用列表成功
// 
// 回调:
//      1.成功->didShowWallView: 或 YOUMI_WALL_VIEW_OPENED_NOTIFICATION
//      2.失败->didDismissWallView:error: 或 YOUMI_WALL_VIEW_CLOSED_NOTIFICATION
// 
- (BOOL)showOffers;

// 显示应用列表
//
// 详解:
//      该方法和showOffers作用相同，只是该方法可以控制显示全屏页面的动画效果
// 
// 回调:
//      同上
// 
- (BOOL)showOffers:(YouMiWallAnimationTransition)transition;

// Points

// 查询用户安装获取积分情况
//
// 详解:
//      当用户安装完成应用并执行了相关操作后，后台将会保存相应的安装记录和所获得的积分情况。
//      通过该接口，你可以获取用户所赚取的积分
// 补充:
//      该方法适应于之前任何请求使用@rewarded为YES的安装记录
// 
// 回调:
//      1.成功->didReceiveEarnedPoints:info: 或 YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION
//      2.失败->didFailToReceiveEarnedPoints:error: 或 YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION_ERROR
// 
- (void)requestEarnedPoints;

// 查询用户安装获取积分情况
//
// 详解:
//      该方法和requestEarnedPoints方法作用相同，都是查询用户获取的积分情况。
//      区别在于使用该方法可以在后台生成一个Timer来控制重复查询及重复的次数。
// 
// 回调:
//      同上
// 
- (void)requestEarnedPointsWithTimeInterval:(NSTimeInterval)seconds repeatCount:(NSUInteger)count;  // |count| assigned to 0 indicate infinity

// 查询用户安装获取积分情况
//
// 详解:
//      该方法和requestEarnedPoints方法作用一样，只是可以通过block的方法来处理请求结果
// 
// 回调:
//      同上
// 
- (void)requestEarnedPoints:(void (^)(NSError *error, NSArray *info))notification;

// 查询用户安装获取积分情况
//
// 详解:
//      该方法和requestEarnedPoints:作用一样，同样和requestEarnedPointsWithTimeInterval:repeatCount:类似，
//      它采用重复请求模式来查询积分情况
// 
// 回调:
//      同上
// 
- (void)requestEarnedPointsWithTimeInterval:(NSTimeInterval)seconds 
                                repeatCount:(NSUInteger)count 
                                 usingBlock:(void (^)(NSError *error, NSArray *info))notification;  // |count| assigned to 0 indicate infinity

@end


