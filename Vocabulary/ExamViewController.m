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
- (NSMutableArray *)choseExamContentQueueRandomly;
- (void)shuffleMutableArray:(NSMutableArray *)array;
- (void)prepareNextExamView;

- (void)examViewExchangeDidFinish:(ExamView *)currExamView;

@end

@implementation ExamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _examContentsQueueE2C = [[NSMutableArray alloc]init];
        _examContentsQueueS2E = [[NSMutableArray alloc]init];
        _examViewReuseQueue = [[NSMutableArray alloc]initWithCapacity:2];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cursor1 = 0;
    _cursor2 = 0;
    
    //create examContents
    for (Word *word in self.wordsArray) {
        ExamContent *contentE2C = [[ExamContent alloc]initWithWord:word examType:ExamTypeE2C];
        [self.examContentsQueueE2C addObject:contentE2C];
        if ( word.pronounceUS != nil || word.pronounceEN != nil) {
            ExamContent *contentS2E = [[ExamContent alloc]initWithWord:word examType:ExamTypeS2E];
            [self.examContentsQueueS2E addObject:contentS2E];
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
    [self shuffleMutableArray:self.examContentsQueueE2C];
    [self shuffleMutableArray:self.examContentsQueueS2E];
    
    int rand = arc4random() % 2;
    ExamContent *content = nil;
    if (rand == 0) {
        content = [self.examContentsQueueE2C objectAtIndex:_cursor1];
        _cursor1 = ++_cursor1;
    }else{
        content = [self.examContentsQueueS2E objectAtIndex:_cursor2];
        _cursor2 = ++_cursor2;
    }
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
    for (ExamContent *c1 in self.examContentsQueueE2C) {
        int rightCount = c1.rightTimes;
        int wrongCount = c1.wrongTimes;
        for (int i = 0; i<self.examContentsQueueS2E.count; i++) {
            ExamContent *c2 = [self.examContentsQueueS2E objectAtIndex:i];
            if (c2.word == c1.word) {
                rightCount += c2.rightTimes;
                wrongCount += c2.wrongTimes;
                break;
            }
        }
        float familiarity = 0;
        if (rightCount != 0 || wrongCount != 0) {
            familiarity = ((float)(rightCount))/(rightCount+wrongCount);
        }
        int familiarityInt = (int)(familiarity *10);
        c1.word.familiarity = [NSNumber numberWithInt:familiarityInt];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

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

- (NSMutableArray *)choseExamContentQueueRandomly
{
    int index = arc4random() % 2;
    if (index == 0) {
        return self.examContentsQueueE2C;
    }else{
        return self.examContentsQueueS2E;
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
    int rand = arc4random() % 2;
    ExamContent *content = nil;
    if (rand == 0) {
        content = [self.examContentsQueueE2C objectAtIndex:_cursor1];
        _cursor1 = ++_cursor1 % self.examContentsQueueE2C.count;
        if (_cursor1 == 0) {
            //已循环一遍了，根据权重排序
            [self.examContentsQueueE2C sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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
//            NSLog(@"E2C sorted");
//            for (ExamContent *c in self.examContentsQueueE2C) {
//                NSLog(@"weight:%d",[c weight]);
//            }
        }
    }else{
        content = [self.examContentsQueueS2E objectAtIndex:_cursor2];
        _cursor2 = ++_cursor2 % self.examContentsQueueS2E.count;
        if (_cursor1 == 0) {
            //已循环一遍了，根据权重排序
            [self.examContentsQueueS2E sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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
//            NSLog(@"S2E sorted");
//            for (ExamContent *c in self.examContentsQueueS2E) {
//                NSLog(@"weight:%d",[c weight]);
//            }
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
