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
}

-(void)viewWillAppear:(BOOL)animated
{
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
    }
    return self;
}



- (void)refreshView
{
    self.lblKey.text = self.word.key;
    [self.lblKey sizeToFit];
    if (self.word.hasGotDataFromAPI) {
        NSString *jointStr = [NSString stringWithFormat:@"[%@]\n%@%@",self.word.psUS,self.word.acceptation,self.word.sentences];
        self.acceptationTextView.text = jointStr;
        self.player = [[AVAudioPlayer alloc]initWithData:self.word.pronounceUS error:nil];
        [self.player play];
    }else{
        if (self.downloadOp == nil || self.downloadOp.isCancelled) {
//            NSLog(@"iscancelled:%d,isfinished:%d",self.downloadOp.isFinished,self.downloadOp.isFinished);
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"正在取词";
            CibaEngine *engine = [CibaEngine sharedInstance];
            self.downloadOp = [engine infomationForWord:self.word.key onCompletion:^(NSDictionary *parsedDict) {
                
                self.word.acceptation = [parsedDict objectForKey:@"acceptation"];
                self.word.psEN = [parsedDict objectForKey:@"psEN"];
                self.word.psUS = [parsedDict objectForKey:@"psUS"];
                self.word.sentences = [parsedDict objectForKey:@"sentence"];
                //self.word.hasGotDataFromAPI = [NSNumber numberWithBool:YES];
                [[CoreDataHelper sharedInstance]saveContext];
                //load voice
                NSString *pronURL = [parsedDict objectForKey:@"pronounceUS"];

                if (pronURL && (self.voiceOp == nil || self.voiceOp.isCancelled)) {
                    self.voiceOp = [engine getPronWithURL:pronURL onCompletion:^(NSData *data) {
                        NSLog(@"voice succeed");
                        if (data == nil) {
                            NSLog(@"data nil");
                            return;
                        }
                        self.word.pronounceUS = data;
                        self.word.hasGotDataFromAPI = [NSNumber numberWithBool:YES];
                        [[CoreDataHelper sharedInstance]saveContext];
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [self refreshView];
                        
                    } onError:^(NSError *error) {
                        NSLog(@"VOICE ERROR");
                        [self refreshView];
                        self.word.hasGotDataFromAPI = [NSNumber numberWithBool:NO];
                        [[CoreDataHelper sharedInstance]saveContext];
                        hud.labelText = @"语音加载失败";
                        [hud hide:YES afterDelay:0.5];
                    }];
                }
                
            } onError:^(NSError *error) {
                hud.labelText = @"词义加载失败";
                [hud hide:YES afterDelay:0.5];
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
@end
