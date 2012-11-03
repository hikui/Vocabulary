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

@interface HomeViewController ()

- (NSUInteger)countOfLearnedWordlist;

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
    self.title = @"背单词助手";
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
    self.navigationItem.rightBarButtonItem = configButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.countLabel.text = [NSString stringWithFormat:@"%d",[self countOfLearnedWordlist]];
    [self.countLabel sizeToFit];
    UILabel *tailLabel = (UILabel *)[self.view viewWithTag:2000];
    tailLabel.frame = CGRectMake(self.countLabel.frame.origin.x+self.countLabel.frame.size.width, tailLabel.frame.origin.y, tailLabel.frame.size.width, tailLabel.frame.size.height);
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
                                                       otherButtonTitles:@"批量输入",@"从文件扫描", nil];
        [actionSheet showInView:self.view];
    }else if(btn.tag == 2){
        ShowWordListViewController *vc = [[ShowWordListViewController alloc]initWithNibName:@"ShowWordListViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(btn.tag == 3){
        PlanningVIewController *pvc = [[PlanningVIewController alloc]init];
        [self.navigationController pushViewController:pvc animated:YES];
    }else if(btn.tag == 4){
        NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance] managedObjectContext];
        
        //筛选出所有背过的词汇表
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:ctx];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(effectiveCount > 0)"];
        [request setEntity:entity];
        [request setPredicate:predicate];
        NSArray *resultWordLists = [ctx executeFetchRequest:request error:nil];
        
        NSMutableArray *result = [[NSMutableArray alloc]init];
        
        for (WordList *wl in resultWordLists) {
            for (Word *w in wl.words) {
                if ([w.familiarity intValue] <= 5) {
                    [result addObject:w];
                }
            }
        }
        
        ShowWordsViewController *svc = [[ShowWordsViewController alloc]initWithNibName:@"ShowWordsViewController" bundle:nil];
        svc.wordsSet = result;
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

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"批量输入"]) {
        CreateWordListViewController *vc = [[CreateWordListViewController alloc]initWithNibName:@"CreateWordListViewController" bundle:nil];
        [self presentModalViewController:vc animated:YES];
    }else if ([title isEqualToString:@"从文件扫描"]){
        WordListFromDiskViewController *fdvc =[[WordListFromDiskViewController alloc]initWithNibName:@"WordListFromDiskViewController" bundle:nil];
        [self presentModalViewController:fdvc animated:YES];
    }
}

@end
