//
//  CibaEngine.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-21.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "MKNetworkEngine.h"
#import "CibaNetworkOperation.h"

@interface CibaEngine : MKNetworkEngine

@property (nonatomic, strong) NSMutableSet *livingOperations;

+ (id)sharedInstance;

- (MKNetworkOperation *) infomationForWord:(NSString *)word
                              onCompletion:(CompleteBlockWithStr) completionBlock
                                   onError:(MKNKErrorBlock) errorBlock;

- (MKNetworkOperation *) getPronWithURL:(NSString *)url
                           onCompletion:(CompleteBlockWithData) completionBlock
                                onError:(MKNKErrorBlock) errorBlock;

/**
 一次性填充整个word
 */
- (CibaNetworkOperation *) fillWord:(Word *)word
                     onCompletion:(HKVVoidBlock)completion
                          onError:(HKVErrorBlock)error;

//删除一个单词的请求
- (void) cancelOperationOfWord:(Word *)word;

@end
