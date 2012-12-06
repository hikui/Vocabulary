//
//  WordListCreator.h
//  Vocabulary
//
//  Created by 缪和光 on 12-11-3.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordListCreator : NSObject

//+ (void)createWordListWithTitle:(NSString *)title
//                        wordSet:(NSSet *)wordSet
//                          error:(NSError **)error;

+ (void)createWordListAsyncWithTitle:(NSString *)title
                             wordSet:(NSSet *)wordSet
                       progressBlock:(HKVProgressCallback)progressBlock
                          completion:(HKVErrorBlock)completion;

+ (void)createWordListAsyncWithTitle:(NSString *)title
                             wordSet:(NSSet *)wordSet
                          completion:(HKVErrorBlock)completion;

+ (void)addWords:(NSSet *)wordSet
      toWordListId:(NSManagedObjectID *)wordlistId
   progressBlock:(HKVProgressCallback)progressBlock
      completion:(HKVErrorBlock)completion;
@end
