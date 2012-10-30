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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    NSLog(@"ok");
    NSString *text = self.textView.text;
    if ([text isEqualToString:@"一行一个词"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:@"还没有单词哦"
                                                      delegate:nil
                                             cancelButtonTitle:@"知道了"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
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
    newList.addTime = [NSDate date];
    
    
    NSFetchRequest *wordRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *wordEntity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:moc];
    [wordRequest setEntity:wordEntity];
    for (NSString *aWord in wordSet) {
        if (aWord.length == 0) {
            continue;
        }
        NSString *lowercaseWord = [aWord lowercaseString];
        lowercaseWord = [lowercaseWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //检查是否已经存在这个单词
        NSPredicate *wordPredicate = [NSPredicate predicateWithFormat:@"(key == %@)",lowercaseWord];
        [wordRequest setPredicate:wordPredicate];
        NSArray *resultWords = [moc executeFetchRequest:request error:nil];
        if (resultWords.count > 0) {
            //存在，直接添加
            Word *w = [resultWords objectAtIndex:0];
            [newList addWordsObject:w];
        }else{
            //不存在，新建
            Word *newWord = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:moc];
            newWord.key = lowercaseWord;
            [[newList mutableSetValueForKey:@"words"]addObject:newWord];
        }
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
