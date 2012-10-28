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

- (IBAction)btnSelected:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 1) {
        CreateWordListViewController *vc = [[CreateWordListViewController alloc]initWithNibName:@"CreateWordListViewController" bundle:nil];
        [self presentModalViewController:vc animated:YES];
    }else if(btn.tag == 2){
        ShowWordListViewController *vc = [[ShowWordListViewController alloc]initWithNibName:@"ShowWordListViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(btn.tag == 3){
        PlanningVIewController *pvc = [[PlanningVIewController alloc]initWithNibName:@"ShowWordListViewController" bundle:nil];
        [self.navigationController pushViewController:pvc animated:YES];
    }else if(btn.tag == 4){
        NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance] managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:ctx];
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor1];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(wordList.effectiveCount > 0 AND familiarity <= 5)"];
        [request setEntity:entity];
        [request setSortDescriptors:sortDescriptors];
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

- (IBAction)infoButtonOnPress:(id)sender
{
    HelpViewController *hvc = [[HelpViewController alloc]initWithNibName:@"HelpViewController" bundle:nil];
    hvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:hvc animated:YES];
}

@end
