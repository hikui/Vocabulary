//
//  PlanningVIewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-25.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "PlanningVIewController.h"
#import "ShowWordsViewController.h"

@interface PlanningVIewController ()

@property (nonatomic, strong) WordList *todaysPlan;

@end

@implementation PlanningVIewController

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
    self.title = @"今日复习计划";
    NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:ctx];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(effectiveCount==0)"];
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
    NSArray *result = [ctx executeFetchRequest:request error:nil];
    if (result.count > 0) {
        self.todaysPlan = [result objectAtIndex:0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController sections] count];
    if (self.todaysPlan != nil) {
        count ++;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }else if (section == 1) {
        return 1;
    }
    return 0;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = [[object valueForKey:@"title"] description];
        NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",[[object valueForKey:@"effectiveCount"] description]];
        cell.detailTextLabel.text = detailTxt;
    }else{
        cell.textLabel.text = self.todaysPlan.title;
        NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",self.todaysPlan.effectiveCount];
        cell.detailTextLabel.text = detailTxt;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"今日需要复习的Word list";
        case 1:
            return @"今日需要学习的Word list";
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShowWordsViewController *subVC = [[ShowWordsViewController alloc]initWithNibName:@"ShowWordsViewController" bundle:nil];
    if (indexPath.section == 0) {
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        subVC.wordList = (WordList *)object;
    }else{
        subVC.wordList = self.todaysPlan;
    }
    
    [self.navigationController pushViewController:subVC animated:YES];
}

/**
 @override
 */
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:7];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"addTime" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor1];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(effectiveCount>0 AND effectiveCount < 7)"];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"ShowWordList"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}
@end
