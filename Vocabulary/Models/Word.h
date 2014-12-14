//
//  Word.h
//  Vocabulary
//
//  Created by 缪和光 on 2/11/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note, PronunciationData, Word, WordList;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * acceptation;
@property (nonatomic, retain) NSNumber * familiarity;
@property (nonatomic, retain) NSNumber * hasGotDataFromAPI;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSDate * lastVIewDate;
@property (nonatomic, retain) NSString * psEN;
@property (nonatomic, retain) NSString * psUS;
@property (nonatomic, retain) NSString * sentences;
@property (nonatomic, retain) PronunciationData *pronunciation;
@property (nonatomic, retain) NSSet *similarWords;
@property (nonatomic, retain) NSSet *wordLists;
@property (nonatomic, retain) Note *note;

// transient property

/**
 用于浏览单词和评估界面中text view的内容
 */
@property (nonatomic, readonly) NSAttributedString *attributedWordDetail;

@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addSimilarWordsObject:(Word *)value;
- (void)removeSimilarWordsObject:(Word *)value;
- (void)addSimilarWords:(NSSet *)values;
- (void)removeSimilarWords:(NSSet *)values;

- (void)addWordListsObject:(WordList *)value;
- (void)removeWordListsObject:(WordList *)value;
- (void)addWordLists:(NSSet *)values;
- (void)removeWordLists:(NSSet *)values;

@end
