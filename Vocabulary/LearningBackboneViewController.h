//
//  LearningViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordList.h"
#import "AdBaseViewController.h"
@interface LearningBackboneViewController : AdBaseViewController <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic,strong) NSMutableArray *learningViewControllerArray;
@property (nonatomic,strong) NSMutableArray * words;
@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic,strong) IBOutlet UILabel *pageIndicator;

- (id)initWithWords:(NSMutableArray *)words;
- (IBAction)btnShowInfoOnPressed:(id)sender;
@end
