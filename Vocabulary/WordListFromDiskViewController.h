//
//  WordListFromDiskViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-11-3.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordListFromDiskViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction)finishButtonOnPress:(id)sender;
- (IBAction)refreshButtonOnPress:(id)sender;

@end
