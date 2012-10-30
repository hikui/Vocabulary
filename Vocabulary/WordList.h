//
//  WordList.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-30.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface WordList : NSManagedObject

@property (nonatomic, retain) NSDate * addTime;
@property (nonatomic, retain) NSNumber * effectiveCount;
@property (nonatomic, retain) NSDate * lastReviewTime;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *words;
@end

@interface WordList (CoreDataGeneratedAccessors)

- (void)addWordsObject:(Word *)value;
- (void)removeWordsObject:(Word *)value;
- (void)addWords:(NSSet *)values;
- (void)removeWords:(NSSet *)values;

@end
