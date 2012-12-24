
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
//  HomeViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "HomeViewController.h"
#import "CreateWordListViewController.h"
#import "ShowWordListViewController.h"
#import "PlanningVIewController.h"
#import "ShowWordsViewController.h"
#import "HelpViewController.h"
#import "ConfigViewController.h"
#import "WordListFromDiskViewController.h"
#import "SearchWordViewController.h"

@interface HomeViewController ()

- (NSUInteger)countOfLearnedWordlist;
- (void)databaseMigrationFinished:(NSNotification *)notification;

@end

@implementation HomeViewController

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
    self.title = @"记词助手";
    self.navigationController.navigationBar.tintColor = RGBA(48, 16, 17, 1);
    UIImage *buttonImage = [[UIImage imageNamed:@"orangeButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlighted = [[UIImage imageNamed:@"orangeButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    for (UIButton *btn in self.view.subviews) {
        if ([btn isKindOfClass:[UIButton class]] && btn.tag>=1) {
            [btn setBackgroundImage:buttonImage forState:UIControlStateNormal];
            [btn setBackgroundImage:buttonImageHighlighted forState:UIControlStateHighlighted];
        }
    }
    self.view.backgroundColor = RGBA(227, 227, 227, 1);
    
    
    UIBarButtonItem *configButton = [[UIBarButtonItem alloc]initWithTitle:@"设置"  style:UIBarButtonItemStyleBordered target:self action:@selector(preferenceButtonOnPress)];
    self.navigationItem.leftBarButtonItem = configButton;
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonOnPress)];
    self.navigationItem.rightBarButtonItem = searchButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    __block BOOL needMigration = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        needMigration = [[CoreDataHelper sharedInstance]isMigrationNeeded];
    });
    if (!needMigration) {
        self.countLabel.text = [NSString stringWithFormat:@"%d",[self countOfLearnedWordlist]];
        [self.countLabel sizeToFit];
        UILabel *tailLabel = (UILabel *)[self.view viewWithTag:2000];
        tailLabel.frame = CGRectMake(self.countLabel.frame.origin.x+self.countLabel.frame.size.width, tailLabel.frame.origin.y, tailLabel.frame.size.width, tailLabel.frame.size.height);
    }else{
        UIWindow *window = [[UIApplication sharedApplication]keyWindow];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        hud.detailsLabelText = @"正在升级数据库\n这将花费大约一分钟的时间";
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(databaseMigrationFinished:) name:kMigrationFinishedNotification object:nil];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[CoreDataHelper sharedInstance]migrateDatabase];
        });

    }
}

- (void)viewDidAppear:(BOOL)animated
{
    BOOL isNotFirstRun = [[NSUserDefaults standardUserDefaults]boolForKey:@"kIsNotFirstRun"];
    if (!isNotFirstRun) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"这是您第一次运行，是否显示帮助？" delegate:self cancelButtonTitle:@"不显示" otherButtonTitles:@"显示", nil];
        alertView.tag = 1;
        [alertView show];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"kIsNotFirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)btnSelected:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 1) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选择导入方式"
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"批量输入",@"从iTunes上传", nil];
        [actionSheet showInView:self.view];
    }else if(btn.tag == 2){
        ShowWordListViewController *vc = [[ShowWordListViewController alloc]initWithNibName:@"ShowWordListViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(btn.tag == 3){
        PlanningVIewController *pvc = [[PlanningVIewController alloc]initWithNibName:@"PlanningVIewController" bundle:nil];
        [self.navigationController pushViewController:pvc animated:YES];
    }else if(btn.tag == 4){
        
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
        [self.navigationController pushViewController:svc animated:YES];
    }
}

- (NSUInteger)countOfLearnedWordlist
{
    NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:ctx];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(effectiveCount>0)"];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSUInteger count = [ctx countForFetchRequest:request error:nil];
    return count;
}

- (IBAction)preferenceButtonOnPress
{
    ConfigViewController *configVC = [[ConfigViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:configVC animated:YES];
}

- (void)searchButtonOnPress
{
    SearchWordViewController *swvc = [[SearchWordViewController alloc]initWithModalViewControllerMode:NO];
    [self.navigationController pushViewController:swvc animated:YES];
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

#pragma mark - alert view delegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        NSString *selectedBtnTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if ([selectedBtnTitle isEqualToString:@"显示"]) {
            HelpViewController *helpViewController = [[HelpViewController alloc]initWithNibName:@"HelpViewController" bundle:nil];
            helpViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentModalViewController:helpViewController animated:YES];
        }
    }
}

#pragma mark - database notification
- (void)databaseMigrationFinished:(NSNotification *)notification
{
    UIWindow *window = [[UIApplication sharedApplication]keyWindow];
    [MBProgressHUD hideHUDForView:window animated:YES];
    self.countLabel.text = [NSString stringWithFormat:@"%d",[self countOfLearnedWordlist]];
    [self.countLabel sizeToFit];
    UILabel *tailLabel = (UILabel *)[self.view viewWithTag:2000];
    tailLabel.frame = CGRectMake(self.countLabel.frame.origin.x+self.countLabel.frame.size.width, tailLabel.frame.origin.y, tailLabel.frame.size.width, tailLabel.frame.size.height);
}

@end
