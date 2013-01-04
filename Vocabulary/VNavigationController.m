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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationBar *aNavigationBar = self.navigationBar;
        if ([aNavigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
        {
            [aNavigationBar setBackgroundImage:([[UIImage imageNamed:@"navBg.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0])
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
            [aNavigationBar setBackgroundImage:([[UIImage imageNamed:@"navBg.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0])
                                 forBarMetrics:UIBarMetricsDefault];
        }
    }
    return self;
}

@end
