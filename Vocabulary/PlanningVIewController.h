//
//  PlanningVIewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-25.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowWordListViewController.h"
#import "AdBaseViewController.h"
@interface PlanningVIewController : AdBaseViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *wordListsArray;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
