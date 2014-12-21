//
//  Note.h
//  Vocabulary
//
//  Created by 缪和光 on 2/11/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VBaseModel.h"

@class Word;

@interface Note : VBaseModel

@property (nonatomic, retain) NSString * textNote;
@property (nonatomic, retain) NSSet *attatchments;
@property (nonatomic, retain) Word *word;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)addAttatchmentsObject:(NSManagedObject *)value;
- (void)removeAttatchmentsObject:(NSManagedObject *)value;
- (void)addAttatchments:(NSSet *)values;
- (void)removeAttatchments:(NSSet *)values;

@end
