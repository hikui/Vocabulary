
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
#import "WordListCreator.h"
#import "AppDelegate.h"
#import "SZTextView.h"

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
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
//    [notificationCenter addObserver:self selector:@selector(keyboardwillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    
    self.textView.placeholder = @"请用空格或换行隔开";
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

- (void)keyboardWillAppear:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect targetKeyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    targetKeyboardFrame = [self.view convertRect:targetKeyboardFrame fromView:window];
    CGFloat offsetY = targetKeyboardFrame.size.height;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, offsetY, 0.0);
    self.textView.contentInset = contentInsets;
    self.textView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.textView.contentInset = contentInsets;
    self.textView.scrollIndicatorInsets = contentInsets;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView resignFirstResponder];
}

#pragma mark - ibactions
- (IBAction)btnOkPressed:(id)sender
{
    NSString *text = self.textView.text;
    NSMutableSet *wordSet = [[NSMutableSet alloc]init];
    NSScanner *scanner = [NSScanner scannerWithString:text];
    NSString *token;
    while ([scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&token]) {
        [wordSet addObject:token];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [WordListCreator createWordListAsyncWithTitle:self.titleField.text wordSet:wordSet completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error != NULL) {
                DDLogError(@"%@",error);
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
//                    abort();
                }
                return;
            }else{
                //            [((AppDelegate *)[UIApplication sharedApplication].delegate) refreshTodaysPlan];
                [[NSNotificationCenter defaultCenter]postNotificationName:kShouldRefreshTodaysPlanNotificationKey object:nil];
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
