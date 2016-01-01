
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

#import "WordDetailViewController.h"
#import "MBProgressHUD.h"
#import "CibaEngine.h"
#import "CibaWebView.h"
#import "NSMutableString+HTMLEscape.h"
#import "VNavigationController.h"
#import "VWebViewController.h"
#import "NoteViewController.h"
#import "Note.h"
#import "EditWordDetailViewController.h"
#import "NSString+VAdditions.h"

#define CIBA_URL(__W__) [NSString stringWithFormat:@"http://wap.iciba.com/cword/%@", __W__]

@interface WordDetailViewController ()

@property (nonatomic, weak) CibaNetworkOperation *networkOperation;

@end

@implementation WordDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _shouldHideInfo = NO;
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
    [self showCustomBackButton];
}

- (void)loadRightBarButtonItems {
    UIBarButtonItem *refreshBtn = [VNavigationController generateItemWithType:VNavItemTypeRefresh target:self action:@selector(refreshWordData)];
    UIBarButtonItem *noteBtn = [VNavigationController generateNoteItemWithTarget:self action:@selector(noteButtonOnClick)];
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]initVNavBarButtonItemWithTitle:@"编辑" target:self action:@selector(btnManuallyInfoOnClick:)];
    if ([self.word.manuallyInput boolValue]) {
        self.navigationItem.rightBarButtonItems = @[noteBtn,editBtn];
    }else{
        self.navigationItem.rightBarButtonItems = @[noteBtn,refreshBtn];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self loadRightBarButtonItems];
    [super viewWillAppear:animated];
    [self refreshView];
    if (![self.word.hasGotDataFromAPI boolValue] && ![self.word.manuallyInput boolValue]) {
        [self refreshWordData];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];    
//    [[CibaEngine sharedInstance]cancelOperationOfWord:self.word];
    [self.networkOperation cancel];
    
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

- (void)refreshView
{
    self.lblKey.text = self.word.key;
    
    self.acceptationTextView.attributedText = self.word.attributedWordDetail;
    self.manuallyInputButton.hidden = YES;
    NSData *soundData = self.word.pronunciation.pronData;
    NSError *err = nil;
    self.player = [[AVAudioPlayer alloc]initWithData:soundData error:&err];
    [self.player prepareToPlay];
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

#pragma mark - actions
- (void)refreshWordData
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if ([reachability currentReachabilityStatus] == NotReachable) {
        self.acceptationTextView.text = @"无网络连接，首次访问需要通过网络。";
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    CibaEngine *engine = [CibaEngine sharedInstance];
    self.manuallyInputButton.hidden = YES; //刷新时，关闭此按钮
    
    CibaNetworkOperation *operation = nil;
    [engine fillWord:self.word outerOperation:&operation].then(^(){
        [hud hide:YES];
        [self refreshView];
        BOOL shouldPerformSound = [[NSUserDefaults standardUserDefaults]boolForKey:kPerformSoundAutomatically];
        if (shouldPerformSound) {
            [self playSound];
        }
    }).catch(^(NSError *error){
        if ([error.domain isEqualToString:CibaEngineDomain] && error.code == FillWordPronError) {
            hud.detailsLabelText = @"语音加载失败";
            [hud hide:YES afterDelay:1.5];
            [self refreshView];
        }else{
            hud.detailsLabelText = @"词义加载失败";
            [hud hide:YES afterDelay:1.5];
            self.manuallyInputButton.hidden = NO;
            [self loadRightBarButtonItems];
        }
    });
    
    self.networkOperation = operation;

}

// @Override
- (void)back {
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController.v_navigationManager commonPopAnimated:YES];
    }
}

- (void)noteButtonOnClick {
    [self.navigationController.v_navigationManager commonPushURL:[HKVNavigationRouteConfig sharedInstance].noteVC params:@{@"word":self.word} animate:YES];
}

- (IBAction)btnReadOnPressed:(id)sender
{
    [self playSound];
}

- (IBAction)fullInfomation:(id)sender
{
    NSURL *url = [NSURL URLWithString:CIBA_URL([self.word.key hkv_stringByURLEncoding])];
    [self.navigationController.v_navigationManager commonPresentModalURL:url params:nil animate:YES];
}

- (IBAction)btnManuallyInfoOnClick:(id)sender
{
    [self.navigationController.v_navigationManager commonPushURL:[HKVNavigationRouteConfig sharedInstance].editWordDetailVC params:@{@"word":self.word} animate:YES];
}

@end
