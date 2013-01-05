//
//  VNavigationViewController.h
//  Vocabulary
//
//  Created by 缪 和光 on 13-1-4.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VNavigationController : UINavigationController

+ (UIBarButtonItem *)generateBackItemWithTarget:(id)target action:(SEL)action;
+ (UIBarButtonItem *)generateSearchItemWithTarget:(id)target action:(SEL)action;

@end

@interface UIBarButtonItem(VNavigationController)

- (id)initVNavBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (id)initVNavBarButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;

@end
