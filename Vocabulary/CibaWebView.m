//
//  CibaWebVIew.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-12-17.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "CibaWebView.h"
#import <QuartzCore/QuartzCore.h> 

#define margin 15

#define CIBA_URL(__W__) [NSString stringWithFormat:@"http://wap.iciba.com/cword/%@", __W__]

#define HKVPointNull CGPointMake(MAXFLOAT, MAXFLOAT)

@interface CibaWebView()

@property (nonatomic, weak) UIButton *closeButton;

@end

@implementation CibaWebView

- (id)initWithView:(UIView *)superView word:(NSString *)word;
{
    self = [super init];
    if (self) {
        _word = [word copy];
        _parentView = superView;
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
        [_closeButton setFrame:CGRectMake(0, 0, 40, 40)];
        [_closeButton addTarget:self action:@selector(hideCibaWebViewWithAnimation) forControlEvents:UIControlEventTouchUpInside];
        
        _webView = [[UIWebView alloc]init];
        _webView.delegate = self;
        _webView.clipsToBounds = YES;
        [_webView.layer setCornerRadius:5.0];
        [_webView.layer setBorderWidth:5];
        UIColor *borderColor = RGBA(200, 200, 200, 1);
        [_webView.layer setBorderColor:borderColor.CGColor];
        
        [self addSubview:_webView];
        [self addSubview:_closeButton];
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _animationBeginPoint = HKVPointNull;
        _animationEndPoint = CGPointMake(superView.frame.size.width/2.0, superView.frame.size.height/2.0);
    }
    return self;
}

- (void)showCibaWebViewAnimated:(BOOL)animated
{
    [self adjustFrame];
    [self.parentView addSubview:self];
    
    if (animated) {
        self.transform = CGAffineTransformMakeScale(0.0, 0.0);
        if (!CGPointEqualToPoint(self.animationBeginPoint, HKVPointNull)) {
            self.center = self.animationBeginPoint;
        }
        self.alpha = 0.0;
        [UIView animateWithDuration:0.4 animations:^{
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.alpha = 1.0;
            self.center = self.animationEndPoint;
        }];
        
    }
    
    [self refresh];
}

- (void)hideCibaWebViewAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.4 animations:^{
            self.transform = CGAffineTransformMakeScale(0.0, 0.0);
            if (!CGPointEqualToPoint(self.animationBeginPoint, HKVPointNull)) {
                self.center = self.animationBeginPoint;
            }
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else{
        [self removeFromSuperview];
    }
}

- (void)refresh
{
    NSURL *url = [NSURL URLWithString:CIBA_URL(self.word)];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0];
    [self.webView loadRequest:request];
}


#pragma mark - web view delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:self animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
}

#pragma mark - private methods
- (void)adjustFrame
{
    self.frame = CGRectMake(0, 0, self.parentView.frame.size.width, self.parentView.frame.size.height);
    self.webView.frame = CGRectMake(margin, margin, self.frame.size.width-2*margin, self.frame.size.height-2*margin);
    self.closeButton.center = CGPointMake(self.webView.frame.size.width+10, self.webView.frame.origin.y+10);
}

- (void)hideCibaWebViewWithAnimation
{
    [self hideCibaWebViewAnimated:YES];
}

@end
