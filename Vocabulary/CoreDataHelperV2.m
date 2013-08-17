//
//  CoreDataHelperV2.m
//  Vocabulary
//
//  Created by 缪和光 on 13-6-29.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "CoreDataHelperV2.h"

@implementation CoreDataHelperV2

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainContext = _mainContext;

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static CoreDataHelperV2 *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        [[NSNotificationCenter defaultCenter]addObserver:_sharedObject selector:@selector(receiveContextSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    });
    return _sharedObject;
}

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
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    NSAssert(mainQueue==currentQueue, @"migrationDatabase需要运行在main thread");
    [[NSNotificationCenter defaultCenter]postNotificationName:kStartMigrationNotification object:self];
    
    __block NSError *err = nil;
    
    dispatch_queue_t migrationQueue = dispatch_queue_create("MigrationQUeue", NULL);
    dispatch_async(migrationQueue, ^{
        id psc = [self persistentStoreCoordinator];
        dispatch_async(mainQueue, ^{
            [[self mainContext]save:&err];
            if (psc == nil || err != nil) {
                [[NSNotificationCenter defaultCenter]postNotificationName:kMigrationFailedNotification object:self];
            }else {
                [[NSNotificationCenter defaultCenter]postNotificationName:kMigrationFinishedNotification object:self];
            }
        });
    });
}


- (NSManagedObjectContext *)mainContext
{
    if (_mainContext != nil) {
        return _mainContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _mainContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainContext setPersistentStoreCoordinator:coordinator];
    }
    return _mainContext;
}

- (NSManagedObjectContext *)workerManagedObjectContext
{
    NSManagedObjectContext *workerContext = nil;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [workerContext setPersistentStoreCoordinator:coordinator];
    }
    return workerContext;
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
        MKNetworkEngine *engine = [[MKNetworkEngine alloc]initWithHostName:@"herkuang.info:12345"];
        NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
        NSString *errorMsg = [NSString stringWithFormat:@"--------\nChannelId:%@\nBuild:%@\n%@",kChannelId,build,[error userInfo]];
        NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:errorMsg,@"content", nil];
        MKNetworkOperation *op = [engine operationWithPath:@"/log" params:params httpMethod:@"POST"];
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSLog(@"report success");
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
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
    if (_mainContext != nil && notification.object != _mainContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
            NSLog(@"do merge");
        });
    }
}

@end
