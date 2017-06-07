
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
//  CreateWordListViewController.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-19.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "CreateWordListViewController.h"
#import "WordListManager.h"
#import "AppDelegate.h"
#import "SZTextView.h"
@import MBProgressHUD;

@interface CreateWordListViewController ()

@property (nonatomic, unsafe_unretained) BOOL firstEdit;
@property (nonatomic, unsafe_unretained) CGFloat originalTextViewHeight;

@end

@implementation CreateWordListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    _firstEdit = YES;
    UILabel *titleHint = [[UILabel alloc]init];
    titleHint.text = @"起个名字吧: ";
    titleHint.textColor = RGBA(99, 99, 99, 1);
    titleHint.font = [UIFont systemFontOfSize:14];
    titleHint.backgroundColor = [UIColor clearColor];
    titleHint.textAlignment = NSTextAlignmentCenter;
    [titleHint sizeToFit];
    titleHint.frame = CGRectMake(0, 0, titleHint.frame.size.width+16, titleHint.frame.size.height);
    self.titleField.leftView = titleHint;
    self.titleField.leftViewMode = UITextFieldViewModeAlways;
    
    self.textView.placeholder = @"每行一个单词";
    self.respondScrollView = self.textView;
}

- (void)viewDidAppear:(BOOL)animated {
    self.originalTextViewHeight = self.textView.frame.size.height;
    [self.titleField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.titleField resignFirstResponder];
    [self.textView resignFirstResponder];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark Receive Notification

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView resignFirstResponder];
}

#pragma mark - ibactions
- (IBAction)btnOkPressed:(id)sender
{
    NSSet *wordSet = [WordListManager wordSetFromContent:self.textView.text];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [WordListManager createWordListAsyncWithTitle:self.titleField.text wordSet:wordSet completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error != NULL) {
//                DDLogError(@"%@",error);
                if (error.code == WordListCreatorEmptyWordSetError) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:@"还没有单词哦"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"知道了"
                                                         otherButtonTitles:nil];
                    [alert show];
                }else if (error.code == WordListCreatorNoTitleError){
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:@"还没有起名字哦"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"知道了"
                                                         otherButtonTitles:nil];
                    [alert show];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:@"发生了错误"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"知道了"
                                                         otherButtonTitles:nil];
                    [alert show];
                }
                return;
            }else{
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
        });
        
    }];
    
    

    
}
- (IBAction)btnCancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
