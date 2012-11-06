//
//  LearningViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordList.h"
@interface LearningBackboneViewController : UIViewController <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic,strong) NSMutableArray *learningViewControllerArray;
@property (nonatomic,copy) NSMutableArray * words;
@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic,strong) IBOutlet UILabel *pageIndicator;

- (id)initWithWords:(NSMutableArray *)words;
- (IBAction)btnShowInfoOnPressed:(id)sender;
@end
