
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
//  CoreDataHelper.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static CoreDataHelper *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        _sharedObject.globalContextSavingLock = [[NSLock alloc]init];
        [[NSNotificationCenter defaultCenter]addObserver:_sharedObject selector:@selector(receiveContextSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    });
    return _sharedObject;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        [self.globalContextSavingLock lock];
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.globalContextSavingLock unlock];
    }
}

#pragma mark - Core Data stack

- (BOOL)isMigrationNeeded
{
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]]; ;
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"db.sqlite"];
    
    // Determine if a migration is needed
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:storeURL
                                                                                            error:&error];
    NSManagedObjectModel *destinationModel = [persistentStoreCoordinator managedObjectModel];
    BOOL pscCompatibile = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
    NSLog(@"Migration needed? %d", !pscCompatibile);
    return !pscCompatibile;
}

- (void)migrateDatabase
{
    
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    if (currentQueue == mainQueue) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kStartMigrationNotification object:self];
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:kStartMigrationNotification object:self];
        });
    }
    
    id psc = [self persistentStoreCoordinator];
    
    if (psc == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:kMigrationFailedNotification object:self];
        });
    }else {
        if (currentQueue == mainQueue) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kMigrationFinishedNotification object:self];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:kMigrationFinishedNotification object:self];
            });
        }
    }
}

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
//        //各个context之间同步
//        [[NSNotificationCenter defaultCenter]addObserver:_managedObjectContext selector:@selector(mergeChangesFromContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
//        [_managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    }
    return _managedObjectContext;
}

- (NSManagedObjectContext *)newManagedObjectContext
{
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc]init];
        [ctx setPersistentStoreCoordinator:coordinator];
//        //各个context之间同步
//        [[NSNotificationCenter defaultCenter]addObserver:ctx selector:@selector(mergeChangesFromContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
        [ctx setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        return ctx;
    }
    return nil;
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
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,nil];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
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
        MKNetworkEngine *engine = [[MKNetworkEngine alloc]initWithHostName:@"herkuang.info:12345"];
        NSString *errorMsg = [NSString stringWithFormat:@"--------\n%@",[error userInfo]];
        NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:errorMsg,@"content", nil];
        MKNetworkOperation *op = [engine operationWithPath:@"/log" params:params httpMethod:@"POST"];
        [op onCompletion:^(MKNetworkOperation *completedOperation) {
            NSLog(@"report success");
        } onError:^(NSError *error) {
            NSLog(@"report failed");
        }];
        [engine enqueueOperation:op];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)receiveContextSaveNotification:(NSNotification *)notification
{
    NSLog(@"- (void)receiveContextSaveNotification:(NSNotification *)notification;");
    if (_managedObjectContext != nil && notification.object != self.managedObjectContext) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        NSLog(@"do merge");
    }
}

@end
