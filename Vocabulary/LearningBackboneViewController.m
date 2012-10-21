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

- (id)initWithWords:(NSArray *)words
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
    
    
    UIPageViewController *pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageViewController.view.backgroundColor = [UIColor redColor];
    [[pageViewController view] setFrame:[[self view] bounds]];
    [self addChildViewController:pageViewController];
    [self.view addSubview:pageViewController.view];
    [pageViewController didMoveToParentViewController:self];
    pageViewController.dataSource = self;
    pageViewController.delegate = self;
    
    
    //只使用3个LVC，代表当前页，前页和后页
    for (int i = 0; i< MIN(self.words.count, 2); i++) {
        LearningViewController *lvc = [[LearningViewController alloc]initWithWord:[self.words objectAtIndex:i]];
        if (lvc) {
            [self.learningViewControllerArray addObject:lvc];
        }
    }
    if (self.learningViewControllerArray.count > 0) {
        [pageViewController setViewControllers:@[[self.learningViewControllerArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController{
    LearningViewController *lvc = (LearningViewController *)viewController;
    Word *wd = lvc.word;
    int index = [self.words indexOfObject:wd];
    if (index == self.words.count-1) {
        return nil;
    }
    return [self.learningViewControllerArray objectAtIndex:(index+1)%2];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
viewControllerBeforeViewController:(UIViewController *)viewController{
    LearningViewController *lvc = (LearningViewController *)viewController;
    Word *wd = lvc.word;
    int index = [self.words indexOfObject:wd];
    if (index == 0) {
        return nil;
    }
    return [self.learningViewControllerArray objectAtIndex:(index-1)%2];
}


@end
