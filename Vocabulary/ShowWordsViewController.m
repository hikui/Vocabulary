//
//  ShowWordsViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ShowWordsViewController.h"
#import "Word.h"
#import "LearningBackboneViewController.h"
#import "LearningViewController.h"
#import "ExamViewController.h"
#import "ConfusingWordsIndexer.h"

@interface ShowWordsViewController ()

@end

@implementation ShowWordsViewController

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
    if (self.wordList != nil) {
        NSMutableArray *words = [[NSMutableArray alloc]initWithCapacity:self.wordList.words.count];
        for (Word *w in self.wordList.words) {
            [words addObject:w];
        }
        self.wordsSet = words;
    }else{
        self.addWordButton.enabled = NO;
    }
    [_wordsSet sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Word *wobj1 = (Word *)obj1;
        Word *wobj2 = (Word *)obj2;
        return [wobj1.key compare:wobj2.key];
    }];
    self.tableView.backgroundColor = RGBA(227, 227, 227, 1);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (self.wordsSet.count == 0) {
        self.beginStudyButton.enabled = NO;
        self.beginTestButton.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[CoreDataHelper sharedInstance]saveContext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.wordsSet.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Word *w = [self.wordsSet objectAtIndex:indexPath.row];
    cell.textLabel.text = w.key;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"熟悉度: %@/10",w.familiarity];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Word *w = [self.wordsSet objectAtIndex:indexPath.row];
    LearningViewController *lvc = [[LearningViewController alloc]initWithWord:w];
    [self.navigationController pushViewController:lvc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger row = indexPath.row;
        Word *wordShouldBeDeleted = [self.wordsSet objectAtIndex:row];
        for (NSUInteger i=row; i<self.wordsSet.count-1; i++) {
            [self.wordsSet replaceObjectAtIndex:i withObject:[self.wordsSet objectAtIndex:i+1]];
        }
        [self.wordsSet removeLastObject];
        NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance]managedObjectContext];
        [ctx deleteObject:wordShouldBeDeleted];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [_tableView endUpdates];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if (editing == NO) {
        [[CoreDataHelper sharedInstance]saveContext];
    }
}

#pragma mark - tool bar actions
- (IBAction)btnBeginStudyOnPress:(id)sender
{
    LearningBackboneViewController *lvc = [[LearningBackboneViewController alloc]initWithWords:self.wordsSet];
    [self.navigationController pushViewController:lvc animated:YES];
}
- (IBAction)btnBeginTestOnPress:(id)sender
{
    ExamViewController *evc = nil;
    if (self.wordList != nil) {
        evc = [[ExamViewController alloc]initWithWordList:self.wordList];
    }else{
        evc = [[ExamViewController alloc]initWithWordArray:self.wordsSet];
    }
    
    [self.navigationController pushViewController:evc animated:YES];
}

- (IBAction)btnAddWordOnPress:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"增加一个单词" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"确定"]) {
        NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance]managedObjectContext];
        Word *w = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:ctx];
        w.key = [[alertView textFieldAtIndex:0]text];
        [w addWordListsObject:self.wordList];
        [ctx save:nil];
        [self.wordsSet addObject:w];
        [_tableView beginUpdates];
        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:self.wordsSet.count-1 inSection:0];
        [_tableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
        
        //后台做索引
        
        [ConfusingWordsIndexer indexNewWordsAsyncById:@[w.objectID] completion:NULL];
        
    }
}



@end
