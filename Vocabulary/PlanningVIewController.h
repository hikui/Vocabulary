//
//  PlanningVIewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-25.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowWordListViewController.h"
@interface PlanningVIewController : UITableViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *wordListsArray;

@end
