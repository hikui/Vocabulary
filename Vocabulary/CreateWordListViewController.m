//
//  CreateWordListViewController.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-19.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "CreateWordListViewController.h"
#import "AppDelegate.h"

@interface CreateWordListViewController ()

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
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
//    [notificationCenter addObserver:self selector:@selector(keyboardwillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    static BOOL firstEdit = YES;
    if (firstEdit) {
        textView.text = @"";
    }
    firstEdit = NO;
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
        self.textView.frame = CGRectMake(0, 44, 320,416-offsetY);
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.textView.frame = CGRectMake(0, 44, 320,416);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static CGFloat lastOffset = 0.0f;
    if (lastOffset > scrollView.contentOffset.y && ![scrollView isDecelerating]) {
        [scrollView resignFirstResponder];
    }
    lastOffset = scrollView.contentOffset.y;
}

#pragma mark - ibactions
- (IBAction)btnOkPressed:(id)sender
{
    NSLog(@"ok");
    NSString *text = self.textView.text;
    NSArray *words = [text componentsSeparatedByString:@"\n"];
    NSSet *wordSet = [NSSet setWithArray:words];
    
    
}
- (IBAction)btnCancelPressed:(id)sender
{
    
}

@end
