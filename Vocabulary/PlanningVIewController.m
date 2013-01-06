
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

#import "PlanningVIewController.h"
#import "ShowWordsViewController.h"
#import "AppDelegate.h"
#import "IIViewDeckController.h"

@interface PlanningVIewController ()

@property (nonatomic, strong) NSDictionary *effectiveCount_deltaDay_map;
@property (nonatomic, unsafe_unretained) BOOL finishTodaysLearningPlan;

@end

@implementation PlanningVIewController

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
    //广告
    self.banner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view bringSubviewToFront:self.banner];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    
    UIImage *buttonBgImage = [[UIImage imageNamed:@"barbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    [menuButton setBackgroundImage:buttonBgImage forState:UIControlStateNormal];
    [menuButton setImage:[UIImage imageNamed:@"ButtonMenu.png"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(revealLeftSidebar:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc]initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = menuBarButton;
    
    self.todaysPlan = ((AppDelegate *)[UIApplication sharedApplication].delegate).todaysPlan;
    self.title = @"记词助手";
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg.png"] forBarMetrics:UIBarMetricsDefault];
    
//    self.wordListsArray = [[NSMutableArray alloc]init];
//    
//    //艾宾浩斯曲线日期递增映射
//    self.effectiveCount_deltaDay_map = 
//    @{
//        [NSNumber numberWithInt:1]:[NSNumber numberWithInt:0],
//        [NSNumber numberWithInt:2]:[NSNumber numberWithInt:1],
//        [NSNumber numberWithInt:3]:[NSNumber numberWithInt:2],
//        [NSNumber numberWithInt:4]:[NSNumber numberWithInt:3],
//        [NSNumber numberWithInt:5]:[NSNumber numberWithInt:8],
//    };
//    
//    self.title = @"记词助手";
//    
//    BOOL isPlanExpire = NO;
//    NSDate *planExpireTime = ((AppDelegate *)[UIApplication sharedApplication].delegate).planExpireTime;
//    //获取当前日期，忽略具体时间
//    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    NSDateComponents* components = [calendar components:flags fromDate:planExpireTime];
//    planExpireTime = [calendar dateFromComponents:components];
//    if ([planExpireTime compare:[NSDate date]] == NSOrderedAscending || [planExpireTime compare:[NSDate date]] == NSOrderedSame) {
//        //expire于现在之前，为过期
//        isPlanExpire = YES;
//        ((AppDelegate *)[UIApplication sharedApplication].delegate).finishTodaysLearningPlan = NO;
//    }
//    
//    _finishTodaysLearningPlan = ((AppDelegate *)[UIApplication sharedApplication].delegate).finishTodaysLearningPlan;
//    
//    NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance] managedObjectContext];
//    NSFetchRequest *request = [[NSFetchRequest alloc]init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:ctx];
//    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"addTime" ascending:YES];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(effectiveCount==0)"];
//    [request setEntity:entity];
//    [request setPredicate:predicate];
//    [request setSortDescriptors:@[sort]];
//    [request setFetchLimit:1];
//    //筛选学习计划
//    if (!_finishTodaysLearningPlan) {
//        //pick a word list
//        NSArray *result = [ctx executeFetchRequest:request error:nil];
//        if (result.count > 0) {
//            self.todaysPlan = [result objectAtIndex:0];
//        }
//    }
//    //筛选复习计划
//    predicate = [NSPredicate predicateWithFormat:@"(effectiveCount > 0 AND effectiveCount <= 5)"];
//    [request setPredicate:predicate];
//    [request setFetchLimit:0];
//    
//    NSArray *result = [ctx executeFetchRequest:request error:nil];
//    
//    for (WordList *wl in result) {
//        //上次复习日期+(effectiveCount对应的艾宾浩斯递增天数)=预计复习日期
//        NSDate *lastReviewTime = wl.lastReviewTime;
//        NSNumber *effectiveCount = wl.effectiveCount;
//        int deltaDay = [[self.effectiveCount_deltaDay_map objectForKey:effectiveCount]intValue];
//        NSTimeInterval deltaTimeInterval = deltaDay*24*60*60;
//        //计算得到的下次应该复习的时间
//        NSDate *expectedNextReviewDate = [lastReviewTime dateByAddingTimeInterval:deltaTimeInterval];
//        //获取当前日期，忽略具体时间
//        unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
//        NSCalendar* calendar = [NSCalendar currentCalendar];
//        NSDateComponents* components = [calendar components:flags fromDate:expectedNextReviewDate];
//        expectedNextReviewDate = [calendar dateFromComponents:components];
//        NSDate* currDate = [NSDate date];
//        //比较两个时间
//        if ([expectedNextReviewDate compare:currDate] == NSOrderedAscending || [expectedNextReviewDate compare:currDate] == NSOrderedSame) {
//            //预计复习日期≤现在日期 需要复习
//            [self.wordListsArray addObject:wl];
//        }
//    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.bannerFrame = CGRectMake(0, self.view.bounds.size.height-50, 320, 50);
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSInteger numberOfSections = [self.tableView numberOfSections];
    if (numberOfSections == 2) {
        if (indexPath.section == 0) {
            cell.textLabel.text = self.todaysPlan.learningPlan.title;
            NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",self.todaysPlan.learningPlan.effectiveCount];
            cell.detailTextLabel.text = detailTxt;
        }else{
            WordList *wl = [self.todaysPlan.reviewPlan objectAtIndex:indexPath.row];
            cell.textLabel.text = [[wl valueForKey:@"title"] description];
            NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",[[wl valueForKey:@"effectiveCount"] description]];
            if (wl.finished) {
                cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkmark.png"]];
            }
            cell.detailTextLabel.text = detailTxt;
        }
    }else if (numberOfSections == 1) {
        if (self.todaysPlan != nil) {
            cell.textLabel.text = self.todaysPlan.learningPlan.title;
            NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",self.todaysPlan.learningPlan.effectiveCount];
            cell.detailTextLabel.text = detailTxt;
        }else if (self.todaysPlan.reviewPlan.count != 0) {
            WordList *wl = [self.todaysPlan.reviewPlan objectAtIndex:indexPath.row];
            cell.textLabel.text = [[wl valueForKey:@"title"] description];
            NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",[[wl valueForKey:@"effectiveCount"] description]];
            if (wl.finished) {
                cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkmark.png"]];
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
    ShowWordsViewController *subVC = [[ShowWordsViewController alloc]initWithNibName:@"ShowWordsViewController" bundle:nil];
    
    NSInteger numOfSections = [tableView numberOfSections];
    
    if (numOfSections == 2) {
        if (indexPath.section == 0) {
            subVC.wordList = self.todaysPlan.learningPlan;
        }else{
            WordList *wl = [self.todaysPlan.reviewPlan objectAtIndex:indexPath.row];
            subVC.wordList = wl;
        }
    }else if (numOfSections == 1) {
        if (self.todaysPlan != nil) {
            subVC.wordList = self.todaysPlan.learningPlan;
        }else if (self.todaysPlan.reviewPlan.count != 0) {
            WordList *wl = [self.todaysPlan.reviewPlan objectAtIndex:indexPath.row];
            subVC.wordList = wl;
        }
    }
    [self.navigationController pushViewController:subVC animated:YES];
}

#pragma mark - actions
- (void)revealLeftSidebar:(id)sender {
    [((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController toggleLeftViewAnimated:YES];
}


#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    [super adViewDidReceiveAd:view];
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50);
//        self.banner.transform = CGAffineTransformMakeTranslation(0, -50);
    }];
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error
{
    [super adView:view didFailToReceiveAdWithError:error];
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.frame = self.view.bounds;
//        self.banner.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}



@end
