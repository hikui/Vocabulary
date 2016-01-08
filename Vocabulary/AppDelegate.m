
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
#import "PlanningViewController.h"
#import "VNavigationController.h"
#import "PureColorImageGenerator.h"
#import "HKVNavigationRouteConfig.h"
#import "HKVNavigationManager.h"
#import "VWebViewController.h"
#import "UMOnlineConfig.h"
#import "Masonry.h"
#import "VRotatableButton.h"
#import "ImportSelectionView.h"
#import "WordListFromDiskViewController.h"
#import "CreateWordListViewController.h"
#import "UnfamiliarWordListViewController.h"
#import "PreferenceViewController.h"

static BOOL isRunningTests(void)
{
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    NSString* injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}

NS_INLINE void configNavigationController(UINavigationController *nav) {
    [nav.v_navigationManager configRoute:^NSDictionary * {
        return [HKVNavigationRouteConfig sharedInstance].route;
    }];
    
    nav.v_navigationManager.onMatchFailureBlock = ^UIViewController * (HKVNavigationActionCommand * command)
    {
        VWebViewController* webViewController = [[VWebViewController alloc] initWithNibName:nil bundle:nil];
        webViewController.requestURL = command.targetURL;
        return webViewController;
    };
}

@interface AppDelegate()

@property (strong) UIViewController *placeholderVC; // placeholder for "add" tab
@property (strong) UITabBarController *tabbarController;

@property (strong) ImportSelectionView *importSelectionView;
@property (strong) VRotatableButton *addButton;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    if (isRunningTests()) {
        return YES;
    }

    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    // setup appearance
    UIImage* navBackgroundImage = [PureColorImageGenerator generateOnePixelImageWithColor:[UIColor whiteColor]];
    [[UIToolbar appearance] setBackgroundImage:navBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];

    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelVerbose];

    //友盟统计
    [MobClick startWithAppkey:@"50b828715270152727000018" reportPolicy:REALTIME channelId:kChannelId];
    [UMOnlineConfig updateOnlineConfigWithAppkey:@"50b828715270152727000018"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];

    //CoreData stack
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"db.sqlite"];

    //Lumberjack
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[[DDFileLogger alloc] init]];
    
    // tabbar controller
    self.placeholderVC = [[UIViewController alloc]init];
    
    PlanningViewController *planVC = [[PlanningViewController alloc]initWithNibName:nil bundle:nil];
    ExistingWordListsViewController *eVC = [[ExistingWordListsViewController alloc]initWithNibName:nil bundle:nil];
    UnfamiliarWordListViewController *uVC = [[UnfamiliarWordListViewController alloc]initWithNibName:NSStringFromClass([WordListViewController class]) bundle:nil];
    PreferenceViewController *pvc = [[PreferenceViewController alloc]initWithNibName:nil bundle:nil];
    
    planVC.tabBarItem.title = @"今日计划";
    planVC.tabBarItem.image = [UIImage imageNamed:@"plan-icon"];
    eVC.tabBarItem.title = @"词汇列表";
    eVC.tabBarItem.image = [UIImage imageNamed:@"list-icon"];
    self.placeholderVC.tabBarItem.title = @"";
    uVC.tabBarItem.title = @"生疏词汇";
    uVC.tabBarItem.image = [UIImage imageNamed:@"unfamiliar-words-icon"];
    pvc.tabBarItem.title = @"设置";
    pvc.tabBarItem.image = [UIImage imageNamed:@"settings-icon"];
    
    
    UITabBarController *tabbarController = [[UITabBarController alloc]init];
    tabbarController.delegate = self;
    [tabbarController setViewControllers:@[planVC,eVC,self.placeholderVC,uVC,pvc]];
    [tabbarController setSelectedIndex:0];
    tabbarController.tabBar.barTintColor = [UIColor whiteColor];
    self.tabbarController = tabbarController;
    
    VRotatableButton *addButton = [[VRotatableButton alloc]initWithFrame:CGRectMake(0, 0, 78, 48)];
    addButton.rotatableImageView.image = [UIImage imageNamed:@"TabbarAddButtonIcon"];
    [tabbarController.view addSubview:addButton];
    addButton.center = tabbarController.tabBar.center;
    addButton.backgroundColor = [UIColor clearColor];
    addButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [addButton addTarget:self action:@selector(addButtonOnTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.addButton = addButton;
    
    VNavigationController *globalNavigationController = [[VNavigationController alloc]initWithRootViewController:tabbarController];
//    [HKVNavigationManager sharedInstance].navigationController = globalNavigationController;
//    self.globalNavigationController = globalNavigationController;
    configNavigationController(globalNavigationController);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = globalNavigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)addButtonOnTouch:(VRotatableButton *)sender {
    if (self.importSelectionView == nil) {
        self.importSelectionView = [ImportSelectionView importSelectionView];
        __weak typeof(self) weakSelf = self;
        self.importSelectionView.menuDidHideBlock = ^() {
            weakSelf.addButton.active = NO;
        };
        [self.importSelectionView.importManuallyButton addTarget:self action:@selector(importManuallyButtonOnTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self.importSelectionView.importFromiTunesButton addTarget:self action:@selector(importFromiTunesButtonOnTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (sender.active) {
        [self.tabbarController.view insertSubview:self.importSelectionView belowSubview:self.tabbarController.tabBar];
        [self.importSelectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(0);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.importSelectionView showMenu];
        });
    } else {
        [self.importSelectionView hideMenu];
    }
}

- (void)importFromiTunesButtonOnTouch:(id)sender {
    WordListFromDiskViewController *wvc = [[WordListFromDiskViewController alloc]initWithNibName:nil bundle:nil];
    [self.importSelectionView hideMenu];
    [self.window.rootViewController presentViewController:wvc animated:YES completion:nil];
    
}

- (void)importManuallyButtonOnTouch:(id)sender {
    CreateWordListViewController *cvc = [[CreateWordListViewController alloc]initWithNibName:nil bundle:nil];
    [self.importSelectionView hideMenu];
    [self.window.rootViewController presentViewController:cvc animated:YES completion:nil];
}

- (void)applicationWillResignActive:(UIApplication*)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:nil];
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRefreshTodaysPlanNotificationKey object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    // Ensure data is saved before terminate.
    [MagicalRecord saveWithBlockAndWait:nil];
    [MagicalRecord cleanUp];
}

- (void)onlineConfigCallBack:(NSNotification*)notification
{
    DDLogDebug(@"online config has fininshed and params = %@", notification.userInfo);
    NSString* newHelpDocVersion = [UMOnlineConfig getConfigParams:@"helpDocVersion"];
    NSString* currentHelpVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCurrHelpDocVersion"];
    if (currentHelpVersion == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:newHelpDocVersion forKey:@"kCurrHelpDocVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }

    if (newHelpDocVersion.length > 0) {

        if (![newHelpDocVersion isEqualToString:currentHelpVersion]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"帮助文档更新了，请查看" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
            [[NSUserDefaults standardUserDefaults] setObject:newHelpDocVersion forKey:@"kCurrHelpDocVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark - TabBarController delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController == self.placeholderVC) {
        return NO;
    }
    return YES;
}

@end
