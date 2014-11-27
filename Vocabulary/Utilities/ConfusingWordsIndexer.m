
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
//  ConfusingWordsIndexer.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-11-22.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ConfusingWordsIndexer.h"

@implementation ConfusingWordsIndexer


+ (void)asyncIndexNewWords:(NSArray *)newWords progressBlock:(HKVProgressCallback)progressBlock completion:(HKVErrorBlock)completion {
    BOOL needIndex = [[NSUserDefaults standardUserDefaults]boolForKey:kAutoIndex];
    if (!needIndex) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    if (newWords.count == 0) {
        if (completion != NULL) {
            completion(nil);
        }
        return;
    }
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *allWords = [Word MR_findAllInContext:localContext];
        NSUInteger totalNum = newWords.count;
        NSUInteger finishedNum = 0;
        for (Word *anNewWord in newWords) {
            // There is a bug in MagicalRecord when a NSManagedObject has a temporary id.
            // Fix here.
            NSError *error = nil;
            BOOL success = [[anNewWord managedObjectContext] obtainPermanentIDsForObjects:@[anNewWord] error:&error];
            if (!success) {
                [MagicalRecord handleErrors:error];
            }
            Word *anLocalNewWord = [anNewWord MR_inContext:localContext];
            NSString *key1 = anLocalNewWord.key;
            
            for (Word *anExistingWord in allWords) {
                // Don't need to fix temporary id bug, since these words are fetched in current context
                NSString *key2 = anExistingWord.key;
                if (![key1 isEqualToString:key2]) {
                    @autoreleasepool {
                        float distance = [self compareString:key1 withString:key2];
                        NSInteger lcs = [self longestCommonSubstringWithStr1:key1 str2:key2];
                        if (distance < 3 || ((float)lcs)/MAX(key1.length,key2.length)>0.5) {
                            DDLogDebug(@"key1: %@, key2: %@",key1,key2);
                            [anNewWord addSimilarWordsObject:anExistingWord];
                        }
                    }
                }
                finishedNum ++;
                float progress = ((float)finishedNum)/totalNum;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressBlock != NULL) progressBlock(progress);
                });
            }
            
        }
    } completion:^(BOOL success, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

+ (void)reIndexForAllWithProgressCallback:(HKVProgressCallback)callback completion:(HKVVoidBlock)completion
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *allWords = [Word MR_findAllInContext:localContext];
        for (Word *aWord in allWords) {
            // remove all similar words
            [aWord removeSimilarWords:aWord.similarWords];
        }
        NSUInteger totalNum = allWords.count;
        NSUInteger finishedNum = 0;
        for (int i = 0; i < allWords.count; i++) {
            Word *w1 = allWords[i];
            for (int j = i; j < allWords.count; j++) {
                Word *w2 = allWords[j];
                if (i != j) {
                    @autoreleasepool {
                        float distance = [self compareString:w1.key withString:w2.key];
                        NSInteger lcs = [self longestCommonSubstringWithStr1:w1.key str2:w2.key];
                        if (distance < 3 || ((float)lcs)/MAX(w1.key.length, w2.key.length)>0.5) {
                            [w1 addSimilarWordsObject:w2];
                            [w2 addSimilarWordsObject:w1];
                        }
                    }
                }
            }
            
            finishedNum ++;
            float progress = ((float)finishedNum)/totalNum;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(progress);
                }
            });
        }
    } completion:^(BOOL success, NSError *error) {
        if (completion) {
            completion();
        }
    }];
    
        
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
