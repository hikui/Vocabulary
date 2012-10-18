//
//  Word.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-18.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSString * meaning;
@property (nonatomic, retain) NSNumber * qualification;
@property (nonatomic, retain) NSDate * lastReviewDate;
@property (nonatomic, retain) NSManagedObject *wordList;

@end
