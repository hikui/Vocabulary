//
//  ShowWordListViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AdBaseViewController.h"

@interface ShowWordListViewController : AdBaseViewController<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    @protected
    NSFetchedResultsController *_fetchedResultsController;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
