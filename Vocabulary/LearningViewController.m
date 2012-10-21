//
//  LearningViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-21.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "LearningViewController.h"

@interface LearningViewController ()

@end

@implementation LearningViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblKey.text = self.word.key;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setWord:(Word *)word
{
    _word = word;
    [self refreshView];
}

- (id)initWithWord:(Word *)word
{
    self = [super initWithNibName:@"LearningViewController" bundle:nil];
    if (self) {
        _word = word;
    }
    return self;
}

- (void)refreshView
{
    self.lblKey.text = self.word.key;
}
@end
