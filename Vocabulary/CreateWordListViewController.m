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
    NSLog(@"ok");
    NSString *text = self.textView.text;
    NSArray *words = [text componentsSeparatedByString:@"\n"];
    NSSet *wordSet = [NSSet setWithArray:words]; //remove duplications
    
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    NSManagedObjectContext *moc = helper.managedObjectContext;
    
    
    //search if a word list with same title already exist
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"WordList"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@",self.titleField.text];
    [request setPredicate:predicate];
    NSArray *result = [moc executeFetchRequest:request error:nil];
    if (result.count>0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:@"Word list名字重复啦"
                                                      delegate:nil
                                             cancelButtonTitle:@"知道了"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    WordList *newList = [NSEntityDescription insertNewObjectForEntityForName:@"WordList" inManagedObjectContext:moc];
    newList.title = self.titleField.text;
    
    for (NSString *aWord in wordSet) {
        if (aWord.length == 0) {
            continue;
        }
        NSString *lowercaseWord = [aWord lowercaseString];
        lowercaseWord = [lowercaseWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        Word *newWord = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:moc];
        newWord.key = lowercaseWord;
        newWord.wordList = newList;
    }
    if (newList.words.count>0) {
        [helper saveContext];
        [self dismissModalViewControllerAnimated:YES];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:@"还没有单词哦"
                                                      delegate:nil
                                             cancelButtonTitle:@"知道了"
                                             otherButtonTitles:nil];
        [alert show];
        [moc deleteObject:newList];
    }
    
}
- (IBAction)btnCancelPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
