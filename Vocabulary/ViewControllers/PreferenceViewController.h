
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
//  ConfigViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-11-1.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface PreferenceViewController : UITableViewController<MFMailComposeViewControllerDelegate>

@property (nonatomic, unsafe_unretained) BOOL notificationEnabled;
@property (nonatomic, strong) NSDate *dayNotificationTime;
@property (nonatomic, strong) NSDate *nightNotificationTime;

@end
