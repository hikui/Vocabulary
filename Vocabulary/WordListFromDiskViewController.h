
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
//  WordListFromDiskViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-11-3.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordListFromDiskViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

//当这个值不为nil时，所有增加的word都进入到此word list中。
@property (nonatomic, strong) WordList *wordList;

- (IBAction)finishButtonOnPress:(id)sender;
- (IBAction)refreshButtonOnPress:(id)sender;
- (IBAction)clearAllFilesButtonPressed:(id)sender;
- (void)clearAllFiles;

@end
