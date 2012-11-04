//
//  LearningViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "LearningBackboneViewController.h"
#import "LearningViewController.h"

@interface LearningBackboneViewController ()

@property (nonatomic, unsafe_unretained) CGRect originalPageViewFrame;
- (void)shuffleWords;

@end

@implementation LearningBackboneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithWords:(NSMutableArray *)words
{
    self = [super initWithNibName:@"LearningBackboneViewController" bundle:nil];
    if (self) {
        _learningViewControllerArray = [[NSMutableArray alloc]initWithCapacity:3];
        _words = words;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"浏览词汇";
    
    //广告
    self.bannerFrame = CGRectMake(0, -50, 320, 50);
    self.banner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    self.pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.view.backgroundColor = [UIColor redColor];
    CGRect pageViewControllerFrame = self.view.bounds;
    pageViewControllerFrame.size.height = pageViewControllerFrame.size.height-51;
    [[self.pageViewController view] setFrame:pageViewControllerFrame];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    self.pageIndicator.text = [NSString stringWithFormat:@"%d/%d",1,self.words.count];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self shuffleWords];//每次都乱序
    for (int i = 0; i< MIN(self.words.count, 2); i++) {
        LearningViewController *lvc = [[LearningViewController alloc]initWithWord:[self.words objectAtIndex:i]];
        if (lvc) {
            [self.learningViewControllerArray addObject:lvc];
        }
    }
    if (self.learningViewControllerArray.count > 0) {
        [self.pageViewController setViewControllers:@[[self.learningViewControllerArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.originalPageViewFrame = self.pageViewController.view.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

static bool forward = true;

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController{
    forward = true;
    LearningViewController *lvc = (LearningViewController *)viewController;
    Word *wd = lvc.word;
    int index = [self.words indexOfObject:wd];
    if (index == self.words.count-1) {
        return nil;
    }
    LearningViewController *nlvc = [self.learningViewControllerArray objectAtIndex:(index+1)%2];
    nlvc.word = [self.words objectAtIndex:index+1];
    return nlvc;
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
viewControllerBeforeViewController:(UIViewController *)viewController{
    forward = false;
    LearningViewController *lvc = (LearningViewController *)viewController;
    Word *wd = lvc.word;
    int index = [self.words indexOfObject:wd];
    if (index == 0) {
        return nil;
    }
    LearningViewController *nlvc = [self.learningViewControllerArray objectAtIndex:(index-1)%2];
    nlvc.word = [self.words objectAtIndex:index-1];
    return nlvc;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished && completed) {
        LearningViewController *lvc = (LearningViewController *)[previousViewControllers objectAtIndex:0];
        if ([lvc isKindOfClass:[LearningViewController class]]) {
            Word *wd = lvc.word;
            int index = [self.words indexOfObject:wd];
            if (forward) {
                self.pageIndicator.text = [NSString stringWithFormat:@"%d/%d",index+2,self.words.count];
                [self.pageIndicator sizeToFit];
            }else{
                self.pageIndicator.text = [NSString stringWithFormat:@"%d/%d",index,self.words.count];
                [self.pageIndicator sizeToFit];
            }
        }
    }
}

- (void)shuffleWords
{
    int i = [self.words count];
    while(--i > 0) {
        int j = arc4random() % (i+1);
        [self.words exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    
}

#pragma mark - ibactions
- (IBAction)btnShowInfoOnPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    btn.selected = !btn.selected;
    

    for (LearningViewController *lvc in self.learningViewControllerArray) {
        if (!btn.selected) {
            [lvc showInfo];
        }else{
            [lvc hideInfo];
        }

    }
    
    
}

#pragma - mark GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    [super adViewDidReceiveAd:view];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect targetFrame = self.originalPageViewFrame;
        targetFrame.origin.y = 50;
        targetFrame.size.height -= 50;
        self.pageViewController.view.frame = targetFrame;
        self.banner.transform = CGAffineTransformMakeTranslation(0, 50);
    }];
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error
{
    [super adView:view didFailToReceiveAdWithError:error];
    [UIView animateWithDuration:0.5 animations:^{
        self.pageViewController.view.frame = self.originalPageViewFrame;
        self.banner.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}

@end
