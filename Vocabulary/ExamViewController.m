
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
//  ExamViewController.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-23.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ExamViewController.h"
#import "ShowWrongWordsViewController.h"
#import "ExamView.h"
#import "CibaEngine.h"
//#import "CibaXMLParser.h"
#import "IIViewDeckController.h"
#import "AppDelegate.h"
#import "VNavigationController.h"

@interface ExamViewController ()

@property (nonatomic, unsafe_unretained) BOOL animationLock;
@property (nonatomic, unsafe_unretained) BOOL downloadLock;
@property (nonatomic, unsafe_unretained) ExamContent *currentExamContent;
@property (nonatomic, unsafe_unretained) BOOL shouldUpdateWordFamiliarity;

@property (nonatomic, strong) NSMutableSet *wordsWithNoInfoSet;
@property (nonatomic, strong) NSMutableArray *networkOperationQueue;

- (ExamView *)pickAnExamView;
- (void)createExamContentsArray;
- (void)shuffleMutableArray:(NSMutableArray *)array;
- (void)prepareNextExamView;

- (void)examViewExchangeDidFinish:(ExamView *)currExamView;
- (void)backButtonPressed;

@end

@implementation ExamViewController

- (id)initWithWordList:(WordList *)wordList
{
    self = [super initWithNibName:@"ExamViewController" bundle:nil];
    if (self) {
        _wordList = wordList;
        _examContentsQueue = [[NSMutableArray alloc]init];
        _examViewReuseQueue = [[NSMutableArray alloc]initWithCapacity:2];
        _wrongWordsSet = [[NSMutableSet alloc]init];
        _wordsWithNoInfoSet = [[NSMutableSet alloc]init];
        _networkOperationQueue = [[NSMutableArray alloc]init];
    }
    return self;
}
- (id)initWithWordArray:(NSMutableArray *)wordArray
{
    self = [super initWithNibName:@"ExamViewController" bundle:nil];
    if (self) {
        _wordsArray = wordArray;
        _examContentsQueue = [[NSMutableArray alloc]init];
        _examViewReuseQueue = [[NSMutableArray alloc]initWithCapacity:2];
        _wrongWordsSet = [[NSMutableSet alloc]init];
        _wordsWithNoInfoSet = [[NSMutableSet alloc]init];
        _networkOperationQueue = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _examContentsQueue = [[NSMutableArray alloc]init];
        _examViewReuseQueue = [[NSMutableArray alloc]initWithCapacity:2];
        _wrongWordsSet = [[NSMutableSet alloc]init];
        _wordsWithNoInfoSet = [[NSMutableSet alloc]init];
        _networkOperationQueue = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"评估";
    //adjust views
    _cursor1 = 0;
    _shouldUpdateWordFamiliarity = NO;
    
//    self.roundNotificatonLabel.layer.cornerRadius = 5.0f;
//    self.roundNotificatonLabel.clipsToBounds = YES;

    CGPoint center = CGPointMake(self.view.bounds.size.width/2, 0 - self.roundNotificatonView.bounds.size.height/2);
    self.roundNotificatonView.center = center;
    [self.view addSubview:self.roundNotificatonView];
    
    if (self.wordList != nil) {
        NSMutableArray *words = [[NSMutableArray alloc]initWithCapacity:self.wordList.words.count];
        for (Word *w in self.wordList.words) {
            [words addObject:w];
        }
        self.wordsArray = words;
    }
    
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"评估完成"
//                                                                  style:UIBarButtonItemStyleBordered target:self
//                                                                 action:@selector(backButtonPressed)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initVNavBarButtonItemWithTitle:@"评估完成" target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    //create 2 exam views;
    ExamView *ev1 = [ExamView newInstance];
    ev1.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    ev1.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44);
    ExamView *ev2 = [ExamView newInstance];
    ev2.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    ev2.frame = ev1.frame;
    [self.examViewReuseQueue addObject:ev1];
    [self.examViewReuseQueue addObject:ev2];
    
    
    //扫描是否有未加载的word
    for (Word *w in self.wordsArray) {
        if ([w.hasGotDataFromAPI boolValue] == NO) {
            
            [self.wordsWithNoInfoSet addObject:w];
            
            CibaEngine *engine = [CibaEngine sharedInstance];
            __block MKNetworkOperation *infoDownloadOp = [engine infomationForWord:w.key onCompletion:^(NSDictionary *parsedDict) {
                [self.networkOperationQueue removeObject:infoDownloadOp];                
                [CibaEngine fillWord:w withResultDict:parsedDict];
                [[[CoreDataHelperV2 sharedInstance]mainContext]save:nil];
                
                NSString *pronURL = [parsedDict objectForKey:@"pron_us"];
                if (pronURL == nil) {
                    pronURL = [parsedDict objectForKey:@"pron_uk"];
                }
                if (pronURL) {
                    __block MKNetworkOperation *voiceOp = [engine getPronWithURL:pronURL onCompletion:^(NSData *data) {
                        [self.wordsWithNoInfoSet removeObject:w];
                        [self.networkOperationQueue removeObject:voiceOp];
                        NSManagedObjectContext *ctx = [[CoreDataHelperV2 sharedInstance]mainContext];
                        PronunciationData *pronData = [NSEntityDescription insertNewObjectForEntityForName:@"PronunciationData" inManagedObjectContext:ctx];
                        pronData.pronData = data;
                        w.pronunciation = pronData;
                        w.hasGotDataFromAPI = [NSNumber numberWithBool:YES];
                        [[[CoreDataHelperV2 sharedInstance]mainContext]save:nil];
                        if (self.wordsWithNoInfoSet.count == 0) {
                            //all ok
                            [self createExamContentsArray];
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        }
                        
                    } onError:^(NSError *error) {
                        // get sound faild
                        [self.wordsWithNoInfoSet removeObject:w];
                        [self.networkOperationQueue removeObject:voiceOp];
                        w.hasGotDataFromAPI = [NSNumber numberWithBool:YES];
                        [[[CoreDataHelperV2 sharedInstance]mainContext]save:nil];
                        if (self.wordsWithNoInfoSet.count == 0) {
                            //all ok
                            [self createExamContentsArray];
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        }
                    }];
                    [self.networkOperationQueue addObject:voiceOp];
                }else {
                    // this word has no sound
                    [self.wordsWithNoInfoSet removeObject:w];
                    w.hasGotDataFromAPI = [NSNumber numberWithBool:YES];
                    [[[CoreDataHelperV2 sharedInstance]mainContext]save:nil];
                    if (self.wordsWithNoInfoSet.count == 0) {
                        //all ok
                        [self createExamContentsArray];
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    }
                }
            } onError:^(NSError *error) {
                // failed to get the word's meaning
                [self.wordsWithNoInfoSet removeObject:w];
                [self.networkOperationQueue removeObject:infoDownloadOp];
                if (self.wordsWithNoInfoSet.count == 0) {
                    [self createExamContentsArray];
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                }
            }];
            [self.networkOperationQueue addObject:infoDownloadOp];
        }
    }
    if (self.wordsWithNoInfoSet.count == 0) {
        [self createExamContentsArray];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.detailsLabelText = @"正在取词";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    ((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController.panningMode = IIViewDeckNoPanning;
}

- (void)viewWillDisappear:(BOOL)animated
{
    ((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController.panningMode = IIViewDeckFullViewPanning;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.roundNotificatonView setNeedsDisplay];
}

- (void)calculateFamiliarityForEveryWords
{
    [self.examContentsQueue sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ExamContent *c1 = (ExamContent *)obj1;
        ExamContent *c2 = (ExamContent *)obj2;
        NSString *str1 = c1.word.key;
        NSString *str2 = c2.word.key;
        return [str1 compare:str2];
    }];
    int i = 0;
    while (i<self.examContentsQueue.count) {
        ExamContent *c1 = [self.examContentsQueue objectAtIndex:i];
        ExamContent *c2 = nil;
        if (i+1 < self.examContentsQueue.count) {
            c2 = [self.examContentsQueue objectAtIndex:i+1];
        }
        int rightCount = c1.rightTimes;
        int wrongCount = c1.wrongTimes;
        if (c1.word == c2.word) {
            rightCount += c2.rightTimes;
            wrongCount += c2.wrongTimes;
            i += 2;
        }else{
            i += 1;
        }
        
        float familiarity = 0;
        if (rightCount != 0 || wrongCount != 0) {
            familiarity = ((float)(rightCount))/(rightCount+wrongCount);
        }
        if (c1.word.lastVIewDate != nil) {
            //与以前的值做平均
            float oldFamiliarity = [c1.word.familiarity floatValue]/10;
            familiarity = (oldFamiliarity + familiarity)/2;
        }
        
        int familiarityInt = (int)(roundf(familiarity*10));
        c1.word.familiarity = [NSNumber numberWithInt:familiarityInt];
        c1.word.lastVIewDate = [NSDate date];
    }
    [[[CoreDataHelperV2 sharedInstance]mainContext]save:nil];
}

#pragma mark - ibactions

- (IBAction)rightButtonOnPress:(id)sender
{

    if (_animationLock) {
        return;
    }
    self.currentExamContent.rightTimes++;
    [self prepareNextExamView];
}

- (IBAction)wrongButtonOnPress:(id)sender
{
    if (_animationLock) {
        return;
    }
    self.rightButton.enabled = YES;
    self.currentExamContent.wrongTimes++;
    [self.wrongWordsSet addObject:self.currentExamContent.word];
    [self prepareNextExamView];
}

#pragma mark - private methods
- (ExamView *)pickAnExamView
{
    static int i = 0;
    ExamView *view = [self.examViewReuseQueue objectAtIndex:i%2];
    i++;
    return view;
}

- (void)createExamContentsArray
{
    self.rightButton.enabled = NO;
    self.wrongButton.enabled = NO;
    //create examContents and detect if the word has acceptation.
    for (Word *word in self.wordsArray) {
        //NSLog(@"creating exam contents...");
        if (word.acceptation != nil) {
            ExamContent *contentE2C = [[ExamContent alloc]initWithWord:word examType:ExamTypeE2C];
            [self.examContentsQueue addObject:contentE2C];
        }
        
        //NSLog(@"%@",contentE2C);
        if ( word.pronunciation.pronData != nil) {
            ExamContent *contentS2E = [[ExamContent alloc]initWithWord:word examType:ExamTypeS2E];
            [self.examContentsQueue addObject:contentS2E];
            //NSLog(@"%@",contentS2E);
        }
    }
    
    //shuffle array
    [self shuffleMutableArray:self.examContentsQueue];
    
    if (self.examContentsQueue.count != 0) {
        ExamContent *content = [self.examContentsQueue objectAtIndex:_cursor1];;
        
        ExamView *ev = [self pickAnExamView];
        ev.content = content;
        self.currentExamContent = content;
        [self.view addSubview:ev];
        [self examViewExchangeDidFinish:ev];
        self.rightButton.enabled = YES;
        self.wrongButton.enabled = YES;
    }
}

- (void)shuffleMutableArray:(NSMutableArray *)array
{
    int i = [array count];
    while(--i > 0) {
        int j = arc4random() % (i+1);
        [array exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
}

- (void)prepareNextExamView
{
    ExamView *ev = [self pickAnExamView];
    ev.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44);
    _cursor1 = ++_cursor1 % self.examContentsQueue.count;
    ExamContent * content = [self.examContentsQueue objectAtIndex:_cursor1];
    if (_cursor1 == 0) {
        //已经循环一遍了
        NSLog(@"已经循环一遍了");
        //显示提示
        [self.view bringSubviewToFront:self.roundNotificatonView];
        [UIView animateWithDuration:0.5 animations:^{
            self.roundNotificatonView.transform = CGAffineTransformMakeTranslation(0, 0-self.roundNotificatonView.frame.origin.y);
        } completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.5 delay:3 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.roundNotificatonView.transform = CGAffineTransformMakeTranslation(0,0);
                } completion:nil];
            }
        }];
        
        //根据权值算法排序
        [self.examContentsQueue sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            ExamContent *c1 = (ExamContent *)obj1;
            ExamContent *c2 = (ExamContent *)obj2;
            int weight1 = [c1 weight];
            int weight2 = [c2 weight];
            if (weight1>weight2) {
                return NSOrderedAscending;
            }else if(weight1==weight2){
                return NSOrderedSame;
            }else{
                return NSOrderedDescending;
            }
        }];
        
        //更新本WordList的信息
        if (self.wordList != nil) {
            self.wordList.finished = YES;
            NSDate *lastReviewTime = self.wordList.lastReviewTime;
            if (lastReviewTime != nil) {
                NSDateComponents *components = [[NSCalendar currentCalendar]components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:lastReviewTime];
                NSInteger lastReviewYear = components.year;
                NSInteger lastReviewMonth = components.month;
                NSInteger lastReviewDay = components.day;
                components = [[NSCalendar currentCalendar]components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[NSDate date]];
                NSInteger currYear = components.year;
                NSInteger currMonth = components.month;
                NSInteger currDay = components.day;
                BOOL effect = YES;
                if (currYear-lastReviewYear==0 && currMonth-lastReviewMonth==0) {
                    effect = (currDay-lastReviewDay)>0;
                }
                
                if (effect) {
                    //如果距离上次复习时间大于一天，视为有效次数
                    int effictiveCount = [self.wordList.effectiveCount intValue];
                    NSAssert(effictiveCount != 0, @"effectiveCount > 0 while lastReviewTime is nil");
                    if (effictiveCount == 0) {
                        ((AppDelegate *)[UIApplication sharedApplication].delegate).finishTodaysLearningPlan = YES;
                        NSDate *planExpireDate = [[NSDate date]dateByAddingTimeInterval:24*60*60];//往后推一天
                        ((AppDelegate *)[UIApplication sharedApplication].delegate).planExpireTime = planExpireDate;
                    }
                    effictiveCount++;
                    self.wordList.effectiveCount = [NSNumber numberWithInt:effictiveCount];
                    self.wordList.lastReviewTime = [NSDate date]; //设为现在
                }
            }else{
                int effictiveCount = [self.wordList.effectiveCount intValue];
                if (effictiveCount == 0) {
                    ((AppDelegate *)[UIApplication sharedApplication].delegate).finishTodaysLearningPlan = YES;
                    NSDate *planExpireDate = [[NSDate date]dateByAddingTimeInterval:24*60*60];//往后推一天
                    ((AppDelegate *)[UIApplication sharedApplication].delegate).planExpireTime = planExpireDate;
                }
                effictiveCount++;
                self.wordList.effectiveCount = [NSNumber numberWithInt:effictiveCount];
                self.wordList.lastReviewTime = [NSDate date]; //设为现在
            }
            
        }
        
        //标记Word熟悉度可更新
        _shouldUpdateWordFamiliarity = YES;
    }
    ev.content = content;
    self.currentExamContent = content;
    NSLog(@"%d",[content weight]);
    int i = [self.examViewReuseQueue indexOfObject:ev];
    ExamView *oldView = [self.examViewReuseQueue objectAtIndex:++i%2];
    [oldView stopSound];
    [self.view insertSubview:ev belowSubview:oldView];
    [UIView animateWithDuration:0.5 animations:^{
        _animationLock = YES;
        CGFloat width = oldView.bounds.size.width;
        oldView.transform = CGAffineTransformMakeTranslation(-width, 0);
    } completion:^(BOOL finished) {
        oldView.transform = CGAffineTransformMakeTranslation(0, 0);
        [self.view insertSubview:oldView belowSubview:ev];
        [self examViewExchangeDidFinish:ev];
        _animationLock = NO;
    }];
    
}

- (void)examViewExchangeDidFinish:(ExamView *)currExamView
{
    ExamContent *content = currExamView.content;
    content.lastReviewDate = [NSDate date];
    if (content.examType == ExamTypeS2E) {
//        Word *word = content.word;
//        NSData *pronData = word.pronounceUS;
//        if (pronData == nil) {
//            pronData = word.pronounceEN;
//        }
//        if (pronData != nil) {
//            self.soundPlayer = [[AVAudioPlayer alloc]initWithData:pronData error:nil];
//            [self.soundPlayer play];
//        }
        [currExamView playSound];
    }
}

- (void)backButtonPressed
{
    if (_shouldUpdateWordFamiliarity) {
        [self calculateFamiliarityForEveryWords];
        if (self.wrongWordsSet.count == 0) {

            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[ShowWordsViewController class]] && ![vc isKindOfClass:[ShowWrongWordsViewController class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
        }else{
            NSMutableArray *wrongWordsArray = [[NSMutableArray alloc]init];
            for (Word *w in self.wrongWordsSet) {
                [wrongWordsArray addObject:w];
            }
            ShowWrongWordsViewController *svc = [[ShowWrongWordsViewController alloc]initWithNibName:@"ShowWordsViewController" bundle:nil];
            svc.wordsSet = wrongWordsArray;
            [self.navigationController pushViewController:svc animated:YES];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"您还没背完一遍呢"
                                                           message:@"本次测试将作废"
                                                          delegate:self
                                                 cancelButtonTitle:@"继续背"
                                                 otherButtonTitles:@"确认作废",nil];
        [alertView show];
    }
}

#pragma mark - alert view delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"确认作废"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
