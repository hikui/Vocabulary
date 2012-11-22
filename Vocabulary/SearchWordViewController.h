//
//  SearchWordViewController.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-11-22.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchWordViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>


@property (nonatomic, copy) NSArray *contentsArray;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSOperationQueue *queryOperationQueue;

- (IBAction)back:(id)sender;

@end
