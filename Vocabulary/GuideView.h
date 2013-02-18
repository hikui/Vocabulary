//
//  GuideView.h
//  Vocabulary
//
//  Created by 缪 和光 on 13-2-18.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "Guide.h"

@class Guide;

@interface GuideView : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) Guide *guide;

+ (GuideView *)guideViewForClass:(Class)class;
- (void)updateContentSize;
- (void)guideWillAppear;

@end
