
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
//  WordListCreator.m
//  Vocabulary
//
//  Created by 缪和光 on 12-11-3.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "WordListManager.h"
#import "WordManager.h"
#import "NSString+VAdditions.h"
#import "PlanMaker.h"
#import "YAMLSerialization.h"
#import "Note.h"
#import "Word.h"
#import "CoreData+MagicalRecord.h"

@implementation WordListManager

+ (NSString *)wordListNameWithTitle:(NSString *)title{
    // Check if the word list name is already used.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@",title];
    // There is a bug in MR_countOfEntitiesWithPredicate: where it uses default context instead of context for current thread. Here I deliberately use MR_contextForCurrentThread without changing its source code.
    NSUInteger *count = [WordList MR_countOfEntitiesWithPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    if (count > 0) {
        /* 
         This name is already used;
         Check if there is a number suffix.
         Possible format would be:
            * abcde
            * abcde_
            * abcd_e
            * abcd_e_123    <- valid
            * abcd_123      <- valid
            * _123
            * _
        */
        NSArray *titleComponents = [title componentsSeparatedByString:@"_"];
        NSString *num = titleComponents.lastObject;
        NSString *firstComponet = titleComponents.firstObject;
        if (titleComponents.count > 1 && [num hkv_isPureInt] && firstComponet.length > 0) {
            // It has a number suffix.
            // e.g. abcd_1
            int iNum = [num intValue];
            iNum++;
            NSRange range = [title rangeOfString:@"_" options:NSBackwardsSearch];
            NSString *rawTitle = [title substringToIndex:range.location];
            // New titile would be abcd_2
            NSString *newTitle = [NSString stringWithFormat:@"%@_%d",rawTitle, iNum];
            return [self wordListNameWithTitle:newTitle];
        }else{
            NSString *newTitle = [NSString stringWithFormat:@"%@_%d",title, 1];
            return [self wordListNameWithTitle:newTitle];
        }
    }
    
    return title;
}

+ (void)createWordListAsyncWithTitle:(NSString *)title
                             wordSet:(NSSet *)wordSet
                       progressBlock:(HKVProgressCallback)progressBlock
                          completion:(HKVErrorBlock)completion
{
    //初步过滤，可能会有空字符串问题
    if (wordSet.count == 0) {
        //没有单词
        NSError *error = [[NSError alloc]initWithDomain:WordListManagerDomain code:WordListCreatorEmptyWordSetError userInfo:nil];
        if (completion != NULL) {
            completion(error);
        }
        return;
    }
    
    if (title == nil || title.length == 0) {
        // no title
        NSError *error = [[NSError alloc]initWithDomain:WordListManagerDomain code:WordListCreatorNoTitleError userInfo:nil];
        if (completion != NULL) {
            completion(error);
        }
        return;
    }
    
    NSString *wordListName = [self wordListNameWithTitle:title];
    __block NSError *createBlockError = nil;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        WordList *newList = [WordList MR_createEntityInContext:localContext];
        newList.title = wordListName;
        newList.addTime = [NSDate date];
        
        NSMutableArray *newWordsToBeIndexed = [[NSMutableArray alloc]initWithCapacity:wordSet.count];
        
        // If a word is already in the database, add the existing one to the word list
        for (NSString *aWordStr in wordSet) {
            NSString *lowercaseWordStr = [aWordStr lowercaseString];
            lowercaseWordStr = [lowercaseWordStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (lowercaseWordStr.length == 0) {
                continue;
            }
            Word *existingWord = [Word MR_findFirstByAttribute:@"key" withValue:lowercaseWordStr inContext:localContext];
            if (existingWord) {
                [newList addWordsObject:existingWord];
            }else{
                Word *newWord = [Word MR_createEntityInContext:localContext];
                newWord.key = lowercaseWordStr;
                [newList addWordsObject:newWord];
                [newWordsToBeIndexed addObject:newWord];
            }
        }
        
        if (newList.words.count == 0) {
            [newList MR_deleteEntityInContext:localContext];
            createBlockError = [[NSError alloc]initWithDomain:WordListManagerDomain code:WordListCreatorEmptyWordSetError userInfo:nil];
            return;
        }
        
        [WordManager indexNewWordsWithoutSaving:newWordsToBeIndexed inContext:localContext progressBlock:progressBlock completion:nil];
        
    } completion:^(BOOL success, NSError *error) {
        NSError *errorToEmit = success ? createBlockError : error;
        if (success && createBlockError == nil) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kWordListChangedNotificationKey object:nil userInfo:@{@"Action":@"Add"}];
            
        }
        if (completion) {
            completion(errorToEmit);
        }
    }];
}

+ (void)createWordListAsyncWithTitle:(NSString *)title
                             wordSet:(NSSet *)wordSet
                          completion:(HKVErrorBlock)completion
{
    [WordListManager createWordListAsyncWithTitle:title wordSet:wordSet progressBlock:nil completion:completion];
}

+ (void)createWordListAsyncWithTitle:(NSString *)title
                    yamlContent:(NSString *)yamlContent
                  progressBlock:(HKVProgressCallback)progressBlock
                     completion:(HKVErrorBlock)completion {
    NSError *yamlParseError = nil;
    NSDictionary *dictFromYaml = [YAMLSerialization objectWithYAMLString:yamlContent options:kYAMLReadOptionStringScalars error:&yamlParseError];
    if (!dictFromYaml || ![dictFromYaml isKindOfClass:[NSDictionary class]]) {
        //没有单词
        NSError *error = yamlParseError ? yamlParseError : [[NSError alloc]initWithDomain:WordListManagerDomain code:WordListCreatorEmptyWordSetError userInfo:nil];
        if (completion != NULL) {
            completion(error);
        }
        return;
    }
    NSString *wordListName = [self wordListNameWithTitle:title];
    __block NSError *createBlockError = nil;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        // 检查dict合法性
        WordList *wordList = [WordList MR_createEntityInContext:localContext];
        wordList.title = wordListName;
        [dictFromYaml enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            if (![key isKindOfClass:[NSString class]]) {
                return;
            }
            NSString *definition = nil;
            NSString *noteStr = nil;
            if ([obj isKindOfClass:[NSString class]]) {
                definition = (NSString *)obj;
            }else if([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *wordInfoDict = (NSDictionary *)obj;
                definition = [wordInfoDict[@"definition"] description];
                noteStr = [wordInfoDict[@"note"] description];
            }else{
                return;
            }
            Word *word = [Word MR_createEntityInContext:localContext];
            word.acceptation = definition;
            word.key = key;
            if (noteStr) {
                Note *note = [Note MR_createEntityInContext:localContext];
                note.textNote = noteStr;
                word.note = note;
            }
            if (definition.length > 0) {
                word.manuallyInput = @(YES);
            }
            [wordList addWordsObject:word];
        }];
        if (wordList.words.count == 0) {
            [wordList MR_deleteEntityInContext:localContext];
            createBlockError = [[NSError alloc]initWithDomain:WordListManagerDomain code:WordListCreatorEmptyWordSetError userInfo:nil];
            return;
        }
        [WordManager indexNewWordsWithoutSaving:[wordList.words allObjects] inContext:localContext progressBlock:progressBlock completion:nil];
    } completion:^(BOOL contextDidSave, NSError *error) {
        NSError *errorToEmit = contextDidSave ? createBlockError : error;
        if (contextDidSave && createBlockError == nil) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kWordListChangedNotificationKey object:nil userInfo:@{@"Action":@"Add"}];
            
        }
        if (completion) {
            completion(errorToEmit);
        }
    }];
}

+ (void)deleteWordList:(WordList *)wordList {
    [[PlanMaker sharedInstance]removeWordListFromTodaysPlan:wordList]; //先从plan中移除，否则会崩溃
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        WordList *localWordList = [wordList MR_inContext:localContext];
        [localWordList MR_deleteEntityInContext:localContext];
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:kWordListChangedNotificationKey object:self userInfo:@{@"Action":@"Delete"}];
}

+ (void)addWords:(NSSet *)wordSet
      toWordList:(WordList *)wordlist
   progressBlock:(HKVProgressCallback)progressBlock
      completion:(HKVErrorBlock)completion
{
    //初步过滤，可能会有空字符串问题
    if (wordSet == nil || wordSet.count == 0) {
        //没有单词
        NSError *error = [[NSError alloc]initWithDomain:WordListManagerDomain code:WordListCreatorEmptyWordSetError userInfo:nil];
        if (completion != NULL) {
            completion(error);
        }
        return;
    }
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        
        WordList *localWordList = [wordlist MR_inContext:localContext];
        
        NSMutableArray *newWordsToBeIndexed = [[NSMutableArray alloc]initWithCapacity:wordSet.count];
        
        // If a word is already in the database, add the existing one to the word list
        for (NSString *aWordStr in wordSet) {
            NSString *lowercaseWordStr = [aWordStr lowercaseString];
            lowercaseWordStr = [lowercaseWordStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (lowercaseWordStr.length == 0) {
                continue;
            }
            Word *existingWord = [Word MR_findFirstByAttribute:@"key" withValue:lowercaseWordStr inContext:localContext];
            if (existingWord) {
                [localWordList addWordsObject:existingWord];
            }else{
                Word *newWord = [Word MR_createEntityInContext:localContext];
                newWord.key = lowercaseWordStr;
                [localWordList addWordsObject:newWord];
                [newWordsToBeIndexed addObject:newWord];
            }
        }
        
        [WordManager indexNewWordsWithoutSaving:newWordsToBeIndexed inContext:localContext progressBlock:progressBlock completion:completion];
        
    } completion:^(BOOL success, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

+ (NSSet *)wordSetFromContent:(NSString *)content {
    NSString *text = content;
    NSMutableSet *wordSet = [[NSMutableSet alloc]init];
    NSScanner *scanner = [NSScanner scannerWithString:text];
    NSString *token;
    while ([scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&token]) {
        [wordSet addObject:token];
    }
    return wordSet;
}

@end
