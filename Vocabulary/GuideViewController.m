//
//  GuideViewController.m
//  Vocabulary
//
//  Created by 缪 和光 on 13-2-17.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "GuideViewController.h"
#import "Guide.h"
#import "WordListFromDiskGuide.h"
#import "WordListFromDiskViewController.h"

@interface GuideViewController ()
@end

@implementation GuideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (int i=0; i<self.guide.guidePictureNameArray.count; i++) {
        UIImage *guidePic = [self.guide guidePictureAtIndex:i];
        CGRect imageFrame = self.scrollView.frame;
        imageFrame = CGRectOffset(imageFrame, i * self.scrollView.frame.size.width, 0);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageFrame];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        imageView.image = guidePic;
        [self.scrollView addSubview:imageView];
    }
    self.scrollView.contentSize = CGSizeMake(self.guide.guidePictureNameArray.count * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.pageControl.numberOfPages = self.guide.guidePictureNameArray.count;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *key = self.guide.guideName;
    [[NSUserDefaults standardUserDefaults]setInteger:self.guide.guideVersion forKey:key];
    [self updateContentSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPageControl:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)updateContentSize
{
    self.scrollView.contentSize = CGSizeMake(self.guide.guidePictureNameArray.count * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
}

#pragma mark - scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x + self.scrollView.frame.size.width > self.scrollView.contentSize.width) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [self didMoveToParentViewController:nil];
    }
    CGFloat pageWith = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWith;
    NSInteger page = -1;
    if (fractionalPage - (float)self.pageControl.currentPage > 0) {
        // page forward
        page = (int)(fractionalPage);
    }else{
        // page backword
        page = (int)(ceilf(fractionalPage));
    }
    self.pageControl.currentPage = page;
}

#pragma mark - auto init
+ (GuideViewController *)guideViewControllerForClass:(Class)class
{
    if (class == [WordListFromDiskViewController class]) {
        Guide *guide = [[WordListFromDiskGuide alloc]init];
        GuideViewController *vc = [[GuideViewController alloc]initWithNibName:@"GuideViewController" bundle:nil];
        vc.guide = guide;
        return vc;
    }
    return nil;
}


@end
