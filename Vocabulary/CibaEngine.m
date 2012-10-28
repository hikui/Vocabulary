//
//  CibaEngine.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-21.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "CibaEngine.h"
#import "CibaXMLParser.h"
#define CIBA_URL(__W__)[NSString stringWithFormat:@"api/dictionary.php?w=%@", __W__]

@implementation CibaEngine

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initWithHostName:@"dict-co.iciba.com"]; // or some other init method
    });
    return _sharedObject;
}

- (MKNetworkOperation *) infomationForWord:(NSString *)word
                              onCompletion:(CompleteBlockWithStr) completionBlock
                                   onError:(MKNKErrorBlock) errorBlock
{
    MKNetworkOperation *op = [self operationWithPath:CIBA_URL(word)];
    //[[MKNetworkOperation alloc]initWithURLString:CIBA_URL(word) params:nil httpMethod:@"GET"];
    //NSLog(@"%@",op.url);
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSString *xmlString = [completedOperation responseString];
        NSDictionary *resultDict = [CibaXMLParser parseWithXMLString:xmlString];
        completionBlock(resultDict);
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *) getPronWithURL:(NSString *)url
                           onCompletion:(CompleteBlockWithData) completionBlock
                                onError:(MKNKErrorBlock) errorBlock
{
    MKNetworkOperation *op = [[MKNetworkOperation alloc]initWithURLString:url params:nil httpMethod:@"GET"];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSData *data = [completedOperation responseData];
        completionBlock(data);
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:op];
    return op;
}

@end
