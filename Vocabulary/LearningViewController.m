
/*
 *  This file is part of 记词助手.
 *
 *	记词助手 is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License Version 2 as 
 *  published by the Free Software Foundation.
 *
 *	记词助手 is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with 记词助手.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  LearningViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-21.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "LearningViewController.h"
#import "CoreDataHelper.h"
#import "MBProgressHUD.h"
#import "CibaEngine.h"
#import "CibaWebView.h"

@interface LearningViewController ()

@end

@implementation LearningViewController

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
    if (_shouldHideInfo) {
        self.acceptationTextView.hidden = YES;
    }else{
        self.acceptationTextView.hidden = NO;
    }
    UIView *content = [self.view viewWithTag:1];
    self.view.backgroundColor = RGBA(246, 255, 222, 1);
    content.backgroundColor = RGBA(246, 255, 222, 1);
    //广告
    if (ShowAds) {
        UIView *content = [self.view viewWithTag:1];
        CGRect targetFrame = CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height-50);
        content.frame = targetFrame;
        self.banner.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view bringSubviewToFront:self.banner];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.bannerFrame = CGRectMake(0, 0, self.view.bounds.size.width, 50);
    [super viewWillAppear:animated];
    [self refreshView];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    NSLog(@"view will disappear");
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    [self.downloadOp cancel];
//    [self.voiceOp cancel];
//    self.downloadOp = nil;
//    self.voiceOp = nil;
//    [self.player stop];
    
    [[CibaEngine sharedInstance]cancelOperationOfWord:self.word];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.acceptationTextView.text = @"";
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[CibaWebView class]]) {
            [view removeFromSuperview];
            break;
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithWord:(Word *)word
{
    self = [super initWithNibName:@"LearningViewController" bundle:nil];
    if (self) {
        _word = word;
        _shouldHideInfo = NO;
    }
    return self;
}



- (void)refreshView
{
    self.lblKey.text = self.word.key;
    [self.lblKey sizeToFit];
    if (self.word.hasGotDataFromAPI) {
        NSMutableString *confusingWordsStr = [[NSMutableString alloc]init];
        for (Word *aConfusingWord in self.word.similarWords) {
            [confusingWordsStr appendFormat:@"%@ ",aConfusingWord.key];
        }
        NSString *jointStr = nil;
        if (self.word.similarWords.count == 0) {
            jointStr = [NSString stringWithFormat:@"英[%@] 美[%@]\n%@%@",self.word.psEN,self.word.psUS,self.word.acceptation,self.word.sentences];
        }else{
            jointStr = [NSString stringWithFormat:@"英[%@] 美[%@]\n\n易混淆单词: %@\n\n%@%@",self.word.psEN,self.word.psUS,confusingWordsStr,self.word.acceptation,self.word.sentences];
        }
        
       
        self.acceptationTextView.text = jointStr;
        BOOL shouldPerformSound = [[NSUserDefaults standardUserDefaults]boolForKey:kPerformSoundAutomatically];
        self.player = [[AVAudioPlayer alloc]initWithData:self.word.pronunciation.pronData error:nil];
        [self.player prepareToPlay];
        if (shouldPerformSound) {
            [self.player play];
        }
    }else{
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        if ([reachability currentReachabilityStatus] == NotReachable) {
            self.acceptationTextView.text = @"无网络连接，首次访问需要通过网络。";
            return;
        }
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        CibaEngine *engine = [CibaEngine sharedInstance];
        [engine fillWord:self.word onCompletion:^{
            [hud hide:YES];
            [self refreshView];
        } onError:^(NSError *error) {
            if ([error.domain isEqualToString:CibaEngineDormain] && error.code == FillWordPronError) {
                hud.detailsLabelText = @"语音加载失败";
                [hud hide:YES afterDelay:1.5];
                [self refreshView];
            }else{
                hud.detailsLabelText = @"词义加载失败";
                [hud hide:YES afterDelay:1.5];
            }
        }];

    }
}
- (IBAction)btnReadOnPressed:(id)sender
{
    if (self.player != nil) {
        [self.player play];
    }
}

- (IBAction)fullInfomation:(id)sender
{
//    UIButton *btn = (UIButton *)sender;
    CibaWebView *webView = [[CibaWebView alloc]initWithView:self.view word:self.word.key];
//    webView.animationBeginPoint = btn.center;
    [webView showCibaWebViewAnimated:YES];
}

- (void)showInfo
{
    self.shouldHideInfo = NO;
    self.acceptationTextView.hidden = NO;
}

- (void)hideInfo
{
    self.shouldHideInfo = YES;
    self.acceptationTextView.hidden = YES;
}

//#pragma - mark GADBannerViewDelegate
//- (void)adViewDidReceiveAd:(GADBannerView *)view
//{
//    [super adViewDidReceiveAd:view];
//    [UIView animateWithDuration:0.5 animations:^{
//        UIView *content = [self.view viewWithTag:1];
//        CGRect targetFrame = CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height-50);
//        content.frame = targetFrame;
//        self.banner.transform = CGAffineTransformMakeTranslation(0, 50);
//    }];
//}
//
//- (void)adView:(GADBannerView *)view
//didFailToReceiveAdWithError:(GADRequestError *)error
//{
//    [super adView:view didFailToReceiveAdWithError:error];
//    [UIView animateWithDuration:0.5 animations:^{
//        UIView *content = [self.view viewWithTag:1];
//        CGRect targetFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//        content.frame = targetFrame;
//        self.banner.transform = CGAffineTransformMakeTranslation(0, 0);
//    }];
//}

//#pragma - mark youmi delegate
//- (void)didReceiveAd:(YouMiView *)adView
//{
//    [super didReceiveAd:adView];
//    [UIView animateWithDuration:0.5 animations:^{
//        UIView *content = [self.view viewWithTag:1];
//        CGRect targetFrame = CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height-50);
//        content.frame = targetFrame;
////        self.banner.transform = CGAffineTransformMakeTranslation(0, 50);
//        NSLog(@"banner frame:%@",[NSValue valueWithCGRect:self.banner.frame]);
//        NSLog(@"banner hidden:%d",self.banner.hidden);
//    }];
//}
////
//- (void)didFailToReceiveAd:(YouMiView *)adView  error:(NSError *)error
//{
//    [super didFailToReceiveAd:adView error:error];
//    [UIView animateWithDuration:0.5 animations:^{
//        UIView *content = [self.view viewWithTag:1];
//        CGRect targetFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//        content.frame = targetFrame;
//        self.banner.transform = CGAffineTransformMakeTranslation(0, 0);
//    }];
//}
@end
