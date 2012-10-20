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
    
//    Word *word1 = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.managedObjectContext];
//    word1.key = @"good";
//    word1.meaning = @"meaning of hello1";
//    word1.qualification = [NSNumber numberWithInt:1];
//    Word *word2 = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.managedObjectContext];
//    word2.word = @"hello2";
//    word2.meaning = @"meaning of hello2";
//    word2.qualification = [NSNumber numberWithInt:1];
//    Word *word3 = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.managedObjectContext];
//    word3.word = @"hello3";
//    word3.meaning = @"meaning of hello3";
//    word3.qualification = [NSNumber numberWithInt:1];
//    Word *word4 = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.managedObjectContext];
//    word4.word = @"hello4";
//    word4.meaning = @"meaning of hello4";
//    word4.qualification = [NSNumber numberWithInt:1];
//    WordList *wl = [NSEntityDescription insertNewObjectForEntityForName:@"WordList" inManagedObjectContext:self.managedObjectContext];
//    NSSet *words = [[NSSet alloc]initWithObjects:word1,word2,word3,word4,nil];
//    [wl addWords:words];
//    [self saveContext];
//    [self saveContext];
    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    // 根据指定Entity名称和被管理对象上下文，创建NSEntityDescription对象，
//    NSEntityDescription *myEntityQuery = [NSEntityDescription
//                                          entityForName:@"WordList"
//                                          inManagedObjectContext:self.managedObjectContext];
//    // 指定实体
//    [request setEntity:myEntityQuery];
//    WordList *wl = [[self.managedObjectContext executeFetchRequest:request error:nil]objectAtIndex:0];
//    NSLog(@"%@",wl.words);
//    for (Word *w in wl.words) {
//        NSLog(@"word:%@",w.word);
//    }
//
//    NSError *error = nil;
//    // 返回符合查询条件NSFetchRequest的记录数组
//    NSArray * wordsArr = [self.managedObjectContext executeFetchRequest:request error:&error];
//    NSLog(@"%@",wordsArr);
//    Word *w = [wordsArr objectAtIndex:0];
//    NSLog(@"%@",w.word);
//    NSURL *url = [NSURL URLWithString:@"http://dict-co.iciba.com/api/dictionary.php?w=good"];
//    NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//    NSDictionary *dict = [CibaXMLParser parseWithXMLString:str];
//    NSLog(@"%@",dict);
//    NSData *xmlData = [NSData dataWithContentsOfURL:url];
//    CXMLDocument *document = [[CXMLDocument alloc]initWithData:xmlData encoding:NSUTF8StringEncoding options:0 error:nil];
//    NSArray *posArray = [document nodesForXPath:@"//pos" error:nil];
//    for (CXMLElement *element in posArray) {
//        NSLog(@"%@,%@",[element stringValue],[element name]);
//    }
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


@end
