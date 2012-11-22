//
//  ConfigViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-11-1.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ConfigViewController : UITableViewController<MFMailComposeViewControllerDelegate>

@property (nonatomic, unsafe_unretained) BOOL notificationEnabled;
@property (nonatomic, strong) NSDate *dayNotificationTime;
@property (nonatomic, strong) NSDate *nightNotificationTime;

@end
