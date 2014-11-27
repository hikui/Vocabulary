
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
//  ShowWordListViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ExistingWordListsViewController.h"
#import "WordListViewController.h"
#import "AppDelegate.h"
#import "VNavigationController.h"
#import "PureColorImageGenerator.h"
#import "WordListManager.h"

@interface ExistingWordListsViewController ()

- (void)refreshHintView;

@end

@implementation ExistingWordListsViewController

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
    
//    self.banner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    CoreDataHelperV2 *helper = [CoreDataHelperV2 sharedInstance];
//    self.managedObjectContext = helper.mainContext;
    self.title = @"已有的列表";
    self.tableView.backgroundColor = RGBA(227, 227, 227, 1);
    self.tableView.separatorColor = RGBA(210, 210, 210, 1);
    self.view.backgroundColor = RGBA(227, 227, 227, 1);
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    
    menuButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [menuButton setImage:[PureColorImageGenerator generateMenuImageWithTint:RGBA(255, 255, 255, 0.9)] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(revealLeftSidebar:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc]initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = menuBarButton;
    
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc]initVNavBarButtonItemWithTitle:@"编辑" target:self action:@selector(editButtonItemPressed:)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
    
    self.hintView = [[UILabel alloc]initWithFrame:self.view.frame];
    self.hintView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.hintView.font = [UIFont boldSystemFontOfSize:20];
    self.hintView.backgroundColor = GlobalBackgroundColor;
    self.hintView.shadowColor = [UIColor whiteColor];
    self.hintView.shadowOffset = CGSizeMake(0, 1);
    self.hintView.textColor = RGBA(140, 140, 140, 1);
    self.hintView.numberOfLines = 0;
    self.hintView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.hintView];
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
//    int num = [sectionInfo numberOfObjects];
//    if (num == 0) {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"你还没有Word list哦" message:@"请先“增加word list”" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//        [alert show];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
//    self.bannerFrame = CGRectMake(0, self.view.frame.size.height-50, 320, 50);
    [self refreshHintView];
//    self.fetchedResultsController = nil;
//    [self.tableView reloadData];
    [super viewWillAppear:animated];
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
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        WordList *wordListToBeDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [WordListManager deleteWordList:wordListToBeDelete];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    WordListViewController *subVC = [[WordListViewController alloc]initWithNibName:@"WordListViewController" bundle:nil];
    subVC.wordList = (WordList *)object;
    [self.navigationController pushViewController:subVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchedResultsController *aFetchedResultsController = [WordList MR_fetchAllSortedBy:@"title" ascending:YES withPredicate:nil groupBy:nil delegate:self];
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"title"] description];
    NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",[[object valueForKey:@"effectiveCount"] description]];
    cell.detailTextLabel.text = detailTxt;
}


#pragma mark - actions
- (void)revealLeftSidebar:(id)sender {
    [((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController toggleLeftViewAnimated:YES];
}

- (void)editButtonItemPressed:(id)sender
{
    //!!!触发这个方法的实际上是barButtonItem里面的customView，故sender应为UIButton
    if (!self.isEditing) {
        self.editing = YES;
        UIButton *realButton = (UIButton *)sender;
        [realButton setTitle:@"完成" forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];
    }else{
        self.editing = NO;
        UIButton *realButton = (UIButton *)sender;
        [realButton setTitle:@"编辑" forState:UIControlStateNormal];
        [self.tableView setEditing:NO animated:YES];
    }
}

- (void)refreshHintView
{
    NSUInteger wordListCount = [WordList MR_countOfEntities];
    
    self.view.hidden = NO;
    if (wordListCount == 0) {
        self.hintView.text = @"还没有词汇列表哦~\n点击左上角按钮选择添加词汇列表即可添加!";
    }else{
        self.hintView.hidden = YES;
    }
}


@end
