//
//  Word.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-11-21.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word, WordList;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * acceptation;
@property (nonatomic, retain) NSNumber * familiarity;
@property (nonatomic, retain) NSNumber * hasGotDataFromAPI;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSDate * lastVIewDate;
@property (nonatomic, retain) NSData * pronounceEN;
@property (nonatomic, retain) NSData * pronounceUS;
@property (nonatomic, retain) NSString * psEN;
@property (nonatomic, retain) NSString * psUS;
@property (nonatomic, retain) NSString * sentences;
@property (nonatomic, retain) NSSet *wordLists;
@property (nonatomic, retain) NSSet *similarWords;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addWordListsObject:(WordList *)value;
- (void)removeWordListsObject:(WordList *)value;
- (void)addWordLists:(NSSet *)values;
- (void)removeWordLists:(NSSet *)values;

- (void)addSimilarWordsObject:(Word *)value;
- (void)removeSimilarWordsObject:(Word *)value;
- (void)addSimilarWords:(NSSet *)values;
- (void)removeSimilarWords:(NSSet *)values;

@end
