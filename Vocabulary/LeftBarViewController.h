//
//  LeftBarViewController.h
//  Vocabulary
//
//  Created by Hikui on 13-1-3.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordSearcher.h"

@interface LeftBarViewController : UIViewController<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *searchResultTableView;
@property (nonatomic, strong) NSArray *searchResult;
@property (nonatomic, strong) WordSearcher *searcher;

@end
