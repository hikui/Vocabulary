
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
//  ShowWordsViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordList.h"
@interface ShowWordsViewController : VBaseViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addWordButton;
@property (strong, nonatomic) NSMutableArray *wordsSet;
@property (strong, nonatomic) WordList *wordList;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *beginStudyButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *beginTestButton;

@property (assign, nonatomic, getter = isTopLevel) BOOL topLevel;

- (IBAction)btnBeginStudyOnPress:(id)sender;
- (IBAction)btnBeginTestOnPress:(id)sender;
- (IBAction)btnAddWordOnPress:(id)sender;
@end
