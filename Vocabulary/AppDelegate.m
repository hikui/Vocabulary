
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
//  AppDelegate.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-18.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "TestViewController.h"
#import "HomeViewController.h"
#import "UINavigationController+Rotation_IOS6.h"
#import "LeftBarViewController.h"
#import "SearchWordViewController.h"
#import "IIViewDeckController.h"
#import "PlanningVIewController.h"
#import "VNavigationController.h"
#import "Plan.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    //友盟统计
    [MobClick startWithAppkey:@"50b828715270152727000018" reportPolicy:REALTIME channelId:@"91Store"];
    [MobClick updateOnlineConfig];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
    //载入必要的预存设置
    _finishTodaysLearningPlan = [[NSUserDefaults standardUserDefaults]boolForKey:kFinishTodaysPlan];
    _planExpireTime = [[NSUserDefaults standardUserDefaults]objectForKey:kPlanExpireTime];

    
    LeftBarViewController *leftBarVC = [[LeftBarViewController alloc]initWithNibName:@"LeftBarViewController" bundle:nil];
        
    PlanningVIewController *pvc = [[PlanningVIewController alloc]initWithNibName:@"PlanningVIewController" bundle:nil];
    VNavigationController *npvc = [[VNavigationController alloc]initWithRootViewController:pvc];
    
    IIViewDeckController *viewDeckController = [[IIViewDeckController alloc]initWithCenterViewController:npvc leftViewController:leftBarVC rightViewController:nil];
    viewDeckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    viewDeckController.leftSize = 140;
    viewDeckController.delegate = self;
    self.viewDeckController = viewDeckController;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.todaysPlan = [[Plan alloc]init];
    
    //如果不需要数据库升级，直接进主页。如果需要数据库升级，近welcome view
    __block BOOL needMigration = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        needMigration = [[CoreDataHelper sharedInstance]isMigrationNeeded];
    });
    if (!needMigration) {
//        [self refreshTodaysPlan];
        
        self.window.rootViewController = viewDeckController;
    }else{
        [[NSBundle mainBundle]loadNibNamed:@"WelcomeView" owner:self options:nil];
        self.welcomeView.frame = CGRectMake(0, 20, 320, self.window.frame.size.height - 20);
        [self.window addSubview:self.welcomeView];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.welcomeView animated:YES];
        hud.detailsLabelText = @"正在升级数据库\n这将花费大约一分钟的时间";
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(databaseMigrationFinished:) name:kMigrationFinishedNotification object:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[CoreDataHelper sharedInstance]migrateDatabase];
        });
        
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    [helper saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    [self refreshTodaysPlan];
    [[NSNotificationCenter defaultCenter]postNotificationName:kShouldRefreshTodaysPlanNotificationKey object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    [helper saveContext];
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"crush");
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

- (void)setFinishTodaysLearningPlan:(BOOL)finishTodaysPlan
{
    _finishTodaysLearningPlan = finishTodaysPlan;
    [[NSUserDefaults standardUserDefaults]setBool:finishTodaysPlan forKey:kFinishTodaysPlan];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setPlanExpireTime:(NSDate *)planExpireTime
{
    _planExpireTime = planExpireTime;
    [[NSUserDefaults standardUserDefaults]setObject:planExpireTime forKey:kPlanExpireTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)onlineConfigCallBack:(NSNotification *)notification {
    NSLog(@"online config has fininshed and params = %@", notification.userInfo);
    NSString *newHelpDocVersion = [MobClick getConfigParams:@"helpDocVersion"];
    NSString *currentHelpVersion = [[NSUserDefaults standardUserDefaults]stringForKey:@"kCurrHelpDocVersion"];
    
    if (newHelpDocVersion.length > 0) {
        
        if (![newHelpDocVersion isEqualToString:currentHelpVersion]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"帮助文档更新了，请查看" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
            [[NSUserDefaults standardUserDefaults]setObject:newHelpDocVersion forKey:@"kCurrHelpDocVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
    }
}

#pragma mark - database notification
- (void)databaseMigrationFinished:(NSNotification *)notification
{
//    [self refreshTodaysPlan];
    [self.welcomeView removeFromSuperview];
    self.window.rootViewController = self.viewDeckController;
}

#pragma mark - custom methods
- (void)refreshTodaysPlan
{
    //艾宾浩斯曲线日期递增映射
    NSDictionary *effectiveCount_deltaDay_map =
    @{
    [NSNumber numberWithInt:1]:[NSNumber numberWithInt:0],
    [NSNumber numberWithInt:2]:[NSNumber numberWithInt:1],
    [NSNumber numberWithInt:3]:[NSNumber numberWithInt:2],
    [NSNumber numberWithInt:4]:[NSNumber numberWithInt:3],
    [NSNumber numberWithInt:5]:[NSNumber numberWithInt:8],
    };
    
    BOOL isPlanExpire = NO;
    NSDate *planExpireTime = [self.planExpireTime copy];
    //获取当前日期，忽略具体时间
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:planExpireTime];
    planExpireTime = [calendar dateFromComponents:components];
    if ([planExpireTime compare:[NSDate date]] == NSOrderedAscending || [planExpireTime compare:[NSDate date]] == NSOrderedSame) {
        //expire于现在之前，为过期
        isPlanExpire = YES;
        self.finishTodaysLearningPlan = NO;
    }
    
    NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:ctx];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"addTime" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(effectiveCount==0)"];
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sort]];
    [request setFetchLimit:1];
    //筛选学习计划
    if (!_finishTodaysLearningPlan) {
        //pick a word list
        NSArray *result = [ctx executeFetchRequest:request error:nil];
        if (result.count > 0) {
            WordList *learningPlan = [result objectAtIndex:0];
            self.todaysPlan.learningPlan = learningPlan;
        }
    }
    //筛选复习计划
    predicate = [NSPredicate predicateWithFormat:@"(effectiveCount > 0 AND effectiveCount <= 5)"];
    [request setPredicate:predicate];
    [request setFetchLimit:0];
    
    NSArray *result = [ctx executeFetchRequest:request error:nil];
    
    NSMutableArray *reviewPlan = [[NSMutableArray alloc]init];
    
    for (WordList *wl in result) {
        //上次复习日期+(effectiveCount对应的艾宾浩斯递增天数)=预计复习日期
        NSDate *lastReviewTime = wl.lastReviewTime;
        NSNumber *effectiveCount = wl.effectiveCount;
        int deltaDay = [[effectiveCount_deltaDay_map objectForKey:effectiveCount]intValue];
        NSTimeInterval deltaTimeInterval = deltaDay*24*60*60;
        //计算得到的下次应该复习的时间
        NSDate *expectedNextReviewDate = [lastReviewTime dateByAddingTimeInterval:deltaTimeInterval];
        //获取当前日期，忽略具体时间
        unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:flags fromDate:expectedNextReviewDate];
        expectedNextReviewDate = [calendar dateFromComponents:components];
        NSDate* currDate = [NSDate date];
        //比较两个时间
        if ([expectedNextReviewDate compare:currDate] == NSOrderedAscending || [expectedNextReviewDate compare:currDate] == NSOrderedSame) {
            //预计复习日期≤现在日期 需要复习
            [reviewPlan addObject:wl];
        }
    }
    self.todaysPlan.reviewPlan = reviewPlan;
}

#pragma mark - view deck delegate
//- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated
//{
//    UIView *leftView = viewDeckController.leftController.view;
//    if (animated) {
//        [UIView animateWithDuration:1 animations:^{
//            leftView.frame = CGRectMake(leftView.frame.origin.x, leftView.frame.origin.y, viewDeckController.leftViewSize, leftView.frame.size.height);
//        }];
//    }
//}
//- (void)viewDeckController:(IIViewDeckController*)viewDeckController didChangeOffset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning
//{
//    NSLog(@"view deck did change offset with panning:%d, offset:%f",panning,offset);
//    if (!panning && offset != 0.0f) {
//        UIView *leftView = viewDeckController.leftController.view;
////        [UIView animateWithDuration:1 animations:^{
////            NSLog(@"leftViewSize:%f,leftSize:%f",viewDeckController.leftViewSize,viewDeckController.leftSize);
////            leftView.frame = CGRectMake(leftView.frame.origin.x, leftView.frame.origin.y, offset, leftView.frame.size.height);
////        }];
//    }
//}
@end
