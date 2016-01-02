//
//  UnfamiliarWordListViewController.m
//  Vocabulary
//
//  Created by Heguang Miao on 1/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import "UnfamiliarWordListViewController.h"

@interface UnfamiliarWordListViewController ()

@end

@implementation UnfamiliarWordListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = NO;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastVIewDate != nil AND ((familiarity <= 5) OR (familiarity <10 AND (NONE wordLists.effectiveCount<6))))"];
    NSArray *result = [Word MR_findAllWithPredicate:predicate];
    
    NSMutableArray *mResult = [[NSMutableArray alloc]initWithArray:result];
    self.wordArray = mResult;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
