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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    HomeViewController *home = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    UINavigationController *ntv = [[UINavigationController alloc]initWithRootViewController:home];
    self.window.rootViewController = ntv;
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
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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

- (void)setFinishTodaysLearningPlan:(BOOL)finishTodaysPlan
{
    _finishTodaysLearningPlan = finishTodaysPlan;
    //[[NSUserDefaults standardUserDefaults]setBool:finishTodaysPlan forKey:kFinishTodaysPlan];
}

- (void)setLastTimeOpenThisApp:(NSDate *)lastTimeOpenThisApp
{
    _lastTimeOpenThisApp = lastTimeOpenThisApp;
    //[[NSUserDefaults standardUserDefaults]setObject:lastTimeOpenThisApp forKey:kLastTimeOpenThisApp];
}



@end
