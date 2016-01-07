
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
#import "WordDetailViewController.h"
#import "VNavigationController.h"
#import "NoteViewController.h"
#import "EditWordDetailViewController.h"

@interface LearningBackboneViewController ()
{
    bool forward;
    BOOL firstAppear;
}

@property (nonatomic, weak) WordDetailViewController *currentShownViewController;

- (void)shuffleWords;

@end

@implementation LearningBackboneViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _learningViewControllerArray = [[NSMutableArray alloc]initWithCapacity:3];
    forward = true;
    firstAppear = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"浏览词汇";
    
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
    self.pageIndicator.text = [NSString stringWithFormat:@"%d/%lu",1,(unsigned long)self.words.count];
    
//    [self showCustomBackButton];

    [self shuffleWords];//每次都乱序
    for (int i = 0; i< MIN(self.words.count, 2); i++) {
        WordDetailViewController *lvc = [[WordDetailViewController alloc]initWithNibName:nil bundle:nil];
        lvc.word = self.words[i];
        if (lvc) {
            [self.learningViewControllerArray addObject:lvc];
        }
    }
    if (self.learningViewControllerArray.count > 0) {
        [self.pageViewController setViewControllers:@[(self.learningViewControllerArray)[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        self.currentShownViewController = (self.learningViewControllerArray)[0];
    }
}

- (void)loadRightBarButtonItems {
    UIBarButtonItem *refreshBtn = [VNavigationController generateItemWithType:VNavItemTypeRefresh target:self action:@selector(refreshButtonOnPress:)];
    UIBarButtonItem *noteBtn = [VNavigationController generateNoteItemWithTarget:self action:@selector(noteButtonOnClick)];
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]initVNavBarButtonItemWithTitle:@"编辑" target:self action:@selector(btnManuallyInfoOnClick:)];
    if ([self.currentShownViewController.word.manuallyInput boolValue]) {
        self.navigationItem.rightBarButtonItems = @[noteBtn,editBtn];
    }else{
        self.navigationItem.rightBarButtonItems = @[noteBtn,refreshBtn];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadRightBarButtonItems];
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
    WordDetailViewController *lvc = (WordDetailViewController *)viewController;
    Word *wd = lvc.word;
    NSUInteger index = [self.words indexOfObject:wd];
    if (index == self.words.count-1) {
        return nil;
    }
    WordDetailViewController *nlvc = (self.learningViewControllerArray)[(index+1)%2];
    nlvc.word = (self.words)[index+1];
    return nlvc;
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
viewControllerBeforeViewController:(UIViewController *)viewController{
    forward = false;
    WordDetailViewController *lvc = (WordDetailViewController *)viewController;
    Word *wd = lvc.word;
    NSUInteger index = [self.words indexOfObject:wd];
    if (index == 0) {
        return nil;
    }
    WordDetailViewController *nlvc = (self.learningViewControllerArray)[(index-1)%2];
    nlvc.word = (self.words)[index-1];
    return nlvc;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished && completed) {
        WordDetailViewController *lvc = (WordDetailViewController *)previousViewControllers[0];
        if ([lvc isKindOfClass:[WordDetailViewController class]]) {
            Word *wd = lvc.word;
            NSUInteger index = [self.words indexOfObject:wd];
            if (forward) {
                self.pageIndicator.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)index+2,(unsigned long)self.words.count];
                self.currentShownViewController = self.learningViewControllerArray[(index+1)%2];
            }else{
                self.pageIndicator.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)index,(unsigned long)self.words.count];
                self.currentShownViewController = self.learningViewControllerArray[(index-1)%2];
            }
            BOOL shouldPerformSound = [[NSUserDefaults standardUserDefaults]boolForKey:kPerformSoundAutomatically];
            if (shouldPerformSound) {
                [self.currentShownViewController playSound];
            }
            [self loadRightBarButtonItems];
        }
    }
}

- (void)shuffleWords
{
    NSUInteger i = [self.words count];
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
        for (WordDetailViewController *lvc in self.learningViewControllerArray) {
            [lvc hideInfo];
        }

    }else{
        btn.title = @"隐藏词义";
        for (WordDetailViewController *lvc in self.learningViewControllerArray) {
            [lvc showInfo];
        }
    }
}


- (void)refreshButtonOnPress:(id)sender
{
    [self.currentShownViewController refreshWordData];
}

- (void)noteButtonOnClick {
    [self.navigationController.v_navigationManager commonPushURL:[HKVNavigationRouteConfig sharedInstance].noteVC params:@{@"word":self.currentShownViewController.word} animate:YES];
}

- (void)btnManuallyInfoOnClick:(id)sender
{
    [self.navigationController.v_navigationManager commonPushURL:[HKVNavigationRouteConfig sharedInstance].editWordDetailVC params:@{@"word":self.currentShownViewController.word} animate:YES];
}

@end
