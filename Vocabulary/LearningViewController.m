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
    self.bannerFrame = CGRectMake(0, -50, self.view.bounds.size.width, 50);
    self.banner.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view bringSubviewToFront:self.banner];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"view will disappear");
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.downloadOp cancel];
    [self.voiceOp cancel];
    self.downloadOp = nil;
    self.voiceOp = nil;
    [self.player stop];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.acceptationTextView.text = @"";
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
        NSString *jointStr = [NSString stringWithFormat:@"英[%@] 美[%@]\n%@%@",self.word.psEN,self.word.psUS,self.word.acceptation,self.word.sentences];
        self.acceptationTextView.text = jointStr;
        BOOL shouldPerformSound = [[NSUserDefaults standardUserDefaults]boolForKey:kPerformSoundAutomatically];
        self.player = [[AVAudioPlayer alloc]initWithData:self.word.pronounceUS error:nil];
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
        if (self.downloadOp == nil || self.downloadOp.isCancelled) {
//            NSLog(@"iscancelled:%d,isfinished:%d",self.downloadOp.isFinished,self.downloadOp.isFinished);
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"正在取词";
            CibaEngine *engine = [CibaEngine sharedInstance];
            self.downloadOp = [engine infomationForWord:self.word.key onCompletion:^(NSDictionary *parsedDict) {
                if (parsedDict == nil) {
                    // error on parsing
                    hud.labelText = @"词义加载失败";
                    [hud hide:YES afterDelay:1];
                }
                self.word.acceptation = [parsedDict objectForKey:@"acceptation"];
                self.word.psEN = [parsedDict objectForKey:@"psEN"];
                self.word.psUS = [parsedDict objectForKey:@"psUS"];
                self.word.sentences = [parsedDict objectForKey:@"sentence"];
                //self.word.hasGotDataFromAPI = [NSNumber numberWithBool:YES];
                [[CoreDataHelper sharedInstance]saveContext];
                //load voice
                NSString *pronURL = [parsedDict objectForKey:@"pronounceUS"];
                if (pronURL == nil) {
                    pronURL = [parsedDict objectForKey:@"pronounceEN"];
                }
                if (pronURL && (self.voiceOp == nil || self.voiceOp.isCancelled)) {
                    self.voiceOp = [engine getPronWithURL:pronURL onCompletion:^(NSData *data) {
                        NSLog(@"voice succeed");
                        self.word.pronounceUS = data;
                        self.word.hasGotDataFromAPI = [NSNumber numberWithBool:YES];
                        [[CoreDataHelper sharedInstance]saveContext];
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [self refreshView];
                        
                    } onError:^(NSError *error) {
                        NSLog(@"VOICE ERROR");
                        [self refreshView];
                        self.word.hasGotDataFromAPI = [NSNumber numberWithBool:YES];
                        [[CoreDataHelper sharedInstance]saveContext];
                        hud.labelText = @"语音加载失败";
                        [hud hide:YES afterDelay:1];
                    }];
                }else{
                    hud.labelText = @"语音加载失败";
                    [hud hide:YES afterDelay:1];
                    [self refreshView];
                }
                
            } onError:^(NSError *error) {
                hud.labelText = @"词义加载失败";
                [hud hide:YES afterDelay:1];
                NSLog(@"ERROR");
            }];
        }
    }
}
- (IBAction)btnReadOnPressed:(id)sender
{
    if (self.player != nil) {
        [self.player play];
    }
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

#pragma - mark GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    [super adViewDidReceiveAd:view];
    [UIView animateWithDuration:0.5 animations:^{
        UIView *content = [self.view viewWithTag:1];
        CGRect targetFrame = CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height-50);
        content.frame = targetFrame;
        self.banner.transform = CGAffineTransformMakeTranslation(0, 50);
    }];
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error
{
    [super adView:view didFailToReceiveAdWithError:error];
    [UIView animateWithDuration:0.5 animations:^{
        UIView *content = [self.view viewWithTag:1];
        CGRect targetFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        content.frame = targetFrame;
        self.banner.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}
@end
