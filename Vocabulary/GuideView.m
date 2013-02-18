//
//  GuideView.m
//  Vocabulary
//
//  Created by 缪 和光 on 13-2-18.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "GuideView.h"
#import "Guide.h"
#import "WordListFromDiskGuide.h"
#import "WordListFromDiskViewController.h"

@implementation GuideView

+ (id)newGuideView
{
    NSArray *objects = [[NSBundle mainBundle]loadNibNamed:@"GuideView" owner:self options:nil];
    GuideView *guideView = nil;
    for (id object in objects) {
        if ([object isKindOfClass:[GuideView class]]) {
            guideView = (GuideView *)object;
            break;
        }
    }
    return guideView;
}

+ (GuideView *)guideViewForClass:(Class)class
{
    if (class == [WordListFromDiskViewController class]) {
        Guide *guide = [[WordListFromDiskGuide alloc]init];
        GuideView *gv = [GuideView newGuideView];
        gv.guide = guide;
        return gv;
    }
    return nil;
}

- (void)updateContentSize
{
    self.scrollView.contentSize = CGSizeMake(self.guide.guidePictureNameArray.count * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
}

#pragma mark - scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x + self.scrollView.frame.size.width - 10 > self.scrollView.contentSize.width) {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
//        [self removeFromSuperview];
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

- (void)setGuide:(Guide *)guide
{
    _guide = guide;
    
    for (int i=0; i<_guide.guidePictureNameArray.count; i++) {
        UIImage *guidePic = [_guide guidePictureAtIndex:i];
        CGRect imageFrame = self.scrollView.frame;
        imageFrame = CGRectOffset(imageFrame, i * self.scrollView.frame.size.width, 0);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageFrame];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        imageView.image = guidePic;
        [self.scrollView addSubview:imageView];
    }
    self.pageControl.numberOfPages = _guide.guidePictureNameArray.count;
}

- (void)guideWillAppear
{
    NSString *key = self.guide.guideName;
    [[NSUserDefaults standardUserDefaults]setInteger:self.guide.guideVersion forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self updateContentSize];
}

@end
