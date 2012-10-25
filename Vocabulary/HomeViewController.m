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

@interface HomeViewController ()

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
}

@end
