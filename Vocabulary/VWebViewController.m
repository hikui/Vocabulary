
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
//  HelpViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-28.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "VWebViewController.h"
#import "MobClick.h"
#import "VNavigationController.h"

@interface VWebViewController ()

@end

@implementation VWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.toolBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav.png"]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
//    NSString *url = [MobClick getConfigParams:@"helpUrl"];
    NSURLRequest *req = [[NSURLRequest alloc]initWithURL:self.requestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [self.webView loadRequest:req];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)closeButtonOnPress:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)backButtonPressed:(id)sender
{
    [self.webView goBack];
}

- (void)forwardButtonPressed:(id)sender
{
    [self.webView goForward];
}

#pragma mark - webview delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
    [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.webView animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
    [MBProgressHUD hideAllHUDsForView:self.webView animated:YES];
}

@end
