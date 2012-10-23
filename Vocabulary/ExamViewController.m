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

@property (nonatomic, unsafe_unretained)BOOL animationLock;

- (ExamView *)pickAnExamView;
- (NSMutableArray *)choseExamContentQueueRandomly;
- (void)shuffleMutableArray:(NSMutableArray *)array;
- (void)prepareNextExamView;

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
    ev1.frame = CGRectMake(0, 0, 320, self.view.bounds.size.height-44);
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
        _cursor1 = ++_cursor1 % self.examContentsQueueE2C.count;
    }else{
        content = [self.examContentsQueueS2E objectAtIndex:_cursor2];
        _cursor2 = ++_cursor2 % self.examContentsQueueS2E.count;
    }
    ev1.content = content;
    [self.view addSubview:ev2];
    [self.view addSubview:ev1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    [self prepareNextExamView];
}

- (IBAction)wrongButtonOnPress:(id)sender
{
    self.rightButton.enabled = YES;
}

#pragma mark - private methods
- (ExamView *)pickAnExamView
{
    static int i = 1;
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
    int rand = arc4random() % 2;
    ExamContent *content = nil;
    if (rand == 0) {
        content = [self.examContentsQueueE2C objectAtIndex:_cursor1];
        _cursor1 = ++_cursor1 % self.examContentsQueueE2C.count;
    }else{
        content = [self.examContentsQueueS2E objectAtIndex:_cursor2];
        _cursor2 = ++_cursor2 % self.examContentsQueueS2E.count;
    }
    ev.content = content;
    int i = [self.examViewReuseQueue indexOfObject:ev];
    ExamView *oldView = [self.examViewReuseQueue objectAtIndex:++i%2];
    [self.view insertSubview:ev belowSubview:oldView];
    [UIView animateWithDuration:1 animations:^{
        _animationLock = YES;
        CGFloat width = oldView.bounds.size.width;
        oldView.transform = CGAffineTransformMakeTranslation(-width, 0);
    } completion:^(BOOL finished) {
        oldView.transform = CGAffineTransformMakeTranslation(0, 0);
        [self.view insertSubview:oldView belowSubview:ev];
        _animationLock = NO;
    }];
    
    
}

@end
