//
//  LeftBarViewController.m
//  Vocabulary
//
//  Created by Hikui on 13-1-3.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "LeftBarViewController.h"
#import "IIViewDeckController.h"
#import "PlanningVIewController.h"
#import "WordListFromDiskViewController.h"
#import "ShowWordListViewController.h"
#import "ConfigViewController.h"
#import "AppDelegate.h"

@interface LeftBarViewController ()

@property (nonatomic, strong) NSArray *rows;

@end

@implementation LeftBarViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    self.rows = @[@"今日学习安排",@"添加词汇列表",@"查看已有词汇",@"设置"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor darkGrayColor];
        cell.contentView.backgroundColor = [UIColor darkGrayColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = self.rows[indexPath.row];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IIViewDeckController *viewDeckController = ((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController;
    if (indexPath.row == 0) {
        if ([[((UINavigationController *)viewDeckController.centerController).viewControllers lastObject] isKindOfClass:[PlanningVIewController class]]) {
            [viewDeckController closeLeftView];
        }else{
            PlanningVIewController *pvc = [[PlanningVIewController alloc]initWithNibName:@"PlanningVIewController" bundle:nil];
            UINavigationController *npvc = [[UINavigationController alloc]initWithRootViewController:pvc];
            [viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                controller.centerController = npvc;
            }];
        }
    }else if (indexPath.row == 1) {
        
    }else if (indexPath.row == 2) {
        if ([[((UINavigationController *)viewDeckController.centerController).viewControllers lastObject] isKindOfClass:[ShowWordListViewController class]]) {
            [viewDeckController closeLeftView];
        }else{
            ShowWordListViewController *swlvc = [[ShowWordListViewController alloc]initWithNibName:@"ShowWordListViewController" bundle:nil];
            UINavigationController *nswlvc = [[UINavigationController alloc]initWithRootViewController:swlvc];
            [viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                controller.centerController = nswlvc;
            }];
        }
    }else if (indexPath.row == 3) {
        if ([[((UINavigationController *)viewDeckController.centerController).viewControllers lastObject] isKindOfClass:[ConfigViewController class]]) {
            [viewDeckController closeLeftView];
        }else{
            ConfigViewController *cvc = [[ConfigViewController alloc]initWithStyle:UITableViewStylePlain];
            UINavigationController *ncvc = [[UINavigationController alloc]initWithRootViewController:cvc];
            [viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                controller.centerController = ncvc;
            }];
        }
    }
}

@end
