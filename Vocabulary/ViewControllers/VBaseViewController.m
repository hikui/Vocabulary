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

@property (nonatomic, strong) CALayer *maskLayer;

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
    _maskLayer = [CALayer layer];
    _maskLayer.frame = self.view.bounds;
    _maskLayer.backgroundColor = RGBA(0, 0, 0, 0.5).CGColor;
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

- (void)showMaskLayer {
    [self.view.layer addSublayer:_maskLayer];
}

- (void)hideMaskLayer {
    [_maskLayer removeFromSuperlayer];
}

- (void)back {
    [[HKVNavigationManager sharedInstance]commonPopAnimated:YES];
}

@end
