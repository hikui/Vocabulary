//
//  WordSearcher.m
//  Vocabulary
//
//  Created by 缪 和光 on 13-1-8.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "WordSearcher.h"

@implementation WordSearcher

- (id)init
{
    if (self = [super init]) {
        _queryOperationQueue = [[NSOperationQueue alloc]init];
        _queryOperationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}


- (void)searchWord:(NSString *)word completion:(void(^)(NSArray *words)) completion
{
//    dispatch_queue_t currentQ = dispatch_get_current_queue();
    
    [self.queryOperationQueue cancelAllOperations];

    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *ctx = [[CoreDataHelperV2 sharedInstance]workerManagedObjectContext];
        [ctx performBlock:^{
            if (self.fetchRequest == nil) {
                self.fetchRequest = [[NSFetchRequest alloc]init];
                self.fetchRequest.returnsObjectsAsFaults = NO;
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:ctx];
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
                [self.fetchRequest setEntity:entity];
                [self.fetchRequest setSortDescriptors:@[sort]];
            }
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(key CONTAINS %@)",word];
            [self.fetchRequest setPredicate:predicate];
            NSError *error = nil;
            NSArray *resultFaults = [ctx executeFetchRequest:self.fetchRequest error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *result = [[NSMutableArray alloc]initWithCapacity:resultFaults.count];
                for (NSManagedObject *anObj in resultFaults) {
                    NSManagedObjectContext *mainContext = [[CoreDataHelperV2 sharedInstance]mainContext];
                    Word *w = (Word *)[mainContext objectWithID:anObj.objectID];
                    [result addObject:w];
                }
                completion(result);
            });
        }];
        
        
    }];
    [self.queryOperationQueue addOperation:operation];
}


@end
