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
    
    UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:1000];
    toolbar.tintColor = RGBA(48, 16, 17, 1);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    NSString *text = self.textView.text;
    NSArray *words = [text componentsSeparatedByString:@"\n"];
    NSSet *wordSet = [NSSet setWithArray:words]; //remove duplicates
    NSError *error = NULL;
    [WordListCreator createWordListWithTitle:self.titleField.text wordSet:wordSet error:&error];
    if (error != NULL) {
        NSLog(@"%@",[error localizedDescription]);
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
        }
        return;
    }else{
        [self dismissModalViewControllerAnimated:YES];
    }

    
}
- (IBAction)btnCancelPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
