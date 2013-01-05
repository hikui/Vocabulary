//
//  VNavigationViewController.m
//  Vocabulary
//
//  Created by 缪 和光 on 13-1-4.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "VNavigationController.h"
#import "AppDelegate.h"
#import "IIViewDeckController.h"

@implementation VNavigationController

+ (UIBarButtonItem *)generateBackItemWithTarget:(id)target action:(SEL)action
{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 42, 29)];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    return item;
}

+ (UIBarButtonItem *)generateSearchItemWithTarget:(id)target action:(SEL)action
{
    UIImage *buttonBgImage = [[UIImage imageNamed:@"barbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 42, 29)];
    [btn setBackgroundImage:buttonBgImage forState:UIControlStateNormal];
    UIImage *buttonImage = [UIImage imageNamed:@"search.png"];
    [btn setImage:buttonImage forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    return item;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationBar *aNavigationBar = self.navigationBar;
        if ([aNavigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
        {
            [aNavigationBar setBackgroundImage:([[UIImage imageNamed:@"nav.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0])
                                 forBarMetrics:UIBarMetricsDefault];
        }
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        UINavigationBar *aNavigationBar = self.navigationBar;
        if ([aNavigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
        {
            [aNavigationBar setBackgroundImage:([[UIImage imageNamed:@"nav.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0])
                                 forBarMetrics:UIBarMetricsDefault];
        }
    }
    return self;
}

@end

@implementation UIBarButtonItem(VNavigationController)

- (id)initVNavBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
{
    UIImage *buttonBgImage = [[UIImage imageNamed:@"barbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:buttonBgImage forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [btn sizeToFit];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:btn];
    return self;
}

- (id)initVNavBarButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    UIImage *buttonBgImage = [[UIImage imageNamed:@"barbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:buttonBgImage forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:btn];
    return self;
}

@end
