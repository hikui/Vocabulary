
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
