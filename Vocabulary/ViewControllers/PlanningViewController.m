
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
//  PlanningVIewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-25.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "PlanningViewController.h"
#import "WordListViewController.h"
#import "AppDelegate.h"
#import "PureColorImageGenerator.h"
#import "PlanMaker.h"
#import "NSDate+VAdditions.h"

@interface PlanningViewController ()

- (void)refreshHintView;

@end

@implementation PlanningViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
//    [((AppDelegate *)[UIApplication sharedApplication].delegate) refreshTodaysPlan];
    
    //广告
//    self.banner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    [self.view bringSubviewToFront:self.banner];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    
//    UIImage *buttonBgImage = [[UIImage imageNamed:@"barbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
//    [menuButton setBackgroundImage:buttonBgImage forState:UIControlStateNormal];
    menuButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [menuButton setImage:[PureColorImageGenerator generateMenuImageWithTint:RGBA(255, 255, 255, 0.9)] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(revealLeftSidebar:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc]initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = menuBarButton;
    
    self.title = @"记词助手";
    
    //用于提示已经完成所有计划
    self.hintView = [[UILabel alloc]initWithFrame:self.view.frame];
    self.hintView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.hintView.font = [UIFont boldSystemFontOfSize:20];
    self.hintView.backgroundColor = GlobalBackgroundColor;
    self.hintView.shadowColor = [UIColor whiteColor];
    self.hintView.shadowOffset = CGSizeMake(0, 1);
    self.hintView.textColor = RGBA(140, 140, 140, 1);
    self.hintView.numberOfLines = 0;
    self.hintView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.hintView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldRefreshPlan:) name:kShouldRefreshTodaysPlanNotificationKey object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.todaysPlan = [[PlanMaker sharedInstance]todaysPlan];
    [self refreshHintView];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 2;
    if (self.todaysPlan.learningPlan == nil) {
        count--;
    }
    if (self.todaysPlan.reviewPlan.count == 0) {
        count--;
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfSections = [tableView numberOfSections];
    
    if (numberOfSections == 2) {
        switch (section) {
            case 0:
                return 1;
            case 1:
                return self.todaysPlan.reviewPlan.count;
            default:
                break;
        }
    }else if (numberOfSections == 1) {
        if (self.todaysPlan.learningPlan != nil) {
            return 1;
        }else if (self.todaysPlan.reviewPlan.count != 0) {
            return self.todaysPlan.reviewPlan.count;
        }
    }
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDate *todaysDateWithoutTime = [[NSDate date]hkv_dateWithoutTime];
    NSInteger numberOfSections = [self.tableView numberOfSections];
    if (numberOfSections == 2) {
        if (indexPath.section == 0) {
            cell.textLabel.text = self.todaysPlan.learningPlan.title;
            NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",self.todaysPlan.learningPlan.effectiveCount];
            if ([self.todaysPlan.learningPlan.lastReviewTime compare:todaysDateWithoutTime] == NSOrderedDescending) {
                cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkmark.png"]];
            }else{
                cell.accessoryView = nil;
            }
            cell.detailTextLabel.text = detailTxt;
        }else{
            WordList *wl = (self.todaysPlan.reviewPlan)[indexPath.row];
            cell.textLabel.text = [[wl valueForKey:@"title"] description];
            NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",[[wl valueForKey:@"effectiveCount"] description]];
            if ([wl.lastReviewTime compare:todaysDateWithoutTime] == NSOrderedDescending) {
                cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkmark.png"]];
            }else{
                cell.accessoryView = nil;
            }
            cell.detailTextLabel.text = detailTxt;
        }
    }else if (numberOfSections == 1) {
        if (self.todaysPlan.learningPlan != nil) {
            cell.textLabel.text = self.todaysPlan.learningPlan.title;
            NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",self.todaysPlan.learningPlan.effectiveCount];
            if ([self.todaysPlan.learningPlan.lastReviewTime compare:todaysDateWithoutTime] == NSOrderedDescending) {
                cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkmark.png"]];
            }else{
                cell.accessoryView = nil;
            }
            cell.detailTextLabel.text = detailTxt;
        }else if (self.todaysPlan.reviewPlan.count != 0) {
            WordList *wl = (self.todaysPlan.reviewPlan)[indexPath.row];
            cell.textLabel.text = [[wl valueForKey:@"title"] description];
            NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",[[wl valueForKey:@"effectiveCount"] description]];
            if ([wl.lastReviewTime compare:todaysDateWithoutTime] == NSOrderedDescending) {
                cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkmark.png"]];
            }else{
                cell.accessoryView = nil;
            }
            cell.detailTextLabel.text = detailTxt;
        }
    }
    
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger numOfSections = [tableView numberOfSections];
    
    if (numOfSections == 2) {
        switch (section) {
            case 1:
                return @"今日复习计划";
            case 0:
                return @"今日学习计划";
            default:
                break;
        }
    }else if (numOfSections == 1) {
        if (self.todaysPlan.learningPlan != nil) {
            return @"今日学习计划";
        }else if (self.todaysPlan.reviewPlan.count != 0) {
            return @"今日复习计划";
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WordListViewController *subVC = [[WordListViewController alloc]initWithNibName:@"WordListViewController" bundle:nil];
    
    NSInteger numOfSections = [tableView numberOfSections];
    
    if (numOfSections == 2) {
        if (indexPath.section == 0) {
            subVC.wordList = self.todaysPlan.learningPlan;
        }else{
            WordList *wl = (self.todaysPlan.reviewPlan)[indexPath.row];
            subVC.wordList = wl;
        }
    }else if (numOfSections == 1) {
        if (self.todaysPlan.learningPlan != nil) {
            subVC.wordList = self.todaysPlan.learningPlan;
        }else if (self.todaysPlan.reviewPlan.count != 0) {
            WordList *wl = (self.todaysPlan.reviewPlan)[indexPath.row];
            subVC.wordList = wl;
        }
    }
    [self.navigationController pushViewController:subVC animated:YES];
}

#pragma mark - actions
- (void)revealLeftSidebar:(id)sender {
    [((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController toggleLeftViewAnimated:YES];
}

- (void)refreshHintView
{
    NSUInteger wordListCount = [WordList MR_countOfEntities];
    
    
    self.view.hidden = NO;
    if (wordListCount == 0) {
        self.hintView.text = @"还没有词汇列表哦~\n点击左上角按钮选择添加词汇列表即可添加!";
    }else if (self.todaysPlan.learningPlan == nil && self.todaysPlan.reviewPlan.count == 0) {
        self.hintView.text = @"恭喜你已经完成今日计划了!";
    }else{
        self.hintView.hidden = YES;
    }
}

- (void)shouldRefreshPlan:(NSNotification *)notification
{
    self.todaysPlan = [[PlanMaker sharedInstance]todaysPlan];
    [self.tableView reloadData];
    [self refreshHintView];
}

//#pragma mark - GADBannerViewDelegate
//- (void)adViewDidReceiveAd:(GADBannerView *)view
//{
//    [super adViewDidReceiveAd:view];
//    [UIView animateWithDuration:0.5 animations:^{
//        self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50);
////        self.banner.transform = CGAffineTransformMakeTranslation(0, -50);
//    }];
//}
//
//- (void)adView:(GADBannerView *)view
//didFailToReceiveAdWithError:(GADRequestError *)error
//{
//    [super adView:view didFailToReceiveAdWithError:error];
//    [UIView animateWithDuration:0.5 animations:^{
//        self.tableView.frame = self.view.bounds;
////        self.banner.transform = CGAffineTransformMakeTranslation(0, 0);
//    }];
//}





@end
