//
//  ConfusingWordsIndexer.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-11-22.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^callback)(float progress);

@interface ConfusingWordsIndexer : NSObject

+ (void)beginIndex;

+ (void)indexNewWords:(NSArray *)newWordsArray saveContextAfterIndex:(BOOL)save;

+ (void)reIndexForAllWithCallback:(callback)callback;

@end
