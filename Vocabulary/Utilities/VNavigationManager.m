//
//  VNavigationManager.m
//  Vocabulary
//
//  Created by 缪和光 on 12/22/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "VNavigationManager.h"
#import "VWebViewController.h"

@implementation VNavigationActionCommand @end

@interface VNavigationManager ()

@property (nonatomic, copy) NSDictionary *routes;
@property (nonatomic, strong) NSMutableArray *commandQueue;
@property (nonatomic, assign) BOOL isPerformingNavigationAction;

@end

@implementation VNavigationManager

+ (instancetype)sharedInstance {
    static VNavigationManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[VNavigationManager alloc]init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _commandQueue = [[NSMutableArray alloc]init];
        _isPerformingNavigationAction = NO;
    }
    return self;
}

- (void)configRoute:(NSDictionary* (^)(void))routeConfigBlock {
    if (!routeConfigBlock) {
        return;
    }
    
    NSDictionary *routes = routeConfigBlock();
    NSMutableDictionary *validRoutes = [[NSMutableDictionary alloc]initWithCapacity:routes.count];
    [routes enumerateKeysAndObjectsUsingBlock:^(NSURL *key, NSDictionary *obj, BOOL *stop) {
        if (![key isKindOfClass:[NSURL class]] || ![obj isKindOfClass:[NSDictionary class]]) {
            // 确保类型正确
            return;
        }
        [validRoutes setObject:obj forKey:obj];
    }];
    
    self.routes = routes;
    
}
- (void)executeCommand:(VNavigationActionCommand *)command {
    [self.commandQueue addObject:command];
    
    // 只有当现在的navigation不处于push或者pop动画时才执行command
    if (!self.isPerformingNavigationAction) {
        [self executeNextCommand];
    }
}

- (void)executeNextCommand {
    VNavigationActionCommand *nextCommand = [self.commandQueue firstObject];
    if (!nextCommand) {
        return;
    }
    switch (nextCommand.actionType) {
        case VNavigationActionTypePush:
            [self _doPush:nextCommand];
            break;
        case VNavigationActionTypePop:
            [self _doPop:nextCommand];
            break;
        case VNavigationActionTypePresentModal:
            [self _doPresentModal:nextCommand];
            break;
        case VNavigationActionTypeResetRoot:
            [self _doResetRoot:nextCommand];
            break;
        default:
            break;
    }
}

- (void)_doPush:(VNavigationActionCommand *)command {
    UIViewController *controller = [self _assembleViewControllerWithCommand:command];
    if (command.popTopBeforePush) {
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        if (viewControllers.count > 0) {
            [viewControllers removeLastObject];
        }
        [viewControllers addObject:controller];
        [self.navigationController setViewControllers:viewControllers animated:command.animate];
    }else{
        [self.navigationController pushViewController:controller animated:command.animate];
    }
}

- (void)_doPop:(VNavigationActionCommand *)command {
    // 如果command有targetURL，则尝试执行popToViewController
    // 如果在当前栈里找不到targetURL所属的类型，则转发到_doPush，并将popTopBeforePush设为YES
    if (command.targetURL) {
        NSDictionary *configForURL = self.routes[command.targetURL];
        NSString *classString = configForURL[VNavigationConfigClassNameKey];
        Class controllerClass = nil;
        if (classString) {
            controllerClass = NSClassFromString(classString);
        }
        if (!controllerClass) {
            // 默认值
            controllerClass = [VWebViewController class];
        }
        NSArray *controllersInStack = self.navigationController.viewControllers;
        UIViewController *targetViewController = nil;
        for (NSUInteger i = controllersInStack.count - 1; i > 0; i--) {
            // 从栈顶往下搜索
            UIViewController *aViewController = controllersInStack[i];
            if ([aViewController isKindOfClass:controllerClass]) {
                targetViewController = aViewController;
                break;
            }
        }
        if (targetViewController) {
            [self.navigationController popToViewController:targetViewController animated:command.animate];
        }else{
            // 在栈中找不到需要的view controller
            // 转发command到push
            command.actionType = VNavigationActionTypePush;
            command.popTopBeforePush = YES;
            [self _doPush:command];
        }
    } else {
        [self.navigationController popViewControllerAnimated:command.animate];
    }
    
}

- (void)_doPresentModal:(VNavigationActionCommand *)command {
    UIViewController *controller = [self _assembleViewControllerWithCommand:command];
    [self.navigationController presentViewController:controller animated:command.animate completion:nil];
}

- (void)_doResetRoot:(VNavigationActionCommand *)command {
    UIViewController *controller = [self _assembleViewControllerWithCommand:command];
    [self.navigationController setViewControllers:@[controller] animated:command.animate];
}

- (UIViewController *)_assembleViewControllerWithCommand:(VNavigationActionCommand *)command {
    NSURL *url = command.targetURL;
    NSDictionary *configForURL = self.routes[url];
    BOOL match = NO;
    UIViewController *controller = [self _viewControllerFromConfigValue:configForURL outMatch:&match];
    if (!match) {
        NSAssert([controller isKindOfClass:[VWebViewController class]], @"If no match view controller is found, should return a VWebViewController instance.");
        ((VWebViewController *)controller).requestURL = url;
    }else{
        [self _injectParams:command.params toViewController:controller];
    }
    return controller;
}

- (UIViewController *)_viewControllerFromConfigValue:(NSDictionary *)configValue outMatch:(BOOL *)match{
    if (match) {
        *match = YES;
    }
    NSString *className = configValue[VNavigationConfigClassNameKey];
    NSString *xibName = configValue[VNavigationConfigXibNameKey];
    // 如果找不到对应的class，则直接生成WebViewController
    Class controllerClass = NSClassFromString(className);
    if (!controllerClass) {
        if (match) {
            *match = NO;
        }
        controllerClass = [VWebViewController class];
        xibName = (NSString *)[NSNull null];
    }
    
    UIViewController *controller = nil;
    if (xibName) {
        if ([xibName isEqual:[NSNull null]]) { // 如果是NSNull，则使用initWithNibName初始化方法，但参数是nil
            xibName = nil;
        }
        controller = [[controllerClass alloc]initWithNibName:xibName bundle:nil];
    }else{
        controller = [[controllerClass alloc]init];
    }
    
    return controller;
}

- (void)_injectParams:(NSDictionary *)params toViewController:(UIViewController *)viewController {
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]]) {
            return;
        }
        if (![viewController respondsToSelector:NSSelectorFromString(key)]) {
            return;
        }
        [viewController setValue:obj forKey:key];
    }];
}

- (void)setNavigationController:(UINavigationController *)navigationController {
    _navigationController = navigationController;
    navigationController.delegate = self;
}

#pragma mark - navigation controller delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isPerformingNavigationAction = YES;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isPerformingNavigationAction = NO;
    [self executeNextCommand];
}


@end
