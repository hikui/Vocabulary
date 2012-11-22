//
//  SearchWordViewController.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-11-22.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "SearchWordViewController.h"
#import "LearningViewController.h"

@interface SearchWordViewController ()

@property (nonatomic, strong) NSFetchRequest *fetchRequest;

- (void) addQueryOperation:(NSOperation *)operation;
- (NSOperation *) makeQueryOperationWithText:(NSString *)text;

@end

@implementation SearchWordViewController

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

    self.navigationController.navigationBar.tintColor = RGBA(48, 16, 17, 1);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.hidesWhenStopped = YES;
    UIBarButtonItem *indicatorItem = [[UIBarButtonItem alloc]initWithCustomView:indicator];
    self.navigationItem.rightBarButtonItem = indicatorItem;
    
    self.title = @"查找已有单词";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.queryOperationQueue = [[NSOperationQueue alloc]init];
    self.queryOperationQueue.maxConcurrentOperationCount = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - table view delegate and data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Word *w = [self.contentsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = w.key;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Word *w = [self.contentsArray objectAtIndex:indexPath.row];
    LearningViewController *lvc = [[LearningViewController alloc]initWithWord:w];
    [self.navigationController pushViewController:lvc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBar delegate

- (NSOperation *) makeQueryOperationWithText:(NSString *)text
{
    if (text.length == 0) {
        return nil;
    }
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator startAnimating];
        });
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(key CONTAINS %@)",text];
        [self.fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance]managedObjectContext];
        NSArray * result = [ctx executeFetchRequest:self.fetchRequest error:&error];
        if (error) {
            NSLog(@"%@",error);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contentsArray = result;
            [self.tableView reloadData];
            [indicator stopAnimating];
        });
    }];
    return operation;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@",searchText);
    
    if (self.fetchRequest == nil) {
        NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance]managedObjectContext];
        self.fetchRequest = [[NSFetchRequest alloc]init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:ctx];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
        [self.fetchRequest setEntity:entity];
        [self.fetchRequest setSortDescriptors:@[sort]];
    }
    NSOperation *op = [self makeQueryOperationWithText:searchText];
    
    //制造延时，并发查找
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(addQueryOperation:) withObject:op afterDelay:0.8];
    
    //立即清空
    if (searchText.length == 0) {
        self.contentsArray = nil;
        [self.tableView reloadData];
    }
}

#pragma mark - search action
- (void)addQueryOperation:(NSOperation *)operation
{
    [self.queryOperationQueue cancelAllOperations];
    if (operation != nil) {
        [self.queryOperationQueue addOperation:operation];
    }
}

#pragma mark - ibactions
- (void)back:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - keyboard things
- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up {
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.tableView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
//    keyboardFrame.size.height -= tabBarController.tabBar.frame.size.height;
    newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
    self.tableView.frame = newFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:NO];
}

@end
