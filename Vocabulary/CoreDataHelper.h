//
//  CoreDataHelper.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

+ (id)sharedInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// create new managed object context especially for core data concurrency
- (NSManagedObjectContext *)newManagedObjectContext;

@end
