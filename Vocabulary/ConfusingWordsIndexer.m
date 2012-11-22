//
//  ConfusingWordsIndexer.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-11-22.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ConfusingWordsIndexer.h"

@implementation ConfusingWordsIndexer

+ (void)beginIndex
{
    NSDate *date = [NSDate date];
    
    NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance]managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:ctx];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
//    [request setPropertiesToFetch:@[@"key"]];
//    [request setResultType:NSDictionaryResultType];
    [request setIncludesPropertyValues:NO];
    [request setReturnsObjectsAsFaults:YES];
    NSArray *allWords = [ctx executeFetchRequest:request error:nil];
    NSLog(@"result.count:%d",allWords.count);
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(similarWords.@count == 0)"];
    //request for unindexed words
    [request setPredicate:predicate];
    [request setResultType:NSManagedObjectResultType];
    NSArray *notIndexedWords = [ctx executeFetchRequest:request error:nil];
    NSTimeInterval timeCost = -[date timeIntervalSinceNow];
    NSLog(@"查询用时 :%f",timeCost);
    date = [NSDate date];
    
    //request for all words real obj
    [request setIncludesPropertyValues:NO];
    [request setFetchLimit:1];
    
    for (Word *w in notIndexedWords) {
        for (Word *similarWord in allWords) {
//            NSString *key = [dict objectForKey:@"key"];
            float distance = [self compareString:similarWord.key withString:w.key];
            if (distance >0/*等于0为这个词本身*/ && (distance<3 ||
                ((float)[self longestCommonSubstringWithStr1:similarWord.key str2:w.key])/MAX(similarWord.key.length, w.key.length)>0.5)) {
                
//                NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"key == %@",key];
//                [request setPredicate:predicate2];
//                NSArray *similarWordArr = [ctx executeFetchRequest:request error:nil];
//                if (similarWordArr.count>0) {
//                    Word *similarWord = [similarWordArr objectAtIndex:0];
//                    [w addSimilarWordsObject:similarWord];
//
//                }
                [w addSimilarWordsObject:similarWord];
            }
        }
    }
    [[CoreDataHelper sharedInstance]saveContext];
    timeCost = -[date timeIntervalSinceNow];
    NSLog(@"索引用时:%f",timeCost);
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
