//
//  YouMiFeaturedAppModel.h
//  YouMiSDK
//
//  Created by Layne on 12-01-05.
//  Copyright (c) 2012年 YouMi Mobile Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YouMiWallAppModel : NSObject <NSCoding, NSCopying> {
 @private
    NSString    *_storeID;
    NSString    *_identifier;
    NSString    *_name;
    NSString    *_desc;
    NSString    *_price;
    NSInteger   _points;
    NSString    *_size;
    NSString    *_category;
    NSString    *_author;
    NSString    *_smallIconURL;
    NSString    *_largeIconURL;
    NSString    *_linkURL;
    NSDate      *_expiredDate;
}

@property(nonatomic, copy, readonly)    NSString    *storeID;           // 该开放源应用的标示
@property(nonatomic, copy, readonly)    NSString    *identifier;        // 应用的Bundle Identifier
@property(nonatomic, copy, readonly)    NSString    *name;              // 应用名称
@property(nonatomic, copy, readonly)    NSString    *desc;              // 应用描述
@property(nonatomic, copy, readonly)    NSString    *price;             // 应用在App Store的购买价格
@property(nonatomic, assign, readonly)  NSInteger   points;             // 积分值[该值对有积分应用有效，对无积分应用默认为0]
@property(nonatomic, copy, readonly)    NSString    *size;              // 安装包大小
@property(nonatomic, copy, readonly)    NSString    *category;          // 应用的类别
@property(nonatomic, copy, readonly)    NSString    *author;            // 应用版权所有者
@property(nonatomic, copy, readonly)    NSString    *smallIconURL;      // 应用的小图标
@property(nonatomic, copy, readonly)    NSString    *largeIconURL;      // 应用的大图标
@property(nonatomic, copy, readonly)    NSString    *linkURL;           // 应用点击后的链接
@property(nonatomic, copy, readonly)    NSDate      *expiredDate;       // 该开放源的过期时间

// 初始化方法
// 
// 详解:
//      默认情况下你不能通过该方法来生成一个实例子，该方法只由内部使用。
//
- (id)initWithDictionary:(NSDictionary *)source;

@end
