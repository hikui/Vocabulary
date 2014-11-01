//
//  CoreDataHelperV2.h
//  Vocabulary
//
//  Created by 缪和光 on 13-6-29.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStartMigrationNotification @"startMigration"
#define kMigrationFinishedNotification @"migrationFinished"
#define kMigrationFailedNotification @"migRationFailed"

@interface CoreDataHelperV2 : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong, nonatomic) NSManagedObjectContext *mainContext;

+ (id)sharedInstance;
- (NSManagedObjectContext *)workerManagedObjectContext;

// save the main context
//- (void)saveContext;

- (BOOL)isMigrationNeeded;
- (void)migrateDatabase;

@end
