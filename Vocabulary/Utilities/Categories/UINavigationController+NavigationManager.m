//
//  UINavigationController+NavigationManager.m
//  Vocabulary
//
//  Created by Heguang Miao on 1/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import "UINavigationController+NavigationManager.h"
#import <objc/runtime.h>
#import "VWebViewController.h"

static char AssociatedNavigationManagerKey;

@implementation UINavigationController (NavigationManager)

- (HKVNavigationManager *)v_navigationManager {
    HKVNavigationManager * manager = objc_getAssociatedObject(self, &AssociatedNavigationManagerKey);
    if (manager == nil) {
        manager = [[HKVNavigationManager alloc]init];
        manager.navigationController = self;
        manager.onMatchFailureBlock = ^UIViewController * (HKVNavigationActionCommand * command)
        {
            VWebViewController* webViewController = [[VWebViewController alloc] initWithNibName:nil bundle:nil];
            webViewController.requestURL = command.targetURL;
            return webViewController;
        };
        
        objc_setAssociatedObject(self, &AssociatedNavigationManagerKey, manager, OBJC_ASSOCIATION_RETAIN);
    }
    return manager;
}

@end
