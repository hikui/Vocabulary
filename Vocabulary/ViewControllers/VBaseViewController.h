//
//  VBaseViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 13-10-26.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VNavigationManager.h"
#import "VNavigationRouteConfig.h"
@interface VBaseViewController : UIViewController

/**
 显示自定义的返回按钮
 */
- (void)showCustomBackButton;

/**
 自定义返回（用于Navigation）
 */
- (void)back;

@end
