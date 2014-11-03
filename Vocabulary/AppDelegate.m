
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
#import "LeftBarViewController.h"
#import "PlanningViewController.h"
#import "VNavigationController.h"
#import "PureColorImageGenerator.h"



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    
    // setup appearance
    UIImage *navBackgroundImage = [PureColorImageGenerator generateOnePixelImageWithColor:[UIColor whiteColor]];
    [[UIToolbar appearance] setBackgroundImage:navBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    
    //友盟统计
    [MobClick startWithAppkey:@"50b828715270152727000018" reportPolicy:REALTIME channelId:kChannelId];
    [MobClick updateOnlineConfig];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
    //CoreData stack
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"db.sqlite"];
    
    //Lumberjack
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[[DDFileLogger alloc]init]];
    
    LeftBarViewController *leftBarVC = [[LeftBarViewController alloc]initWithNibName:@"LeftBarViewController" bundle:nil];
        
    PlanningViewController *pvc = [[PlanningViewController alloc]initWithNibName:@"PlanningViewController" bundle:nil];
    VNavigationController *npvc = [[VNavigationController alloc]initWithRootViewController:pvc];
    
    IIViewDeckController *viewDeckController = [[IIViewDeckController alloc]initWithCenterViewController:npvc leftViewController:leftBarVC rightViewController:nil];
    viewDeckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    viewDeckController.sizeMode = IIViewDeckViewSizeMode;
    if (IS_IPAD) {
        viewDeckController.leftSize = 300;
    }else{
        viewDeckController.leftSize = 140;
    }
    viewDeckController.delegate = self;
    self.viewDeckController = viewDeckController;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewDeckController;
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kShouldRefreshTodaysPlanNotificationKey object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:nil];
    [MagicalRecord cleanUp];
}

- (void)onlineConfigCallBack:(NSNotification *)notification {
    DDLogDebug(@"online config has fininshed and params = %@", notification.userInfo);
    NSString *newHelpDocVersion = [MobClick getConfigParams:@"helpDocVersion"];
    NSString *currentHelpVersion = [[NSUserDefaults standardUserDefaults]stringForKey:@"kCurrHelpDocVersion"];
    if (currentHelpVersion == nil) {
        [[NSUserDefaults standardUserDefaults]setObject:newHelpDocVersion forKey:@"kCurrHelpDocVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
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

@end
