
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
#import "SimpleProgressBar.h"
#import "PlanMaker.h"

@interface ExamViewController ()

@property (nonatomic, unsafe_unretained) BOOL animationLock;
@property (nonatomic, unsafe_unretained) BOOL downloadLock;
@property (nonatomic, unsafe_unretained) ExamContent *currentExamContent;
@property (nonatomic, unsafe_unretained) BOOL shouldUpdateWordFamiliarity;

//@property (nonatomic, strong) NSMutableSet *wordsWithNoInfoSet;
@property (nonatomic, strong) NSMutableSet *networkOperationSet;

@property (nonatomic, strong) SimpleProgressBar *progressBar;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) ExamView *pickAnExamView;
- (void)createExamContentsArray;
- (void)shuffleMutableArray:(NSMutableArray *)array;
- (void)prepareNextExamView;

- (void)examViewExchangeDidFinish:(ExamView *)currExamView;
- (void)backButtonPressed;

@end

@implementation ExamViewController

- (instancetype)initWithWordList:(WordList *)wordList
{
    self = [super initWithNibName:@"ExamViewController" bundle:nil];
    if (self) {
        _wordList = wordList;
        _examContentsQueue = [[NSMutableArray alloc]init];
        _examViewReuseQueue = [[NSMutableArray alloc]initWithCapacity:2];
        _wrongWordsSet = [[NSMutableSet alloc]init];
//        _wordsWithNoInfoSet = [[NSMutableSet alloc]init];
        _networkOperationSet = [[NSMutableSet alloc]init];
    }
    return self;
}
- (instancetype)initWithWordArray:(NSMutableArray *)wordArray
{
    self = [super initWithNibName:@"ExamViewController" bundle:nil];
    if (self) {
        _wordsArray = wordArray;
        _examContentsQueue = [[NSMutableArray alloc]init];
        _examViewReuseQueue = [[NSMutableArray alloc]initWithCapacity:2];
        _wrongWordsSet = [[NSMutableSet alloc]init];
//        _wordsWithNoInfoSet = [[NSMutableSet alloc]init];
        _networkOperationSet = [[NSMutableSet alloc]init];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _examContentsQueue = [[NSMutableArray alloc]init];
        _examViewReuseQueue = [[NSMutableArray alloc]initWithCapacity:2];
        _wrongWordsSet = [[NSMutableSet alloc]init];
//        _wordsWithNoInfoSet = [[NSMutableSet alloc]init];
        _networkOperationSet = [[NSMutableSet alloc]init];
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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initVNavBarButtonItemWithTitle:@"评估完成" target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    //create 2 exam views;
    ExamView *ev1 = [ExamView newInstance];
    ev1.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    ev1.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-48);
    ExamView *ev2 = [ExamView newInstance];
    ev2.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    ev2.frame = ev1.frame;
    [self.examViewReuseQueue addObject:ev1];
    [self.examViewReuseQueue addObject:ev2];
    [self.view addSubview:ev1];
    [self.view addSubview:ev2];
    
    
    // 增加progress
    self.progressBar = [[SimpleProgressBar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-48, self.view.bounds.size.width, 4) barColor:RGBA(22, 140, 228, 0.9)];
    self.progressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.progressBar];
    
    
    //扫描是否有未加载的word
//    for (Word *w in self.wordsArray) {
//        if ([w.hasGotDataFromAPI boolValue] == NO && [w.manuallyInput boolValue] == NO) {
//            
//            [self.wordsWithNoInfoSet addObject:w];
//            
//            CibaEngine *engine = [CibaEngine sharedInstance];
//            __block MKNetworkOperation *infoDownloadOp = [engine requestContentOfWord:w.key onCompletion:^(NSDictionary *parsedDict) {
//                [self.networkOperationSet removeObject:infoDownloadOp];
//                [CibaEngine fillWord:w withResultDict:parsedDict];
////                [[[CoreDataHelperV2 sharedInstance]mainContext]save:nil];
//                
//                NSString *pronURL = parsedDict[@"pron_us"];
//                if (pronURL == nil) {
//                    pronURL = parsedDict[@"pron_uk"];
//                }
//                if (pronURL) {
//                    __block MKNetworkOperation *voiceOp = [engine requestPronWithURL:pronURL onCompletion:^(NSData *data) {
//                        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//                            [self.wordsWithNoInfoSet removeObject:w];
//                            [self.networkOperationSet removeObject:voiceOp];
//                            //                        NSManagedObjectContext *ctx = [[CoreDataHelperV2 sharedInstance]mainContext];
//                            PronunciationData *pronData = [PronunciationData MR_createEntityInContext:localContext];
//                            pronData.pronData = data;
//                            Word *localWord = [w MR_inContext:localContext];
//                            localWord.pronunciation = pronData;
//                            localWord.hasGotDataFromAPI = @YES;
//                        }];
//                        if (self.wordsWithNoInfoSet.count == 0) {
//                            //all ok
//                            [self createExamContentsArray];
//                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                        }
//                        
//                    } onError:^(NSError *error) {
//                        // get sound faild
//                        [self.wordsWithNoInfoSet removeObject:w];
//                        [self.networkOperationSet removeObject:voiceOp];
//                        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//                            Word *localWord = [w MR_inContext:localContext];
//                            localWord.hasGotDataFromAPI = @YES;
//                        }];
//                        if (self.wordsWithNoInfoSet.count == 0) {
//                            //all ok
//                            [self createExamContentsArray];
//                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                        }
//                    }];
//                    [self.networkOperationSet addObject:voiceOp];
//                }else {
//                    // this word has no sound
//                    [self.wordsWithNoInfoSet removeObject:w];
//                    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//                        Word *localWord = [w MR_inContext:localContext];
//                        localWord.hasGotDataFromAPI = @YES;
//                    }];
//                    if (self.wordsWithNoInfoSet.count == 0) {
//                        //all ok
//                        [self createExamContentsArray];
//                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                    }
//                }
//            } onError:^(NSError *error) {
//                // failed to get the word's meaning
//                [self.wordsWithNoInfoSet removeObject:w];
//                [self.networkOperationSet removeObject:infoDownloadOp];
//                if (self.wordsWithNoInfoSet.count == 0) {
//                    [self createExamContentsArray];
//                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                }
//            }];
//            [self.networkOperationSet addObject:infoDownloadOp];
//        }
//    }
    
    [self grabWordContent];
    
    if (self.networkOperationSet.count == 0) {
        [self createExamContentsArray];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.detailsLabelText = @"正在取词";
    }
}

- (void)grabWordContent {
    CibaEngine *engine = [CibaEngine sharedInstance];
    for (Word *aWord in self.wordsArray) {
        if ([aWord.hasGotDataFromAPI boolValue] || [aWord.manuallyInput boolValue]) {
            continue;
        }
        
        CibaNetworkOperation *operation = nil;
        [engine fillWord:aWord outerOperation:&operation].finally(^{
            [self.networkOperationSet removeObject:operation];
            if (self.networkOperationSet.count == 0) {
                //all ok
                [self createExamContentsArray];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
        });
        if (operation) {
            [self.networkOperationSet addObject:operation];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    ((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController.panningMode = IIViewDeckNoPanning;
}

- (void)viewWillDisappear:(BOOL)animated
{
    ((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController.panningMode = IIViewDeckFullViewPanning;
    for (CibaNetworkOperation *operation in self.networkOperationSet) {
        [operation cancel];
    }
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        [self.examContentsQueue sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            ExamContent *c1 = (ExamContent *)obj1;
            ExamContent *c2 = (ExamContent *)obj2;
            NSString *str1 = c1.word.key;
            NSString *str2 = c2.word.key;
            return [str1 compare:str2];
        }];
        int i = 0;
        while (i<self.examContentsQueue.count) {
            ExamContent *c1 = (self.examContentsQueue)[i];
            ExamContent *c2 = nil;
            if (i+1 < self.examContentsQueue.count) {
                c2 = (self.examContentsQueue)[i+1];
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
            Word *c1WordInLocalContext = [c1.word MR_inContext:localContext];
            
            c1WordInLocalContext.familiarity = @(familiarityInt);
            c1WordInLocalContext.lastVIewDate = [NSDate date];
        }
    }];
    
//    [[[CoreDataHelperV2 sharedInstance]mainContext]save:nil];
    //TODO: fix this
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
    ExamView *view = (self.examViewReuseQueue)[i%2];
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
        ExamContent *content = (self.examContentsQueue)[_cursor1];;
        
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
    NSUInteger i = [array count];
    while(--i > 0) {
        NSUInteger j = arc4random() % (i+1);
        [array exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
}

- (void)prepareNextExamView
{
    ExamView *ev = [self pickAnExamView];
    ev.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-48);
    _cursor1 = ++_cursor1;
    self.progressBar.progress = (float)_cursor1 / self.examContentsQueue.count;
    _cursor1 = _cursor1 % self.examContentsQueue.count;
    
    ExamContent * content = (self.examContentsQueue)[_cursor1];
    if (_cursor1 == 0) {
        //已经循环一遍了
        DDLogDebug(@"已经循环一遍了");
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
//            self.wordList.finished = YES;
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
//                    if (effictiveCount == 0) {
//                        //如果effectiveCount == 0，则是新学的单词列表
//                        [[PlanMaker sharedInstance]finishTodaysLearningPlan];
//                    }
                    effictiveCount++;
                    self.wordList.effectiveCount = @(effictiveCount);
                    self.wordList.lastReviewTime = [NSDate date]; //设为现在
                }
            }else{
                int effictiveCount = [self.wordList.effectiveCount intValue];
//                if (effictiveCount == 0) {
//                    [[PlanMaker sharedInstance]finishTodaysLearningPlan];
//                }
                effictiveCount++;
                self.wordList.effectiveCount = @(effictiveCount);
                self.wordList.lastReviewTime = [NSDate date]; //设为现在
            }
            
        }
        
        //标记Word熟悉度可更新
        _shouldUpdateWordFamiliarity = YES;
    }
    ev.content = content;
    self.currentExamContent = content;
    DDLogDebug(@"%d",[content weight]);
    NSUInteger i = [self.examViewReuseQueue indexOfObject:ev];
    ExamView *oldView = (self.examViewReuseQueue)[++i%2];
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
                if ([vc isKindOfClass:[WordListViewController class]] && ![vc isKindOfClass:[ShowWrongWordsViewController class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
        }else{
            NSMutableArray *wrongWordsArray = [[NSMutableArray alloc]init];
            for (Word *w in self.wrongWordsSet) {
                [wrongWordsArray addObject:w];
            }
            ShowWrongWordsViewController *svc = [[ShowWrongWordsViewController alloc]initWithNibName:@"WordListViewController" bundle:nil];
            svc.wordArray = wrongWordsArray;
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
