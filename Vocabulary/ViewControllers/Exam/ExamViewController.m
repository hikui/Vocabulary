
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
#import "ExamContentView.h"
#import "CibaEngine.h"
#import "AppDelegate.h"
#import "VNavigationController.h"
#import "SimpleProgressBar.h"
#import "PlanMaker.h"

@interface ExamViewController ()

@property (nonatomic, unsafe_unretained) BOOL animationLock;
@property (nonatomic, unsafe_unretained) BOOL downloadLock;
@property (nonatomic, unsafe_unretained) ExamContent *currentExamContent;
@property (nonatomic, unsafe_unretained) BOOL shouldUpdateWordFamiliarity;

@property (nonatomic, strong) NSMutableSet *networkOperationSet;

@property (nonatomic, strong) SimpleProgressBar *progressBar;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) ExamContentView *pickAnExamView;
- (void)createExamContentsArray;
- (void)shuffleMutableArray:(NSMutableArray *)array;
- (void)prepareNextExamView;

- (void)examViewExchangeDidFinish:(ExamContentView *)currExamView;
- (void)backButtonPressed;

@end

@implementation ExamViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _examContentsQueue = [[NSMutableArray alloc]init];
    _examViewReuseQueue = [[NSMutableArray alloc]initWithCapacity:2];
    _wrongWordsSet = [[NSMutableSet alloc]init];
    _networkOperationSet = [[NSMutableSet alloc]init];
    _examOption = ExamOptionC2E | ExamOptionE2C | ExamOptionListening;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"评估";
    //adjust views
    _cursor1 = 0;
    _shouldUpdateWordFamiliarity = NO;

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
    ExamContentView *ev1 = [ExamContentView newInstance];
    ev1.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    ev1.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-48);
    ExamContentView *ev2 = [ExamContentView newInstance];
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


- (void)viewWillDisappear:(BOOL)animated
{
    for (CibaNetworkOperation *operation in self.networkOperationSet) {
        [operation cancel];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
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

- (void)calculateFamiliarityForContentQueue:(NSMutableArray *)contentQueue
{
    [contentQueue sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ExamContent *c1 = (ExamContent *)obj1;
        ExamContent *c2 = (ExamContent *)obj2;
        NSString *str1 = c1.word.key;
        NSString *str2 = c2.word.key;
        return [str1 compare:str2];
    }];
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        
        int i = 0;
        while (i<contentQueue.count) {
            
            int rightCount = 0;
            int wrongCount = 0;
            
            ExamContent *ci = contentQueue[i];
            rightCount += ci.rightTimes;
            wrongCount += ci.wrongTimes;
            
            int j = i + 1;
            while (j < contentQueue.count) {
                ExamContent *cj = contentQueue[j];
                if (cj.word != ci.word) {
                    break;
                }
                rightCount += cj.rightTimes;
                wrongCount += cj.wrongTimes;
                j++;
            }
            
            i = j;
            
            float familiarity = 0;
            if (rightCount != 0 || wrongCount != 0) {
                familiarity = ((float)(rightCount))/(rightCount+wrongCount);
            }
            if (ci.word.lastVIewDate != nil) {
                //与以前的值做平均
                float oldFamiliarity = [ci.word.familiarity floatValue]/10;
                familiarity = (oldFamiliarity + familiarity)/2;
            }
            
            int familiarityInt = (int)(roundf(familiarity*10));
            Word *c1WordInLocalContext = [ci.word MR_inContext:localContext];
            
            c1WordInLocalContext.familiarity = @(familiarityInt);
            c1WordInLocalContext.lastVIewDate = [NSDate date];
        }
    }];
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
- (ExamContentView *)pickAnExamView
{
    static int i = 0;
    ExamContentView *view = (self.examViewReuseQueue)[i%2];
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
        if ((self.examOption & ExamOptionE2C) == ExamOptionE2C && word.acceptation != nil) {
            ExamContent *contentE2C = [[ExamContent alloc]initWithWord:word examType:ExamTypeE2C];
            [self.examContentsQueue addObject:contentE2C];
        }
        
        if ((self.examOption & ExamOptionListening) == ExamOptionListening && word.pronunciation.pronData != nil) {
            ExamContent *contentS2E = [[ExamContent alloc]initWithWord:word examType:ExamTypeS2E];
            [self.examContentsQueue addObject:contentS2E];
        }
        
        if ((self.examOption & ExamOptionC2E) == ExamOptionC2E && word.acceptation != nil) {
            ExamContent *contentC2E = [[ExamContent alloc]initWithWord:word examType:ExamTypeC2E];
            [self.examContentsQueue addObject:contentC2E];
        }
    }
    
    //shuffle array
    [self shuffleMutableArray:self.examContentsQueue];
    
    if (self.examContentsQueue.count != 0) {
        ExamContent *content = (self.examContentsQueue)[_cursor1];;
        
        ExamContentView *ev = [self pickAnExamView];
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
    NSInteger i = [array count];
    while(--i > 0) {
        NSUInteger j = arc4random() % (i+1);
        [array exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
}

- (void)prepareNextExamView
{
    ExamContentView *ev = [self pickAnExamView];
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
            void (^updateWordList)() = ^void() {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    WordList *localWordList = [self.wordList MR_inContext:localContext];
                    int effictiveCount = [self.wordList.effectiveCount intValue];
                    effictiveCount++;
                    localWordList.effectiveCount = @(effictiveCount);
                    localWordList.lastReviewTime = [NSDate date]; //设为现在
                }];
            };
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
                    updateWordList();
                }
            }else{
                updateWordList();
            }
            
        }
        
        //标记Word熟悉度可更新
        _shouldUpdateWordFamiliarity = YES;
    }
    ev.content = content;
    self.currentExamContent = content;
    DDLogDebug(@"%d",[content weight]);
    NSUInteger i = [self.examViewReuseQueue indexOfObject:ev];
    ExamContentView *oldView = (self.examViewReuseQueue)[++i%2];
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

- (void)examViewExchangeDidFinish:(ExamContentView *)currExamView
{
    ExamContent *content = currExamView.content;
    content.lastReviewDate = [NSDate date];
    if (content.examType == ExamTypeS2E) {
        [currExamView playSound];
    }
}

- (void)backButtonPressed
{
    if (_shouldUpdateWordFamiliarity) {
        [self calculateFamiliarityForContentQueue:self.examContentsQueue];
        if (self.wrongWordsSet.count == 0) {
            [self.navigationController.v_navigationManager commonPopToURL:[HKVNavigationRouteConfig sharedInstance].wordListVC animate:YES];
        }else{
            NSMutableArray *wrongWordsArray = [[NSMutableArray alloc]init];
            for (Word *w in self.wrongWordsSet) {
                [wrongWordsArray addObject:w];
            }
            [self.navigationController.v_navigationManager commonPushURL:[HKVNavigationRouteConfig sharedInstance].showWrongWordsVC params:@{@"wordArray":wrongWordsArray} animate:YES];
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
        [self.navigationController.v_navigationManager commonPopAnimated:YES];
    }
}


@end
