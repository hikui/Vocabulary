//
//  VNavigationViewController.h
//  Vocabulary
//
//  Created by 缪 和光 on 13-1-4.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum VNavItemType : NSInteger {
    VNavItemTypeBack = -1,
    VNavItemTypeSearch = 0,
    VNavItemTypeRefresh = 1
}VNavItemType;

@interface VNavigationController : UINavigationController

+ (UIBarButtonItem *)generateBackItemWithTarget:(id)target action:(SEL)action;
+ (UIBarButtonItem *)generateSearchItemWithTarget:(id)target action:(SEL)action;
+ (UIBarButtonItem *)generateNoteItemWithTarget:(id)target action:(SEL)action;
+ (UIBarButtonItem *)generateItemWithType:(VNavItemType)type
                                   target:(id)target
                                   action:(SEL)action;

@end

@interface UIBarButtonItem(VNavigationController)

- (instancetype)initVNavBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (instancetype)initVNavBarButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;

@end
