//
//  VBaseViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 13-10-26.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "VBaseViewController.h"
#import "VNavigationController.h"

@interface VBaseViewController ()

@end

@implementation VBaseViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (GRATER_THAN_IOS_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCustomBackButton {
    UIBarButtonItem *backButton = [VNavigationController generateBackItemWithTarget:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)back {
    [[HKVNavigationManager sharedInstance]commonPopAnimated:YES];
}

@end
