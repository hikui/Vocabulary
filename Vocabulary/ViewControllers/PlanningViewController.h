
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
//  PlanningVIewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-25.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExistingWordListsViewController.h"
#import "Plan.h"
@interface PlanningViewController : VBaseViewController

@property (nonatomic, strong) Plan *todaysPlan;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *hintView;

@end
