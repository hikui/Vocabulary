//
//  LearningViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-21.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Word.h"
@interface LearningViewController : UIViewController

@property (nonatomic,strong) Word *word;
@property (nonatomic,strong) IBOutlet UILabel *lblKey;

- (id)initWithWord:(Word *)word;
- (void)refreshView;
@end
