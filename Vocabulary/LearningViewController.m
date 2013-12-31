
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
#import "MBProgressHUD.h"
#import "CibaEngine.h"
#import "CibaWebView.h"
#import "NSMutableString+HTMLEscape.h"
#import "VNavigationController.h"
#import "VWebViewController.h"

#define CIBA_URL(__W__) [NSString stringWithFormat:@"http://wap.iciba.com/cword/%@", __W__]

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
    //广告
    if (ShowAds) {
        UIView *content = [self.view viewWithTag:1];
        CGRect targetFrame = CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height-50);
        content.frame = targetFrame;
        self.banner.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view bringSubviewToFront:self.banner];
    }
    
    UIBarButtonItem *backBtn = [VNavigationController generateBackItemWithTarget:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    UIBarButtonItem *refreshBtn = [VNavigationController generateItemWithType:VNavItemTypeRefresh target:self action:@selector(refreshWordData)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.bannerFrame = CGRectMake(0, 0, self.view.bounds.size.width, 50);
    [super viewWillAppear:animated];
    [self refreshView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];    
    [[CibaEngine sharedInstance]cancelOperationOfWord:self.word];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.acceptationTextView.text = @"";
    self.player = nil;
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
    
    CGSize labelSize = [self.word.key sizeWithFont:self.lblKey.font constrainedToSize:CGSizeMake(207, 999) lineBreakMode:NSLineBreakByClipping];
    CGRect labelFrame = self.lblKey.frame;
    labelFrame.size = labelSize;
    self.lblKey.frame = labelFrame;
    
    if (self.word.hasGotDataFromAPI) {
        NSMutableString *confusingWordsStr = [[NSMutableString alloc]init];
        for (Word *aConfusingWord in self.word.similarWords) {
            [confusingWordsStr appendFormat:@"%@ ",aConfusingWord.key];
        }
        NSMutableString *jointStr = nil;
        if (self.word.similarWords.count == 0) {
            jointStr = [[NSMutableString alloc]initWithFormat:@"英[%@]\n美[%@]\n%@%@",self.word.psEN,self.word.psUS,self.word.acceptation,self.word.sentences];
        }else{
            jointStr = [[NSMutableString alloc]initWithFormat:@"英[%@]\n美[%@]\n\n易混淆单词: %@\n\n%@%@",self.word.psEN,self.word.psUS,confusingWordsStr,self.word.acceptation,self.word.sentences];
        }
        
        [jointStr htmlUnescape];
        
        self.acceptationTextView.text = jointStr;
        CGRect textViewFrame = self.acceptationTextView.frame;
        textViewFrame.origin.y = labelFrame.origin.y+labelFrame.size.height+10.0f;
        self.acceptationTextView.frame = textViewFrame;
        
        self.player = [[AVAudioPlayer alloc]initWithData:self.word.pronunciation.pronData error:nil];
        [self.player prepareToPlay];
    }else{
        [self refreshWordData];

    }
}
- (IBAction)btnReadOnPressed:(id)sender
{
    [self playSound];
}

- (IBAction)fullInfomation:(id)sender
{
    VWebViewController *wvc = [[VWebViewController alloc]initWithNibName:@"VWebViewController" bundle:nil];
    NSURL *url = [NSURL URLWithString:CIBA_URL(self.word.key)];
    wvc.requestURL = url;
    [self presentModalViewController:wvc animated:YES];
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

- (void)playSound
{
    if (self.player != nil) {
        [self.player play];
    }
}
- (void)refreshWordData
{
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
        BOOL shouldPerformSound = [[NSUserDefaults standardUserDefaults]boolForKey:kPerformSoundAutomatically];
        if (shouldPerformSound) {
            [self playSound];
        }
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

#pragma mark - actions
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

@end
