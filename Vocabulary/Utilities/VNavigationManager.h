//
//  VNavigationManager.h
//  Vocabulary
//
//  Created by 缪和光 on 12/22/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const VNavigationConfigClassNameKey;
extern NSString* const VNavigationConfigXibNameKey;

typedef NS_ENUM(NSInteger, VNavigationActionType) {
    VNavigationActionTypePush,
    VNavigationActionTypePop,
    VNavigationActionTypePresentModal,
    VNavigationActionTypeDismissModal,
    VNavigationActionTypeResetRoot
};

@interface VNavigationActionCommand : NSObject <NSCopying>

@property (nonatomic, assign) VNavigationActionType actionType;
@property (nonatomic, copy) NSURL* targetURL;

/**
 如果为true，将pop最顶层的view controller再push新的view controller
 当且仅当actionType == VNavigationActionTypePush时有效
 */
@property (nonatomic, assign) BOOL popTopBeforePush;

/**
 用于初始化view controller的参数，key为目标view controller的properties的名字
 value为需要注入的值。将会通过KVC注入。
 */
@property (nonatomic, copy) NSDictionary* params;

@property (nonatomic, assign) BOOL animate;

@end

@interface VNavigationManager : NSObject <UINavigationControllerDelegate>

@property (nonatomic, weak) UINavigationController* navigationController;

/**
 当URL匹配失败时，交给这个block处理
 command: 匹配失败的command
 block的实现应根据command中的URL，返回一个UIViewController。如果返回nil，则该command被忽略。
 */
@property (nonatomic, copy) UIViewController* (^onMatchFailureBlock)(VNavigationActionCommand* command);

+ (instancetype)sharedInstance;

/**
 配置路由
 
 @param routeConfigBlock 路由字典
    key为NSURL, value为ViewController的class name和xib name组成的子dict
 */
- (void)configRoute:(NSDictionary* (^)(void))routeConfigBlock;
- (void)executeCommand:(VNavigationActionCommand*)command;

/* 简便方法 */
- (void)commonPopAnimated:(BOOL)animate;
- (void)commonPopToURL:(NSURL*)url animate:(BOOL)animate;
- (void)commonPushURL:(NSURL*)url params:(NSDictionary*)params animate:(BOOL)animate;
- (void)commonResetRootURL:(NSURL*)url params:(NSDictionary*)params;
- (void)commonPresentModalURL:(NSURL*)url params:(NSDictionary*)params animate:(BOOL)animate;
- (void)commonDismissModalAnimated:(BOOL)animate;
@end
