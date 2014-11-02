//
//  CibaWebVIew.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-12-17.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CibaWebView : UIView <UIWebViewDelegate>

@property (nonatomic, copy) NSString *word;
@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, unsafe_unretained) CGPoint animationBeginPoint;
@property (nonatomic, unsafe_unretained) CGPoint animationEndPoint;

- (instancetype)initWithView:(UIView *)superView word:(NSString *)word;

- (void)showCibaWebViewAnimated:(BOOL)animated;
- (void)hideCibaWebViewAnimated:(BOOL)animated;
- (void)refresh;

@end
