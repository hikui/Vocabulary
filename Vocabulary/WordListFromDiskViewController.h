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

//当这个值不为nil时，所有增加的word都进入到此word list中。
@property (nonatomic, strong) WordList *wordList;

- (IBAction)finishButtonOnPress:(id)sender;
- (IBAction)refreshButtonOnPress:(id)sender;

@end
