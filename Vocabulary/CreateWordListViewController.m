
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
#import "CoreDataHelper.h"
#import "Word.h"
#import "WordList.h"
#import <QuartzCore/QuartzCore.h>
#import "WordListCreator.h"
#import "UIToolbar+VToolBar.h"
#import "AppDelegate.h"

@interface CreateWordListViewController ()

@property (nonatomic, unsafe_unretained) BOOL firstEdit;

@end

@implementation CreateWordListViewController

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
    _firstEdit = YES;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
//    [notificationCenter addObserver:self selector:@selector(keyboardwillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.textView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.textView.layer.borderWidth = 2.0f;
    self.textView.layer.cornerRadius = 4.0f;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (_firstEdit) {
        textView.text = @"";
    }
    _firstEdit = NO;
    return YES;
}

#pragma mark Receive Notification

- (void)keyboardWillAppear:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    double showAnimationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    CGRect targetKeyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat offsetY = targetKeyboardFrame.size.height;
    [UIView animateWithDuration:showAnimationDuration animations:^{
        self.textView.frame = CGRectMake(20, 116, 280,344-offsetY);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.textView.frame = CGRectMake(20, 116, 280,344);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView resignFirstResponder];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    static CGFloat lastOffset = 0.0f;
//    if (lastOffset > scrollView.contentOffset.y && ![scrollView isDecelerating]) {
//        [scrollView resignFirstResponder];
//    }
//    lastOffset = scrollView.contentOffset.y;
//}

#pragma mark - ibactions
- (IBAction)btnOkPressed:(id)sender
{
    NSString *text = self.textView.text;
    NSArray *words = [text componentsSeparatedByString:@"\n"];
    NSSet *wordSet = [NSSet setWithArray:words]; //remove duplicates
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [WordListCreator createWordListAsyncWithTitle:self.titleField.text wordSet:wordSet completion:^(NSError *error) {
        if (error != NULL) {
            NSLog(@"%@",error);
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
                abort();
            }
            return;
        }else{
//            [((AppDelegate *)[UIApplication sharedApplication].delegate) refreshTodaysPlan];
            [[NSNotificationCenter defaultCenter]postNotificationName:kShouldRefreshTodaysPlanNotificationKey object:nil];
            [self dismissModalViewControllerAnimated:YES];
        }
    }];
    
    

    
}
- (IBAction)btnCancelPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
