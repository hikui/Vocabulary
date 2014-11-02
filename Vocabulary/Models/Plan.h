//
//  Plan.h
//  Vocabulary
//
//  Created by 缪和光 on 2/11/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WordList;

@interface Plan : NSManagedObject

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSNumber * learningFinished;
@property (nonatomic, retain) WordList *learningPlan;
@property (nonatomic, retain) NSOrderedSet *reviewPlan;
@end

@interface Plan (CoreDataGeneratedAccessors)

- (void)insertObject:(WordList *)value inReviewPlanAtIndex:(NSUInteger)idx;
- (void)removeObjectFromReviewPlanAtIndex:(NSUInteger)idx;
- (void)insertReviewPlan:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeReviewPlanAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInReviewPlanAtIndex:(NSUInteger)idx withObject:(WordList *)value;
- (void)replaceReviewPlanAtIndexes:(NSIndexSet *)indexes withReviewPlan:(NSArray *)values;
- (void)addReviewPlanObject:(WordList *)value;
- (void)removeReviewPlanObject:(WordList *)value;
- (void)addReviewPlan:(NSOrderedSet *)values;
- (void)removeReviewPlan:(NSOrderedSet *)values;
@end
