//
//  VKeyboardAwarenessViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12/17/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "VKeyboardAwarenessViewController.h"

@interface VKeyboardAwarenessViewController ()

@end

@implementation VKeyboardAwarenessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardIsShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardIsHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - keyboard
- (void)keyboardIsShown:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect targetKeyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    targetKeyboardFrame = [self.view convertRect:targetKeyboardFrame fromView:nil];
    CGFloat offsetY = CGRectGetMaxY(self.respondScrollView.frame) - CGRectGetMinY(targetKeyboardFrame);
    UIEdgeInsets contentInsets = self.defaultTextViewInset;
    contentInsets.bottom = offsetY;
    self.respondScrollView.contentInset = contentInsets;
    self.respondScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardIsHidden:(NSNotification *)notification {
    UIEdgeInsets contentInsets = self.defaultTextViewInset;
    self.respondScrollView.contentInset = contentInsets;
    self.respondScrollView.scrollIndicatorInsets = contentInsets;
}

@end
