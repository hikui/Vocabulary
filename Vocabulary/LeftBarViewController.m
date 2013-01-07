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
#import "ShowWordsViewController.h"
#import "ConfigViewController.h"
#import "CreateWordListViewController.h"
#import "VNavigationController.h"

#import "AppDelegate.h"

@interface LeftBarViewController ()

@property (nonatomic, strong) NSArray *rows;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation LeftBarViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.rows = @[@"今日学习计划",@"添加词汇列表",@"已有词汇列表",@"低熟悉度词汇",@"设置"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)viewWillAppear:(BOOL)animated
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    });
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
        cell.textLabel.textColor = [UIColor whiteColor];
        UIImage *cellBG = [[UIImage imageNamed:@"CellBG.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        UIImage *cellBGHighlighted = [[UIImage imageNamed:@"CellBGHighlighted.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        cell.backgroundView = [[UIImageView alloc]initWithImage:cellBG];
        cell.selectedBackgroundView = [[UIImageView alloc]initWithImage:cellBGHighlighted];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    cell.textLabel.text = self.rows[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 1) {
        self.selectedIndexPath = indexPath;
    }
    
    IIViewDeckController *viewDeckController = ((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController;
    if (indexPath.row == 0) {
        if ([[((VNavigationController *)viewDeckController.centerController).viewControllers lastObject] isKindOfClass:[PlanningVIewController class]]) {
            [viewDeckController closeLeftView];
        }else{
            PlanningVIewController *pvc = [[PlanningVIewController alloc]initWithNibName:@"PlanningVIewController" bundle:nil];
            VNavigationController *npvc = [[VNavigationController alloc]initWithRootViewController:pvc];
            [viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                controller.centerController = npvc;
            }];
        }
    }else if (indexPath.row == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView selectRowAtIndexPath:self.selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选择导入方式"
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"批量输入",@"从iTunes上传", nil];
        [actionSheet showInView:self.view];
    }else if (indexPath.row == 2) {
        if ([[((VNavigationController *)viewDeckController.centerController).viewControllers lastObject] isKindOfClass:[ShowWordListViewController class]]) {
            [viewDeckController closeLeftView];
        }else{
            ShowWordListViewController *swlvc = [[ShowWordListViewController alloc]initWithNibName:@"ShowWordListViewController" bundle:nil];
            VNavigationController *nswlvc = [[VNavigationController alloc]initWithRootViewController:swlvc];
            [viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                controller.centerController = nswlvc;
            }];
        }
    }else if (indexPath.row == 3) {
        if ([[((VNavigationController *)viewDeckController.centerController).viewControllers lastObject] isKindOfClass:[ShowWordsViewController class]]) {
            [viewDeckController closeLeftView];
        }else{
            
            NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance] managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc]init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:ctx];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastVIewDate != nil AND ((familiarity <= 5) OR (familiarity <10 AND (NONE wordLists.effectiveCount<6))))"];
            [request setEntity:entity];
            [request setPredicate:predicate];
            NSArray *result = [ctx executeFetchRequest:request error:nil];
            NSMutableArray *mResult = [[NSMutableArray alloc]initWithArray:result];
            
            ShowWordsViewController *svc = [[ShowWordsViewController alloc]initWithNibName:@"ShowWordsViewController" bundle:nil];
            svc.wordsSet = mResult;
            svc.topLevel = YES;
            svc.title = @"低熟悉度词汇";
            VNavigationController *nsvc = [[VNavigationController alloc]initWithRootViewController:svc];
            [viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                controller.centerController = nsvc;
            }];
        }
    }else if (indexPath.row == 4) {
        if ([[((VNavigationController *)viewDeckController.centerController).viewControllers lastObject] isKindOfClass:[ConfigViewController class]]) {
            [viewDeckController closeLeftView];
        }else{
            ConfigViewController *cvc = [[ConfigViewController alloc]initWithStyle:UITableViewStyleGrouped];
            VNavigationController *ncvc = [[VNavigationController alloc]initWithRootViewController:cvc];
            [viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                controller.centerController = ncvc;
            }];
        }
    }
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"批量输入"]) {
        CreateWordListViewController *vc = [[CreateWordListViewController alloc]initWithNibName:@"CreateWordListViewController" bundle:nil];
        [self presentModalViewController:vc animated:YES];
    }else if ([title isEqualToString:@"从iTunes上传"]){
        WordListFromDiskViewController *fdvc =[[WordListFromDiskViewController alloc]initWithNibName:@"WordListFromDiskViewController" bundle:nil];
        [self presentModalViewController:fdvc animated:YES];
    }
}

@end
