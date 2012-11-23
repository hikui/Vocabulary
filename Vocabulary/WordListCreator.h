//
//  WordListCreator.h
//  Vocabulary
//
//  Created by 缪和光 on 12-11-3.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WordListCreatorDormain @"wordListCreatorDormain"
#define WordListCreatorEmptyWordSetError -1
#define WordListCreatorNoTitleError -2

@interface WordListCreator : NSObject

//+ (void)createWordListWithTitle:(NSString *)title
//                        wordSet:(NSSet *)wordSet
//                          error:(NSError **)error;

+ (void)createWordListAsyncWithTitle:(NSString *)title
                             wordSet:(NSSet *)wordSet
                          completion:(HKVErrorBlock)completion;

@end
