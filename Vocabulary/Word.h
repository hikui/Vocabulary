//
//  Word.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-19.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WordList;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * acceptation;
@property (nonatomic, retain) NSString * psEN;
@property (nonatomic, retain) NSString * psUS;
@property (nonatomic, retain) NSData * pronounceEN;
@property (nonatomic, retain) NSData * pronounceUS;
@property (nonatomic, retain) NSString * sentences;
@property (nonatomic, retain) NSNumber * familiarity;
@property (nonatomic, retain) NSDate * lastVIewDate;
@property (nonatomic, retain) NSNumber * hasGotDataFromAPI;
@property (nonatomic, retain) WordList *wordList;

@end
