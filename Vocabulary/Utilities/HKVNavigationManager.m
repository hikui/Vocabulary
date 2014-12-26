//
//  HKVNavigationManager.m
//  Vocabulary
//
//  Created by 缪和光 on 12/22/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "HKVNavigationManager.h"

NSString* const HKVNavigationConfigClassNameKey =
    @"HKVNavigationConfigClassNameKey";
NSString* const HKVNavigationConfigXibNameKey = @"HKVNavigationConfigXibNameKey";

@implementation HKVNavigationActionCommand

- (id)copyWithZone:(NSZone*)zone
{
    HKVNavigationActionCommand* copyCommand =
        [[HKVNavigationActionCommand allocWithZone:zone] init];
    copyCommand.actionType = self.actionType;
    copyCommand.targetURL = [self.targetURL copy];
    copyCommand.animate = self.animate;
    copyCommand.params = [self.params copy];
    copyCommand.popTopBeforePush = self.popTopBeforePush;
    return copyCommand;
}

@end

@interface HKVNavigationManager ()

@property (nonatomic, copy) NSDictionary* routes;
@property (nonatomic, strong) NSMutableArray* commandQueue;

@end

@implementation HKVNavigationManager

+ (instancetype)sharedInstance
{
    static HKVNavigationManager* sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{ sharedManager = [[HKVNavigationManager alloc] init]; });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _commandQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)configRoute:(NSDictionary* (^)(void))routeConfigBlock
{
    if (!routeConfigBlock) {
        return;
    }

    NSDictionary* routes = routeConfigBlock();
    NSMutableDictionary* validRoutes =
        [[NSMutableDictionary alloc] initWithCapacity:routes.count];
    [routes enumerateKeysAndObjectsUsingBlock:^(NSURL* key,
                                                NSDictionary* obj,
                                                BOOL* stop) {
      if (![key isKindOfClass:[NSURL class]] ||
          ![obj isKindOfClass:[NSDictionary class]]) {
        // 确保类型正确
        return;
      }
        NSURL *urlWithoutPrams = [[NSURL alloc]initWithScheme:key.scheme host:key.host path:key.path];
      [validRoutes setObject:obj forKey:urlWithoutPrams];
    }];

    self.routes = routes;
}

- (void)executeCommand:(HKVNavigationActionCommand*)command
{
    [self.commandQueue addObject:command];

    if (self.commandQueue.count == 1) {
        [self _executeNextCommand];
    }
}

- (void)commonPopAnimated:(BOOL)animate
{
    [self commonPopToURL:nil animate:animate];
}

- (void)commonPopToURL:(NSURL*)url animate:(BOOL)animate
{
    HKVNavigationActionCommand* command = [HKVNavigationActionCommand new];
    command.actionType = HKVNavigationActionTypePop;
    command.animate = animate;
    command.targetURL = url;
    [self executeCommand:command];
}

- (void)commonPushURL:(NSURL*)url
               params:(NSDictionary*)params
              animate:(BOOL)animate
{
    HKVNavigationActionCommand* command = [HKVNavigationActionCommand new];
    command.actionType = HKVNavigationActionTypePush;
    command.animate = animate;
    command.targetURL = url;
    command.params = params;
    [self executeCommand:command];
}

- (void)commonResetRootURL:(NSURL*)url params:(NSDictionary*)params
{
    HKVNavigationActionCommand* command = [HKVNavigationActionCommand new];
    command.actionType = HKVNavigationActionTypeResetRoot;
    command.targetURL = url;
    command.params = params;
    [self executeCommand:command];
}

- (void)commonPresentModalURL:(NSURL*)url
                       params:(NSDictionary*)params
                      animate:(BOOL)animate
{
    HKVNavigationActionCommand* command = [HKVNavigationActionCommand new];
    command.actionType = HKVNavigationActionTypePresentModal;
    command.targetURL = url;
    command.params = params;
    command.animate = animate;
    [self executeCommand:command];
}

- (void)commonDismissModalAnimated:(BOOL)animate
{
    HKVNavigationActionCommand* command = [HKVNavigationActionCommand new];
    command.actionType = HKVNavigationActionTypeDismissModal;
    command.animate = animate;
    [self executeCommand:command];
}

- (void)_executeNextCommand
{
    HKVNavigationActionCommand* nextCommand = [self.commandQueue firstObject];
    switch (nextCommand.actionType) {
    case HKVNavigationActionTypePush:
        [self _doPush:nextCommand];
        break;
    case HKVNavigationActionTypePop:
        [self _doPop:nextCommand];
        break;
    case HKVNavigationActionTypePresentModal:
        [self _doPresentModal:nextCommand];
        break;
    case HKVNavigationActionTypeResetRoot:
        [self _doResetRoot:nextCommand];
        break;
    case HKVNavigationActionTypeDismissModal:
        [self _doDismissModal:nextCommand];
        break;
    default:
        break;
    }
}

- (void)_doPush:(HKVNavigationActionCommand*)command
{
    UIViewController* controller =
        [self _assembleViewControllerWithCommand:command];
    if (controller == nil) {
        [self _dequeueAndJudgeNextStep];
        return;
    }
    if (command.popTopBeforePush) {
        NSMutableArray* viewControllers = [NSMutableArray
            arrayWithArray:self.navigationController.viewControllers];
        if (viewControllers.count > 0) {
            [viewControllers removeLastObject];
        }
        [viewControllers addObject:controller];
        [self.navigationController setViewControllers:viewControllers
                                             animated:command.animate];
    }
    else {
        [self.navigationController pushViewController:controller
                                             animated:command.animate];
    }
}

- (void)_doPop:(HKVNavigationActionCommand*)command
{
    // 如果command有targetURL，则尝试执行popToViewController
    // 如果在当前栈里找不到targetURL所属的类型，则转发到_doPush，并将popTopBeforePush设为YES
    if (command.targetURL) {
        NSDictionary* configForURL = self.routes[command.targetURL];
        NSString* classString = configForURL[HKVNavigationConfigClassNameKey];
        Class controllerClass = nil;
        if (classString) {
            controllerClass = NSClassFromString(classString);
        }
        if (!controllerClass) {
            // 未注册的URL，回调查询
            if (self.onMatchFailureBlock) {
                UIViewController* defaultController = self.onMatchFailureBlock(command);
                if (defaultController) {
                    controllerClass =
                        [defaultController class]; // 这里需要找到class，因为controller
                    // stacks中不会存在这个实例，只会存在该实例所属的class的另外一个实例
                }
                else {
                    // 实在找不到，直接删除当前的command
                    [self _dequeueAndJudgeNextStep];
                    return;
                }
            }
        }
        NSArray* controllersInStack = self.navigationController.viewControllers;
        UIViewController* targetViewController = nil;
        for (NSUInteger i = controllersInStack.count - 1; i > 0; i--) {
            // 从栈顶往下搜索
            UIViewController* aViewController = controllersInStack[i];
            // 注意这里要使用isMemberOfClass，避免子类view controller和父类view
            // controller混淆
            if ([aViewController isMemberOfClass:controllerClass]) {
                targetViewController = aViewController;
                break;
            }
        }
        if (targetViewController) {
            [self.navigationController popToViewController:targetViewController
                                                  animated:command.animate];
        }
        else {
            // 在栈中找不到需要的view controller
            // 转发command到push
            command.actionType = HKVNavigationActionTypePush;
            command.popTopBeforePush = YES;
            [self _doPush:command];
        }
    }
    else {
        if (self.navigationController.viewControllers.count == 1) {
            // 最后一个view
            // controller，pop操作会无效化，不会进delegate方法，这里直接删除queue中的东西
            [self _dequeueAndJudgeNextStep];
        }
        else {
            [self.navigationController popViewControllerAnimated:command.animate];
        }
    }
}

- (void)_doPresentModal:(HKVNavigationActionCommand*)command
{
    UIViewController* controller =
        [self _assembleViewControllerWithCommand:command];
    if (controller == nil) {
        [self _dequeueAndJudgeNextStep];
        return;
    }
    [self.navigationController
        presentViewController:controller
                     animated:command.animate
                   completion:^{ [self _dequeueAndJudgeNextStep]; }];
}

- (void)_doDismissModal:(HKVNavigationActionCommand*)command
{
    [self.navigationController
        dismissViewControllerAnimated:command.animate
                           completion:^{ [self _dequeueAndJudgeNextStep]; }];
}

- (void)_doResetRoot:(HKVNavigationActionCommand*)command
{
    UIViewController* controller =
        [self _assembleViewControllerWithCommand:command];
    if (controller == nil) {
        [self _dequeueAndJudgeNextStep];
    }
    [self.navigationController setViewControllers:@[ controller ]
                                         animated:command.animate];
}

- (UIViewController*)_assembleViewControllerWithCommand:
                         (HKVNavigationActionCommand*)command
{
    NSURL* url = command.targetURL;
    NSURL* urlWithoutParams = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
    NSDictionary* configForURL = self.routes[urlWithoutParams];
    UIViewController* controller =
        [self _viewControllerFromConfigValue:configForURL];
    if (!controller) {
        if (self.onMatchFailureBlock) {
            controller = self.onMatchFailureBlock(command);
        }
    }
    else {
        [self _injectParams:command.params toViewController:controller];
    }
    return controller;
}

- (UIViewController*)_viewControllerFromConfigValue:(NSDictionary*)configValue
{
    NSString* className = configValue[HKVNavigationConfigClassNameKey];
    NSString* xibName = configValue[HKVNavigationConfigXibNameKey];
    // 如果找不到对应的class，则直接生成WebViewController
    Class controllerClass = NSClassFromString(className);
    if (!controllerClass) {
        return nil;
    }

    UIViewController* controller = nil;
    if (xibName) {
        if ([xibName
                isEqual:
                    [NSNull null]]) { // 如果是NSNull，则使用initWithNibName初始化方法，但参数是nil
            xibName = nil;
        }
        controller = [[controllerClass alloc] initWithNibName:xibName bundle:nil];
    }
    else {
        controller = [[controllerClass alloc] init];
    }

    return controller;
}

- (void)_injectParams:(NSDictionary*)params
     toViewController:(UIViewController*)viewController
{
    [params
        enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL* stop) {
          if (![key isKindOfClass:[NSString class]]) {
            return;
          }
          if (![viewController respondsToSelector:NSSelectorFromString(key)]) {
            return;
          }
          [viewController setValue:obj forKey:key];
        }];
}

- (void)setNavigationController:(UINavigationController*)navigationController
{
    _navigationController = navigationController;
    navigationController.delegate = self;
    //当navigationController变换时，清空当前的commandQueue
    [self.commandQueue removeAllObjects];
}

- (void)_dequeueAndJudgeNextStep
{
    if (self.commandQueue.count > 0) {
        [self.commandQueue removeObjectAtIndex:0];
    }
    if (self.commandQueue.count > 0) {
        [self _executeNextCommand];
    }
}

#pragma mark - navigation controller delegate
- (void)navigationController:(UINavigationController*)navigationController
      willShowViewController:(UIViewController*)viewController
                    animated:(BOOL)animated
{
}

- (void)navigationController:(UINavigationController*)navigationController
       didShowViewController:(UIViewController*)viewController
                    animated:(BOOL)animated
{
    [self _dequeueAndJudgeNextStep];
}

@end
