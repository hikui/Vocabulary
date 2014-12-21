//
//  PronunciationData.h
//  Vocabulary
//
//  Created by 缪和光 on 2/11/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VBaseModel.h"

@class Word;

@interface PronunciationData : VBaseModel

@property (nonatomic, retain) NSData * pronData;
@property (nonatomic, retain) Word *word;

@end
