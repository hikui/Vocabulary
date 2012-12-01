//
//  ConfusingWordsIndexer.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-11-22.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ConfusingWordsIndexer.h"

@implementation ConfusingWordsIndexer


+ (void)indexNewWordsAsyncById:(NSArray *)newWordsIDArray progressBlock:(HKVProgressCallback)progressBlock completion:(HKVErrorBlock)completion
{
    BOOL needIndex = [[NSUserDefaults standardUserDefaults]boolForKey:kAutoIndex];
    if (!needIndex) {
        if (completion != NULL) {
            completion(nil);
        }
        return;
    }
    
    
    
    dispatch_queue_t originDispatchQueue = dispatch_get_current_queue();
    dispatch_retain(originDispatchQueue);
    if (newWordsIDArray.count == 0) {
        if (completion != NULL) {
            completion(nil);
        }
        return;
    }
    
    dispatch_queue_t indexQueue = dispatch_queue_create("info.herkuang.vocabulary.indexNewWordsQueue", NULL);
    dispatch_async(indexQueue, ^{
        
        NSDate *date = [NSDate date];
        NSError *error = nil;
        
        NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance]newManagedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:ctx];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        [request setEntity:entity];
        [request setPropertiesToFetch:@[@"key"]];
        [request setResultType:NSDictionaryResultType];
        [request setReturnsObjectsAsFaults:YES];
        [request setSortDescriptors:@[sortDescriptor]];
        
        NSArray *allWordsKey = [ctx executeFetchRequest:request error:&error];
        
        if (error != nil) {
            if (completion != NULL) {
                dispatch_async(originDispatchQueue, ^{
                    completion(error);
                });
            }
            
            dispatch_release(originDispatchQueue);
            return;
        }
        
        [request setResultType:NSManagedObjectResultType];
        [request setIncludesPropertyValues:NO];
        
        NSArray *allWordsPlaceholderArray = [ctx executeFetchRequest:request error:&error];
        if (error != nil) {
            if (completion != NULL) {
                dispatch_async(originDispatchQueue, ^{
                    completion(error);
                });
            }
            dispatch_release(originDispatchQueue);
            return;
        }
        
        NSTimeInterval timeCost = -[date timeIntervalSinceNow];
        NSLog(@"查询用时 :%f",timeCost);
        
        date = [NSDate date];
        
        
        int totalNum = newWordsIDArray.count;
        int finishedNum = 0;
        
        //与已有的words做比较
        for (NSManagedObjectID *aNewWordId in newWordsIDArray) {
            Word *aNewWord = (Word *)[ctx objectRegisteredForID:aNewWordId];
            NSString *key1 = aNewWord.key;
            for (int i = 0; i< allWordsKey.count; i++) {
                NSDictionary *dict = [allWordsKey objectAtIndex:i];
                NSString *key2 = [dict objectForKey:@"key"];
                if (![key1 isEqualToString:key2]) {
                    @autoreleasepool {
                        float distance = [self compareString:key1 withString:key2];
                        NSInteger lcs = [self longestCommonSubstringWithStr1:key1 str2:key2];
                        if (distance < 3 || ((float)lcs)/MAX(key1.length,key2.length)>0.5) {
                            Word *targetWord = [allWordsPlaceholderArray objectAtIndex:i];
                            //NSLog(@"key1: %@, key2: %@, target:%@",key1,key2,targetWord.key);
                            [aNewWord addSimilarWordsObject:targetWord];
                        }
                    }
                }
            }
            finishedNum ++;
            float progress = ((float)finishedNum)/totalNum;
            dispatch_async(originDispatchQueue, ^{
                if (progressBlock != NULL) progressBlock(progress);
            });
        }
        
        [ctx save:&error];
        if (completion != NULL) {
            dispatch_async(originDispatchQueue, ^{
                completion(error);
            });
        }
        dispatch_release(originDispatchQueue);
        timeCost = -[date timeIntervalSinceNow];
        NSLog(@"索引用时 :%f",timeCost);
    });
}

+ (void)indexNewWordsAsyncById:(NSArray *)newWordsIDArray completion:(HKVErrorBlock)completion
{
    [ConfusingWordsIndexer indexNewWordsAsyncById:newWordsIDArray progressBlock:NULL completion:completion];
}

+ (void)indexNewWordsSyncById:(NSArray *)newWordsIDArray managedObjectContext:(NSManagedObjectContext *)context error:(NSError **)_error
{
    BOOL needIndex = [[NSUserDefaults standardUserDefaults]boolForKey:kAutoIndex];
    if (!needIndex) {
        return;
    }
    
    NSDate *date = [NSDate date];
    NSError *error = nil;

    NSManagedObjectContext *ctx = nil;
    if (context != nil) {
        ctx = context;
    }else{
        ctx = [[CoreDataHelper sharedInstance]newManagedObjectContext];
    }

    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:ctx];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    [request setPropertiesToFetch:@[@"key"]];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsObjectsAsFaults:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSArray *allWordsKey = [ctx executeFetchRequest:request error:&error];
    
    if (error != nil) {
        if (_error != NULL) {
            *_error = error;
        }
        return;
    }
    
    [request setResultType:NSManagedObjectResultType];
    [request setIncludesPropertyValues:NO];
    
    NSArray *allWordsPlaceholderArray = [ctx executeFetchRequest:request error:&error];
    if (error != nil) {
        if (_error != NULL) {
            *_error = error;
        }
        return;
    }
    
    NSTimeInterval timeCost = -[date timeIntervalSinceNow];
    NSLog(@"查询用时 :%f",timeCost);
    
    date = [NSDate date];
    
    //与已有的words做比较
    for (NSManagedObjectID *aNewWordId in newWordsIDArray) {
        Word *aNewWord = (Word *)[ctx objectRegisteredForID:aNewWordId];
        NSString *key1 = aNewWord.key;
        for (int i = 0; i< allWordsKey.count; i++) {
            NSDictionary *dict = [allWordsKey objectAtIndex:i];
            NSString *key2 = [dict objectForKey:@"key"];
            if (![key1 isEqualToString:key2]) {
                @autoreleasepool {
                    float distance = [self compareString:key1 withString:key2];
                    NSInteger lcs = [self longestCommonSubstringWithStr1:key1 str2:key2];
                    if (distance < 3 || ((float)lcs)/MAX(key1.length,key2.length)>=0.5) {
                        Word *targetWord = [allWordsPlaceholderArray objectAtIndex:i];
                       // NSLog(@"key1: %@, key2: %@, target:%@",key1,key2,targetWord.key);
                        [aNewWord addSimilarWordsObject:targetWord];
                    }
                }
            }
        }
    }
    
    [ctx save:&error];
    timeCost = -[date timeIntervalSinceNow];
    NSLog(@"索引用时 :%f",timeCost);
    if (error != nil) {
        if (_error != NULL) {
            *_error = error;
        }
        return;
    }
}

+ (void)reIndexForAllWithProgressCallback:(HKVProgressCallback)callback completion:(HKVVoidBlock)completion
{
    dispatch_queue_t originDispatchQueue = dispatch_get_current_queue();
    dispatch_retain(originDispatchQueue);
    NSDate *date = [NSDate date];
    
    
    //concurrency
    
    dispatch_queue_t indexQueue = dispatch_queue_create("info.herkuang.vocabulary.reindexAllQueue", NULL);
    
    dispatch_async(indexQueue, ^{
        //创建新的context，适应并发
//        NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance]newManagedObjectContext];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:ctx];
//        NSFetchRequest *request = [[NSFetchRequest alloc]init];
//        [request setEntity:entity];
//        NSArray *allWords = [ctx executeFetchRequest:request error:nil];
//        
//        NSTimeInterval queryTime = - [date timeIntervalSinceNow];
//        NSLog(@"数据库查询时间：%f",queryTime);
        
        
        NSError *error = nil;
        
        NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance]newManagedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:ctx];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        [request setEntity:entity];
        [request setPropertiesToFetch:@[@"key"]];
        [request setResultType:NSDictionaryResultType];
        [request setReturnsObjectsAsFaults:YES];
        [request setSortDescriptors:@[sortDescriptor]];
        
        NSArray *allWordsKey = [ctx executeFetchRequest:request error:&error];
        NSAssert(error == nil, @"has error");
        
        [request setResultType:NSManagedObjectResultType];
        [request setIncludesPropertyValues:NO];
        
        NSArray *allWordsPlaceholderArray = [ctx executeFetchRequest:request error:&error];
        NSAssert(error == nil, @"has error");
        
        NSTimeInterval timeCost = -[date timeIntervalSinceNow];
        NSLog(@"查询用时 :%f",timeCost);
        
        
        
        NSMutableDictionary *wordRelativeMap = [[NSMutableDictionary alloc]initWithCapacity:allWordsKey.count];
        
        
        
        
        int totalNum = allWordsKey.count;
        int finishedNum = 0;
        
        
        for (int i = 0; i < allWordsPlaceholderArray.count; i++) {
            Word *w1 = [allWordsPlaceholderArray objectAtIndex:i];
            NSString *key1 = [[allWordsKey objectAtIndex:i]objectForKey:@"key"];
            for (int j = 0; j < allWordsPlaceholderArray.count; j++) {
                Word *w2 = [allWordsPlaceholderArray objectAtIndex:j];
                NSString *key2 = [[allWordsKey objectAtIndex:j]objectForKey:@"key"];
                if (i != j) {
                    @autoreleasepool {
                        NSMutableSet *_simularWords = [wordRelativeMap objectForKey:key1];
                        if ([_simularWords containsObject:key2]) {
                            continue;
                        }
                        float distance = [self compareString:key1 withString:key2];
                        NSInteger lcs = [self longestCommonSubstringWithStr1:key1 str2:key2];
                        if (distance < 3 || ((float)lcs)/MAX(key1.length, key2.length)>0.5) {
                            [w1 addSimilarWordsObject:w2];
                            
                            NSMutableSet *simularWords1 = [wordRelativeMap objectForKey:key1];
                            if (simularWords1 == nil) {
                                simularWords1 = [[NSMutableSet alloc]init];
                            }
                            [simularWords1 addObject:key2];
                            
                            NSMutableSet *simularWords2 = [wordRelativeMap objectForKey:key2];
                            if (simularWords2 == nil) {
                                simularWords2 = [[NSMutableSet alloc]init];
                            }
                            [simularWords2 addObject:key1];
                            //NSLog(@"%@,%@",w1.key,w2.key);
                        }
                    }
                }
            }
            finishedNum ++;
            float progress = ((float)finishedNum)/totalNum;
            dispatch_async(originDispatchQueue, ^{
                callback(progress);
            });
        }
        [ctx save:nil];
        if (completion != NULL) {
            dispatch_async(originDispatchQueue, completion);
        }
        dispatch_release(originDispatchQueue);
        timeCost = -[date timeIntervalSinceNow];
        NSLog(@"整体易混淆单词索引用时:%f",timeCost);
    
    });
    
    
}

+ (float)compareString:(NSString *)originalString withString:(NSString *)comparisonString
{
    // Normalize strings
    [originalString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [comparisonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    originalString = [originalString lowercaseString];
    comparisonString = [comparisonString lowercaseString];
    
    // Step 1 (Steps follow description at http://www.merriampark.com/ld.htm)
    NSInteger k, i, j, cost, * d, distance;
    
    NSInteger n = [originalString length];
    NSInteger m = [comparisonString length];
    
    if( n++ != 0 && m++ != 0 ) {
        
        d = malloc( sizeof(NSInteger) * m * n );
        
        // Step 2
        for( k = 0; k < n; k++)
            d[k] = k;
        
        for( k = 0; k < m; k++)
            d[ k * n ] = k;
        
        // Step 3 and 4
        for( i = 1; i < n; i++ )
            for( j = 1; j < m; j++ ) {
                
                // Step 5
                if( [originalString characterAtIndex: i-1] ==
                   [comparisonString characterAtIndex: j-1] )
                    cost = 0;
                else
                    cost = 1;
                
                // Step 6
                d[ j * n + i ] = [self smallestOf: d [ (j - 1) * n + i ] + 1
                                            andOf: d[ j * n + i - 1 ] + 1
                                            andOf: d[ (j - 1) * n + i - 1 ] + cost ];
                
                // This conditional adds Damerau transposition to Levenshtein distance
                if( i>1 && j>1 && [originalString characterAtIndex: i-1] ==
                   [comparisonString characterAtIndex: j-2] &&
                   [originalString characterAtIndex: i-2] ==
                   [comparisonString characterAtIndex: j-1] )
                {
                    d[ j * n + i] = [self smallestOf: d[ j * n + i ]
                                               andOf: d[ (j - 2) * n + i - 2 ] + cost ];
                }
            }
        
        distance = d[ n * m - 1 ];
        
        free( d );
        
        return distance;
    }
    return 0.0;
}

// Return the minimum of a, b and c - used by compareString:withString:
+ (NSInteger)smallestOf:(NSInteger)a andOf:(NSInteger)b andOf:(NSInteger)c
{
    NSInteger min = a;
    if ( b < min )
        min = b;
    
    if( c < min )
        min = c;
    
    return min;
}

+ (NSInteger)smallestOf:(NSInteger)a andOf:(NSInteger)b
{
    NSInteger min=a;
    if (b < min)
        min=b;
    
    return min;
}

#pragma mark - lcs
+ (NSInteger)longestCommonSubstringWithStr1:(NSString *)str1 str2:(NSString *)str2
{
    NSInteger m, n, *d, maxLen;
    m = str1.length;
    n = str2.length;
    
    maxLen = 0;
    d = malloc( sizeof(NSInteger) * m * n );
    
    for (int i = 0; i<n; i++) {
        for (int j = 0; j<m; j++) {
            if ([str1 characterAtIndex:j] != [str2 characterAtIndex:i]) {
                d[j*n+i] = 0;
            }else{
                if (i==0 || j==0) {
                    d[j*n+i] = 1;
                }else{
                    d[j*n+i] = 1 + d[(j-1)*n+i-1];
                }
                if (d[j*n+i] > maxLen) {
                    maxLen = d[j*n+i];
                }
            }
        }
    }
    free(d);
    return maxLen;
}

@end
