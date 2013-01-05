//
//  LeftBarViewController.h
//  Vocabulary
//
//  Created by Hikui on 13-1-3.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftBarViewController : UIViewController<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
