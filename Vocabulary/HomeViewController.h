//
//  HomeViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *countLabel;

- (IBAction)btnSelected:(id)sender;
- (IBAction)infoButtonOnPress:(id)sender;

@end
