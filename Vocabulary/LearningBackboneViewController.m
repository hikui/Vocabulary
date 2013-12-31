
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
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "LearningBackboneViewController.h"
#import "LearningViewController.h"
#import "SearchWordViewController.h"
#import "VNavigationController.h"

@interface LearningBackboneViewController ()
{
    bool forward;
    BOOL firstAppear;
}

@property (nonatomic, weak) LearningViewController *currentShownViewController;

- (void)shuffleWords;

- (void)searchButtonOnPress:(id)sender;

@end

@implementation LearningBackboneViewController


- (id)initWithWords:(NSMutableArray *)words
{
    self = [super initWithNibName:@"LearningBackboneViewController" bundle:nil];
    if (self) {
        _learningViewControllerArray = [[NSMutableArray alloc]initWithCapacity:3];
        _words = [words mutableCopy];
        forward = true;
        firstAppear = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"浏览词汇";
    
    self.pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.view.backgroundColor = RGBA(227, 227, 227, 1);
    self.view.backgroundColor = RGBA(227, 227, 227, 1);
    CGRect pageViewControllerFrame = self.view.bounds;
    pageViewControllerFrame.size.height = pageViewControllerFrame.size.height-51;
    [[self.pageViewController view] setFrame:pageViewControllerFrame];
    self.pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.pageIndicator.text = [NSString stringWithFormat:@"%d/%d",1,self.words.count];
    
    UIBarButtonItem *backBtn = [VNavigationController generateBackItemWithTarget:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backBtn;
    
//    UIBarButtonItem *searchButton = [VNavigationController generateSearchItemWithTarget:self action:@selector(searchButtonOnPress:)];
//    
//    self.navigationItem.rightBarButtonItem = searchButton;
    
    UIBarButtonItem *refreshButtonItem = [VNavigationController generateItemWithType:VNavItemTypeRefresh target:self action:@selector(refreshButtonOnPress:)];
    self.navigationItem.rightBarButtonItem = refreshButtonItem;

    [self shuffleWords];//每次都乱序
    for (int i = 0; i< MIN(self.words.count, 2); i++) {
        LearningViewController *lvc = [[LearningViewController alloc]initWithWord:[self.words objectAtIndex:i]];
        if (lvc) {
            [self.learningViewControllerArray addObject:lvc];
        }
    }
    if (self.learningViewControllerArray.count > 0) {
        [self.pageViewController setViewControllers:@[[self.learningViewControllerArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        self.currentShownViewController = [self.learningViewControllerArray objectAtIndex:0];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"Learning"];
    //必须手动为第一页播放声音。其余页在翻页结束的时候触发播放声音。
    if (firstAppear) /*避免在左边栏search word时发声*/{
        BOOL shouldPerformSound = [[NSUserDefaults standardUserDefaults]boolForKey:kPerformSoundAutomatically];
        if (shouldPerformSound) {
            [self.currentShownViewController playSound];
        }
    }
    firstAppear = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"Learning"];
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
                self.currentShownViewController = self.learningViewControllerArray[(index+1)%2];
            }else{
                self.pageIndicator.text = [NSString stringWithFormat:@"%d/%d",index,self.words.count];
                self.currentShownViewController = self.learningViewControllerArray[(index-1)%2];
            }
            BOOL shouldPerformSound = [[NSUserDefaults standardUserDefaults]boolForKey:kPerformSoundAutomatically];
            if (shouldPerformSound) {
                [self.currentShownViewController playSound];
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
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    if ([btn.title isEqualToString:@"隐藏词义"]) {
        btn.title = @"显示词义";
        for (LearningViewController *lvc in self.learningViewControllerArray) {
            [lvc hideInfo];
        }

    }else{
        btn.title = @"隐藏词义";
        for (LearningViewController *lvc in self.learningViewControllerArray) {
            [lvc showInfo];
        }
    }
}

- (void)searchButtonOnPress:(id)sender
{
    SearchWordViewController *svc = [[SearchWordViewController alloc]initWithModalViewControllerMode:YES];
    VNavigationController *nsvc = [[VNavigationController alloc]initWithRootViewController:svc];
    nsvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:nsvc animated:YES];
}

- (void)refreshButtonOnPress:(id)sender
{
    [self.currentShownViewController refreshWordData];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
