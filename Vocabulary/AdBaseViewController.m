//
//  AdBaseViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-11-4.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "AdBaseViewController.h"

@interface AdBaseViewController ()

@end

@implementation AdBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    self.banner = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
    self.banner.adUnitID = @"75ec8a2a75764c0e";
    self.banner.rootViewController = self;
    self.banner.delegate = self;
    [self.banner loadRequest:[GADRequest request]];
}

- (void)viewWillAppear:(BOOL)animated
{
    BOOL shouldAddToView = YES;
    for (UIView *view in self.view.subviews) {
        if (view == self.banner) {
            shouldAddToView = NO;
            break;
        }
    }
    if (shouldAddToView) {
        [self.view addSubview:self.banner];
        self.banner.frame = self.bannerFrame;
    }
    CGPoint bannerCenter = self.banner.center;
    bannerCenter.x = self.view.bounds.size.width/2;
    self.banner.center = bannerCenter;
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.banner.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    NSLog(@"receive ad succeed");
    
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"%@",error);
}

@end
