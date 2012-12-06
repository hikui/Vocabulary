//
//  YouMiData.h
//  YouMiSDK
//
//  Created by  on 12-4-29.
//  Copyright (c) 2012年 YouMi Mobile Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouMiConfig.h"


extern NSString *const kDefaultDomainName;

// 有米数据中心(开发者工具)
// 
// 目前主要是给开发者提供云端数据存储功能
//
@interface YouMiDataCenter : NSObject

// 共享单实例
// 
+ (id)sharedDataCenter;

// 设置当前数据操作的作用域
// 
// 详解:
//     作用域类似数据库的数据库名称，当你设置该值之后，你后面操作的所有数据都会作用于该作用域
//
- (void)selectDomain:(NSString *)domainName;
- (NSString *)currentDomain;

// 存储数据
// 
// 方式:
//     异步操作
// 详解:
//     通过该系列方法你可以把本地的数据存储到远程数据中心
// 补充:
//     当你有很多数据需要保存的时候，推荐使用setObjects:forKeys:因为这样可以节省流量
//
// 注意:
//     Object只能是NSNumber,NSString,NSArray,NSDictionary。
//     其中NSArray和NSDictionary包含的值只能是NSNumber,NSString,NSArray,NSDictionary等，
//     递归最终的值只能是NSNumber和NSString
// 
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (void)setFloat:(float)value forKey:(NSString *)defaultName;
- (void)setDouble:(double)value forKey:(NSString *)defaultName;
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
- (void)setObject:(id)value forKey:(NSString *)defaultName; // object must be NSNumber, NSString, NSArray, NSDictionary
- (void)setObjects:(NSArray *)valueArray forKeys:(NSArray *)defaultNameArray;

// 读取数据(同步)
// 
// 方式:
//     同步操作
// 详解:
//     读取远程数据中心的数据键值
// 补充:
//     - (NSDictionary *)objectsForKeys:(NSArray *)defaultNameArray方法返回的是键值对
// 
- (NSInteger)integerForKey:(NSString *)defaultName;
- (float)floatForKey:(NSString *)defaultName;
- (double)doubleForKey:(NSString *)defaultName;
- (BOOL)boolForKey:(NSString *)defaultName;
- (id)objectForKey:(NSString *)defaultName;
- (NSDictionary *)objectsForKeys:(NSArray *)defaultNameArray;

// 读取数据(异步)
// 
// 方式:
//     异步操作
// 详解:
//     该操作和同步读取数据操作类似，主要是采用异步的方式，防止阻塞当前线程
//     如果操作成功，则error为nil,否则error指示错误信息
// 推荐:
//     Block用法:http://developer.apple.com/library/ios/#documentation/cocoa/Conceptual/Blocks/Articles/00_Introduction.html
//     Block中文文档:http://www.cocoachina.com/bbs/read.php?tid=87593
// 
- (void)fetchAsyncIntegerForKey:(NSString *)defaultName withCompletion:(void (^)(NSError *error, NSInteger value))completion;
- (void)fetchAsyncFloatForKey:(NSString *)defaultName withCompletion:(void (^)(NSError *error, float value))completion;
- (void)fetchAsyncDoubleForKey:(NSString *)defaultName withCompletion:(void (^)(NSError *error, double value))completion;
- (void)fetchAsyncBoolForKey:(NSString *)defaultName withCompletion:(void (^)(NSError *error, BOOL value))completion;
- (void)fetchAsyncObjectForKey:(NSString *)defaultName withCompletion:(void (^)(NSError *error, id value))completion;
- (void)fetchAsyncObjectsForKeys:(NSArray *)defaultNameArray withCompletion:(void (^)(NSError *error, NSDictionary *valueDic))completion;


// 递增操作
// 
// 方式:
//     异步操作
// 详解:
//     对应值为NSNumber的数据(包括之前存储的int,float,double,bool等)，你可以递增该数据的值
//     如果执行递增操作后想查看新值，推荐使用increaseKey:byAmount:withCompletion:
// 补充:
//     若希望执行递减操作，可以给参数传递负数即可，比如[NSNumber numberWithInt:-18]
// 
- (void)increaseKey:(NSString *)defaultName byAmount:(NSNumber *)amount;
- (void)increaseKey:(NSString *)defaultName byAmount:(NSNumber *)amount withCompletion:(void (^)(NSError *error, NSNumber *newValue))completion;

// 删除键值
//
// 方式:
//     异步操作
// 详解:
//     执行对远程数据库数据的删除操作
// 补充:
//     当需要批量删除数据的时候，可以使用removeObjectsForKeys:
// 
- (void)removeObjectForKey:(NSString *)defaultName;
- (void)removeObjectsForKeys:(NSArray *)defaultNameArray;

@end
