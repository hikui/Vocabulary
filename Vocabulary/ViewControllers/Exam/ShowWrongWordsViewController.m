
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
//  ShowWrongWordsViewController.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-26.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ShowWrongWordsViewController.h"
#import "VNavigationController.h"

@interface ShowWrongWordsViewController ()

@end

@implementation ShowWrongWordsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"错误单词";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// @Override
- (void)back {
    [self.navigationController.v_navigationManager commonPopToURL:[HKVNavigationRouteConfig sharedInstance].wordListVC animate:YES];
}

@end
