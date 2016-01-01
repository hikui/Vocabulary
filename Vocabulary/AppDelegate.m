
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

    VNavigationController* planNav = [[VNavigationController alloc] init];
    VNavigationController* listNav = [[VNavigationController alloc] init];
    VNavigationController* addNav = [[VNavigationController alloc] init];
    VNavigationController* unfamiliarNav = [[VNavigationController alloc] init];
    VNavigationController* settingsNav = [[VNavigationController alloc] init];

    configNavigationController(planNav);
    configNavigationController(listNav);
    configNavigationController(addNav);
    configNavigationController(unfamiliarNav);
    configNavigationController(settingsNav);
    
    [planNav.v_navigationManager commonResetRootURL:[HKVNavigationRouteConfig sharedInstance].planningVC
                                             params:nil];
    [listNav.v_navigationManager commonResetRootURL:[HKVNavigationRouteConfig sharedInstance].existingWordsListsVC
                                             params:nil];
    [addNav.v_navigationManager commonResetRootURL:[HKVNavigationRouteConfig sharedInstance].planningVC
                                            params:nil];
    [unfamiliarNav.v_navigationManager commonResetRootURL:[HKVNavigationRouteConfig sharedInstance].wordListVC
                                                   params:nil];
    [settingsNav.v_navigationManager commonResetRootURL:[HKVNavigationRouteConfig sharedInstance].PreferenceVC
                                                 params:nil];
    planNav.tabBarItem.title = @"aaa";
    listNav.tabBarItem.title = @"bbb";
    addNav.tabBarItem.title = @"ccc";
    unfamiliarNav.tabBarItem.title = @"ddd";
    settingsNav.tabBarItem.title = @"eee";
    
    
    UITabBarController *tabbar = [[UITabBarController alloc]init];
    [tabbar setViewControllers:@[planNav,listNav,addNav,unfamiliarNav,settingsNav]];
    [tabbar setSelectedIndex:0];
    

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabbar;
    [self.window makeKeyAndVisible];
    return YES;
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

@end
