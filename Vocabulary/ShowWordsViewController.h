//
//  ShowWordsViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordList.h"
@interface ShowWordsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *wordsSet;
@property (strong, nonatomic) WordList *wordList;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *beginStudyButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *beginTestButton;

- (IBAction)btnBeginStudyOnPress:(id)sender;
- (IBAction)btnBeginTestOnPress:(id)sender;

@end
