//
//  AppDelegate.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-18.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "AppDelegate.h"
#import "Word.h"
#import "WordList.h"
#import "TouchXML.h"
#import "CibaXMLParser.h"
#import "TestViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
//    Word *word1 = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.managedObjectContext];
//    word1.word = @"hello1";
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
    TestViewController *tv = [[TestViewController alloc]initWithNibName:@"TestViewController" bundle:nil];
    self.window.rootViewController = tv;
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
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"db.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
