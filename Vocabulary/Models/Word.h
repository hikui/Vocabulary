//
//  Word.h
//  Vocabulary
//
//  Created by 缪和光 on 2/11/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VBaseModel.h"

@class Note, PronunciationData, Word, WordList;

@interface Word : VBaseModel

/**
 词解
 */
@property (nonatomic, retain) NSString * acceptation;

/**
 熟悉度
 */
@property (nonatomic, retain) NSNumber * familiarity;

/**
 是否手动输入（如果手动输入，不需要从网上请求词解）
 */
@property (nonatomic, retain) NSNumber * manuallyInput;

/**
 是否已从网上取得词解
 */
@property (nonatomic, retain) NSNumber * hasGotDataFromAPI;

/**
 单词本身
 */
@property (nonatomic, retain) NSString * key;

/**
 最后复习时间
 */
@property (nonatomic, retain) NSDate * lastVIewDate;

/**
 英式音标
 */
@property (nonatomic, retain) NSString * psEN;

/**
 美式音标
 */
@property (nonatomic, retain) NSString * psUS;

/**
 例句
 */
@property (nonatomic, retain) NSString * sentences;

/**
 发音
 */
@property (nonatomic, retain) PronunciationData *pronunciation;

/**
 易混淆词汇
 */
@property (nonatomic, retain) NSSet *similarWords;

/**
 存在于wordList
 */
@property (nonatomic, retain) NSSet *wordLists;

/**
 笔记
 */
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
