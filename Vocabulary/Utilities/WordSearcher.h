//
//  WordSearcher.h
//  Vocabulary
//
//  Created by 缪 和光 on 13-1-8.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordSearcher : NSObject

@property (nonatomic, strong) NSOperationQueue *queryOperationQueue;

- (void)searchWord:(NSString *)word completion:(void(^)(NSArray *words)) completion;

@end
