//
//  AdBaseViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-11-4.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "AdBaseViewController.h"
#import "GADAdMobExtras.h"

@interface AdBaseViewController ()

- (NSString *)hexStringWithRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue;

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
//    self.banner = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
//    self.banner.adUnitID = @"75ec8a2a75764c0e";
//    self.banner.rootViewController = self;
//    self.banner.delegate = self;
//    GADRequest *request = [GADRequest request];
//    GADAdMobExtras *extras = [[GADAdMobExtras alloc] init] ;
//    extras.additionalParameters =
//    [NSMutableDictionary dictionaryWithObjectsAndKeys:
//     [self hexStringWithRed:141 green:198 blue:65], @"color_bg",
//     [self hexStringWithRed:141 green:198 blue:65], @"color_bg_top",
//     [self hexStringWithRed:141 green:198 blue:65], @"color_border",
//     [self hexStringWithRed:88 green:87 blue:92], @"color_link",
//     [self hexStringWithRed:255 green:255 blue:255], @"color_text",
//     [self hexStringWithRed:88 green:87 blue:92], @"color_url",
//     nil];
//    
//    [request registerAdNetworkExtras:extras];
//    [self.banner loadRequest:request];
//    NSLog(@"hex:%@",[self hexStringWithRed:244 green:233 blue:215]);
    
    if (ShowAds) {
        [YouMiView setShouldGetLocation:NO];
        self.banner = [[YouMiView alloc]initWithContentSizeIdentifier:YouMiBannerContentSizeIdentifier320x50 delegate:self];
        self.banner.appID = @"d3ff59c20eec9ef5";
        self.banner.appSecret = @"a7b790693ba72b85";
        self.banner.appVersion = @"1.2.3";
        self.banner.indicateBackgroundColor = RGBA(246, 255, 222, 1);
        self.banner.indicateRounded = NO;
        self.banner.indicateBorder = NO;
        self.banner.indicateTranslucency = NO;
        self.banner.textColor = [UIColor blackColor];
        self.banner.subTextColor = RGBA(66, 66, 66, 1);
        [self.banner addKeyword:@"雅思"];
        [self.banner addKeyword:@"托福"];
        [self.banner addKeyword:@"GRE"];
        [self.banner addKeyword:@"留学"];
        self.banner.testing = NO;
    }
    
    
//    [self.banner start];
//    [self.view addSubview:self.banner];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (ShowAds) {
        [self.banner start];
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

- (NSString *)hexStringWithRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue
{
    NSString *str = [[NSString stringWithFormat:@"%02x%02x%02x",red,green,blue] capitalizedString];
    return str;
}

#pragma - mark youmi delegate
- (void)didReceiveAd:(YouMiView *)adView
{
    self.banner.frame = self.bannerFrame;
    self.banner.hidden = NO;
    NSLog(@"receive ad succeed");
}

- (void)didFailToReceiveAd:(YouMiView *)adView  error:(NSError *)error
{
    self.banner.frame = self.bannerFrame;
    self.banner.hidden = YES;
    NSLog(@"%@",error);
}

@end
