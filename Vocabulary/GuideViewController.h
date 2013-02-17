//
//  GuideViewController.h
//  Vocabulary
//
//  Created by 缪 和光 on 13-2-17.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Guide;

@interface GuideViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) Guide *guide;

//根据class来生成指定的guide view controller
+ (GuideViewController *)guideViewControllerForClass:(Class)class;
- (void)updateContentSize;

@end
