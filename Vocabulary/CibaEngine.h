//
//  CibaEngine.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-21.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "MKNetworkEngine.h"

@interface CibaEngine : MKNetworkEngine

typedef void (^CompleteBlockWithStr)(NSDictionary *parsedDict);
typedef void (^CompleteBlockWithData)(NSData *data);

+ (id)sharedInstance;

- (MKNetworkOperation *) infomationForWord:(NSString *)word
                              onCompletion:(CompleteBlockWithStr) completionBlock
                                   onError:(MKNKErrorBlock) errorBlock;

- (MKNetworkOperation *) getPronWithURL:(NSString *)url
                           onCompletion:(CompleteBlockWithData) completionBlock
                                onError:(MKNKErrorBlock) errorBlock;
@end
