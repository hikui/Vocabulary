//
//  VNavigationViewController.m
//  Vocabulary
//
//  Created by 缪 和光 on 13-1-4.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "VNavigationController.h"
#import "PureColorImageGenerator.h"

@implementation VNavigationController

+ (UIBarButtonItem *)generateBackItemWithTarget:(id)target action:(SEL)action
{
    return [VNavigationController generateItemWithType:VNavItemTypeBack target:target action:action];
}

+ (UIBarButtonItem *)generateSearchItemWithTarget:(id)target action:(SEL)action
{
    return [VNavigationController generateItemWithType:VNavItemTypeSearch target:target action:action];
}

+ (UIBarButtonItem *)generateNoteItemWithTarget:(id)target action:(SEL)action
{
//    return [[UIBarButtonItem alloc]initVNavBarButtonItemWithTitle:@"笔记" target:target action:action];
    UIImage *noteIcon = [UIImage imageNamed:@"NoteIcon"];
    return [[UIBarButtonItem alloc]initVNavBarButtonItemWithImage:noteIcon target:target action:action];
}

+ (UIBarButtonItem *)generateItemWithType:(VNavItemType)type
                                   target:(id)target
                                   action:(SEL)action
{
//    NSArray *buttonImageNames = @[@"search.png",@"refresh.png"];
    
    if (type == VNavItemTypeBack) {
        static UIImage *backImage = nil;
        if (backImage == nil) {
//            backImage = [PureColorImageGenerator generateBackButtonImageWithTint:RGBA(255, 255, 255, 0.9)];
            backImage = [UIImage imageNamed:@"BackIcon"];
        }
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 43, 30)];
        [btn setImage:backImage forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
        return item;
    }else{
        static UIImage *refreshImage = nil;
        if (refreshImage == nil) {
//            refreshImage = [PureColorImageGenerator generateRefreshImageWithTint:RGBA(255, 255, 255, 0.9)];
            refreshImage = [UIImage imageNamed:@"RefreshIcon"];
        }
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 43, 30)];
        UIImage *buttonImage = refreshImage;
        [btn setImage:buttonImage forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
        return item;
    }
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self.navigationBar setBackgroundImage:([[UIImage imageNamed:@"nav.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0])
                         forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.tintColor = [UIColor whiteColor];
}

@end

@implementation UIBarButtonItem(VNavigationController)

- (instancetype)initVNavBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [btn sizeToFit];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:btn];
    return self;
}

- (instancetype)initVNavBarButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:btn];
    return self;
}

@end
