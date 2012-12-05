//
//  WordListCreator.m
//  Vocabulary
//
//  Created by 缪和光 on 12-11-3.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "WordListCreator.h"
#import "ConfusingWordsIndexer.h"

@implementation WordListCreator

+ (void)createWordListAsyncWithTitle:(NSString *)title
                             wordSet:(NSSet *)wordSet
                       progressBlock:(HKVProgressCallback)progressBlock
                          completion:(HKVErrorBlock)completion
{
    //初步过滤，可能会有空字符串问题
    if (wordSet == nil || wordSet.count == 0) {
        //没有单词
        NSError *error = [[NSError alloc]initWithDomain:WordListCreatorDormain code:WordListCreatorEmptyWordSetError userInfo:nil];
        if (completion != NULL) {
            completion(error);
        }
        return;
    }
    
    if (title == nil || title.length == 0) {
        // no title
        NSError *error = [[NSError alloc]initWithDomain:WordListCreatorDormain code:WordListCreatorNoTitleError userInfo:nil];
        if (completion != NULL) {
            completion(error);
        }
        return;
    }
    
    dispatch_queue_t originalQueue = dispatch_get_current_queue();
    dispatch_retain(originalQueue);
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        NSManagedObjectContext *moc = [helper newManagedObjectContext];
        
        //search if a word list with same title already exist
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"WordList"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@",title];
        [request setPredicate:predicate];
        NSArray *result = [moc executeFetchRequest:request error:nil];
        
        NSString *titleInBlock = [title copy];
        
        if (result.count>0) {
            //名字重复，后面加个(1)
            titleInBlock = [titleInBlock stringByAppendingString:@"(1)"];
        }
        
        WordList *newList = [NSEntityDescription insertNewObjectForEntityForName:@"WordList" inManagedObjectContext:moc];
        newList.title = titleInBlock;
        newList.addTime = [NSDate date];
        
        NSFetchRequest *wordRequest = [[NSFetchRequest alloc]init];
        NSEntityDescription *wordEntity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:moc];
        [wordRequest setEntity:wordEntity];
        [wordRequest setIncludesPropertyValues:NO];
        NSMutableArray *newWordsToBeIndexed = [[NSMutableArray alloc]initWithCapacity:wordSet.count];
        
        for (NSString *aWord in wordSet) {
            if (aWord.length == 0) {
                //出现空字符串
                continue;
            }
            NSString *lowercaseWord = [aWord lowercaseString];
            lowercaseWord = [lowercaseWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (lowercaseWord.length == 0) {
                continue;
            }
            //检查是否已经存在这个单词
            NSPredicate *wordPredicate = [NSPredicate predicateWithFormat:@"(key == %@)",lowercaseWord];
            [wordRequest setPredicate:wordPredicate];
            NSArray *resultWords = [moc executeFetchRequest:wordRequest error:nil];
            if (resultWords.count > 0) {
                //存在，直接添加
                Word *w = [resultWords objectAtIndex:0];
                [newList addWordsObject:w];
            }else{
                //不存在，新建
                Word *newWord = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:moc];
                newWord.key = lowercaseWord;
                [newList addWordsObject:newWord];
                [newWordsToBeIndexed addObject:newWord];
            }
        }
        //再次检查是否为空，排除空字符串干扰
        if (newList.words.count>0) {
            NSError *saveErr = nil;
            [moc save:&saveErr];
            
            if (saveErr == nil) {
                //索引易混淆词
                //                NSError *indexError = nil;
                if (newWordsToBeIndexed.count > 0) {
                    
                    //!!! objectId在save前后值会变换
                    NSMutableArray *ids = [[NSMutableArray alloc]initWithCapacity:newWordsToBeIndexed.count];
                    for (int i = 0; i< newWordsToBeIndexed.count; i++) {
                        Word *w = newWordsToBeIndexed[i];
                        [ids addObject:w.objectID];
                    }
                    
                    [ConfusingWordsIndexer indexNewWordsAsyncById:ids progressBlock:^(float progress) {
                        dispatch_async(originalQueue, ^{
                            if (progressBlock != NULL) progressBlock(progress);
                        });
                    } completion:^(NSError *error) {
                        dispatch_async(originalQueue, ^{
                            if (completion != NULL) completion(error);
                        });
                    }];
                    
//                    [ConfusingWordsIndexer indexNewWordsAsyncById:ids completion:^(NSError *error) {
//                        dispatch_async(originalQueue, ^{
//                            completion(error);
//                        });
//                    }];
                    return;
                    //                    [ConfusingWordsIndexer indexNewWordsSyncById:ids managedObjectContext:moc error:&indexError];
                }else {
                    if (completion != NULL) {
                        dispatch_async(originalQueue, ^{
                            completion(nil);
                        });
                    }
                    return;
                }
                
            }else{
                NSLog(@"create words save error:%@",saveErr);
                if (completion != NULL) {
                    dispatch_async(originalQueue, ^{
                        completion(saveErr);
                    });
                }
                return;
            }
        }else{
            NSError *error = [[NSError alloc]initWithDomain:WordListCreatorDormain code:WordListCreatorEmptyWordSetError userInfo:nil];
            [moc deleteObject:newList];
            if (completion != NULL) {
                dispatch_async(originalQueue, ^{
                    completion(error);
                });
            }
            return;
        }
    });
}

+ (void)createWordListAsyncWithTitle:(NSString *)title
                             wordSet:(NSSet *)wordSet
                          completion:(HKVErrorBlock)completion
{
    [WordListCreator createWordListAsyncWithTitle:title wordSet:wordSet progressBlock:NULL completion:completion];
}

+ (void)addWords:(NSSet *)wordSet
      toWordListId:(NSManagedObjectID *)wordlistId
   progressBlock:(HKVProgressCallback)progressBlock
      completion:(HKVErrorBlock)completion
{
    //初步过滤，可能会有空字符串问题
    if (wordSet == nil || wordSet.count == 0) {
        //没有单词
        NSError *error = [[NSError alloc]initWithDomain:WordListCreatorDormain code:WordListCreatorEmptyWordSetError userInfo:nil];
        if (completion != NULL) {
            completion(error);
        }
        return;
    }
    
    
    dispatch_queue_t originalQueue = dispatch_get_current_queue();
    dispatch_retain(originalQueue);
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        NSManagedObjectContext *moc = [helper newManagedObjectContext];
        
        //search if a word list with same title already exist

        
        NSFetchRequest *wordRequest = [[NSFetchRequest alloc]init];
        NSEntityDescription *wordEntity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:moc];
        [wordRequest setEntity:wordEntity];
        [wordRequest setIncludesPropertyValues:NO];
        NSMutableArray *newWordsToBeIndexed = [[NSMutableArray alloc]initWithCapacity:wordSet.count];
        WordList *wordlist = (WordList *)[moc objectWithID:wordlistId];
        for (NSString *aWord in wordSet) {
            if (aWord.length == 0) {
                //出现空字符串
                continue;
            }
            NSString *lowercaseWord = [aWord lowercaseString];
            lowercaseWord = [lowercaseWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (lowercaseWord.length == 0) {
                continue;
            }
            //检查是否已经存在这个单词
            NSPredicate *wordPredicate = [NSPredicate predicateWithFormat:@"(key == %@)",lowercaseWord];
            [wordRequest setPredicate:wordPredicate];
            NSArray *resultWords = [moc executeFetchRequest:wordRequest error:nil];
            if (resultWords.count > 0) {
                //存在，直接添加
                Word *w = [resultWords objectAtIndex:0];
                [wordlist addWordsObject:w];
            }else{
                //不存在，新建
                Word *newWord = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:moc];
                newWord.key = lowercaseWord;
                [wordlist addWordsObject:newWord];
                [newWordsToBeIndexed addObject:newWord];
            }
        }
        

        NSError *saveErr = nil;
        [moc save:&saveErr];
        
        if (saveErr == nil) {
            //索引易混淆词
            if (newWordsToBeIndexed.count > 0) {
                
                //!!! objectId在save前后值会变换
                NSMutableArray *ids = [[NSMutableArray alloc]initWithCapacity:newWordsToBeIndexed.count];
                for (int i = 0; i< newWordsToBeIndexed.count; i++) {
                    Word *w = newWordsToBeIndexed[i];
                    [ids addObject:w.objectID];
                }
                
                [ConfusingWordsIndexer indexNewWordsAsyncById:ids progressBlock:^(float progress) {
                    dispatch_async(originalQueue, ^{
                        if (progressBlock != NULL) progressBlock(progress);
                    });
                } completion:^(NSError *error) {
                    dispatch_async(originalQueue, ^{
                        if (completion != NULL) completion(error);
                    });
                }];
                
                return;

            }else {
                if (completion != NULL) {
                    dispatch_async(originalQueue, ^{
                        completion(nil);
                    });
                }
                return;
            }
            
        }else{
            NSLog(@"create words save error:%@",saveErr);
            if (completion != NULL) {
                dispatch_async(originalQueue, ^{
                    completion(saveErr);
                });
            }
            return;
        }
        
    });
}

@end
