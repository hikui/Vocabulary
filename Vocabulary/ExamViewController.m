//
//  ExamViewController.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-23.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ExamViewController.h"
#import "ExamView.h"

@interface ExamViewController ()

@property (nonatomic, unsafe_unretained) BOOL animationLock;
@property (nonatomic, unsafe_unretained) ExamContent *currentExamContent;

- (ExamView *)pickAnExamView;
- (void)shuffleMutableArray:(NSMutableArray *)array;
- (void)prepareNextExamView;

- (void)examViewExchangeDidFinish:(ExamView *)currExamView;

@end

@implementation ExamViewController

- (id)initWithWordList:(WordList *)wordList
{
    self = [super initWithNibName:@"ExamViewController" bundle:nil];
    if (self) {
        _wordList = wordList;
        _examContentsQueue = [[NSMutableArray alloc]init];
        _examViewReuseQueue = [[NSMutableArray alloc]initWithCapacity:2];
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
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        _examContentsQueue = [[NSMutableArray alloc]init];
        _examViewReuseQueue = [[NSMutableArray alloc]initWithCapacity:2];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cursor1 = 0;
    
    self.roundNotificatonLabel.layer.cornerRadius = 5.0f;
    self.roundNotificatonLabel.clipsToBounds = YES;

    CGPoint center = CGPointMake(self.view.bounds.size.width/2, 0 - self.roundNotificatonLabel.bounds.size.height/2);
    self.roundNotificatonLabel.center = center;
    [self.view addSubview:self.roundNotificatonLabel];
    
    if (self.wordList != nil) {
        NSMutableArray *words = [[NSMutableArray alloc]initWithCapacity:self.wordList.words.count];
        for (Word *w in self.wordList.words) {
            [words addObject:w];
        }
        self.wordsArray = words;
    }
    
    //create examContents
    for (Word *word in self.wordsArray) {
        //NSLog(@"creating exam contents...");
        ExamContent *contentE2C = [[ExamContent alloc]initWithWord:word examType:ExamTypeE2C];
        [self.examContentsQueue addObject:contentE2C];
        //NSLog(@"%@",contentE2C);
        if ( word.pronounceUS != nil || word.pronounceEN != nil) {
            ExamContent *contentS2E = [[ExamContent alloc]initWithWord:word examType:ExamTypeS2E];
            [self.examContentsQueue addObject:contentS2E];
            //NSLog(@"%@",contentS2E);
        }
    }
    
    //create 2 exam views;
    ExamView *ev1 = [ExamView newInstance];
    ev1.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44);
    ExamView *ev2 = [ExamView newInstance];
    ev2.frame = ev1.frame;
    [self.examViewReuseQueue addObject:ev1];
    [self.examViewReuseQueue addObject:ev2];
    
    //shuffle array
    [self shuffleMutableArray:self.examContentsQueue];

    ExamContent *content = [self.examContentsQueue objectAtIndex:_cursor1];;

    ExamView *ev = [self pickAnExamView];
    ev.content = content;
    self.currentExamContent = content;
    [self.view addSubview:ev];
    [self examViewExchangeDidFinish:ev];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    //统计各个word的familiarity
    
    //排序
    
    [self calculateFamiliarityForEveryWords];
    
//    for (ExamContent *c1 in self.examContentsQueueE2C) {
//        int rightCount = c1.rightTimes;
//        int wrongCount = c1.wrongTimes;
//        for (int i = 0; i<self.examContentsQueueS2E.count; i++) {
//            ExamContent *c2 = [self.examContentsQueueS2E objectAtIndex:i];
//            if (c2.word == c1.word) {
//                rightCount += c2.rightTimes;
//                wrongCount += c2.wrongTimes;
//                break;
//            }
//        }
//        float familiarity = 0;
//        if (rightCount != 0 || wrongCount != 0) {
//            familiarity = ((float)(rightCount))/(rightCount+wrongCount);
//        }
//        int familiarityInt = (int)(familiarity *10);
//        c1.word.familiarity = [NSNumber numberWithInt:familiarityInt];
//    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
        ExamContent *c2 = [self.examContentsQueue objectAtIndex:i+1];
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
        int familiarityInt = (int)(familiarity *10);
        c1.word.familiarity = [NSNumber numberWithInt:familiarityInt];
    }
    [[CoreDataHelper sharedInstance]saveContext];
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

//- (NSMutableArray *)choseExamContentQueueRandomly
//{
//    int index = arc4random() % 2;
//    if (index == 0) {
//        return self.examContentsQueueE2C;
//    }else{
//        return self.examContentsQueueS2E;
//    }
//}

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
        [self.view bringSubviewToFront:self.roundNotificatonLabel];
        [UIView animateWithDuration:0.5 animations:^{
            self.roundNotificatonLabel.transform = CGAffineTransformMakeTranslation(0, 0-self.roundNotificatonLabel.frame.origin.y+3);
        } completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.5 delay:2 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.roundNotificatonLabel.transform = CGAffineTransformMakeTranslation(0,0);
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
            NSDate *lastReviewTime = self.wordList.lastReviewTime;
            if (lastReviewTime != nil) {
                NSTimeInterval passedTime = 0 - [lastReviewTime timeIntervalSinceNow];
                if (passedTime > 24*60*60) {
                    //如果距离上次复习时间大于一天，视为有效次数
                    int effictiveCount = [self.wordList.effectiveCount intValue];
                    effictiveCount++;
                    self.wordList.effectiveCount = [NSNumber numberWithInt:effictiveCount];
                    self.wordList.lastReviewTime = [NSDate date]; //设为现在
                }
            }else{
                int effictiveCount = [self.wordList.effectiveCount intValue];
                effictiveCount++;
                self.wordList.effectiveCount = [NSNumber numberWithInt:effictiveCount];
                self.wordList.lastReviewTime = [NSDate date]; //设为现在
            }
            
        }
    }
    ev.content = content;
    self.currentExamContent = content;
    NSLog(@"%d",[content weight]);
    int i = [self.examViewReuseQueue indexOfObject:ev];
    ExamView *oldView = [self.examViewReuseQueue objectAtIndex:++i%2];
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
        Word *word = content.word;
        NSData *pronData = word.pronounceUS;
        if (pronData == nil) {
            pronData = word.pronounceEN;
        }
        if (pronData != nil) {
            self.soundPlayer = [[AVAudioPlayer alloc]initWithData:pronData error:nil];
            [self.soundPlayer play];
        }
    }
}

@end
