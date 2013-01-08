
/*
 *  This file is part of 记词助手.
 *
 *	记词助手 is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License Version 2 as 
 *  published by the Free Software Foundation.
 *
 *	记词助手 is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with 记词助手.  If not, see <http://www.gnu.org/licenses/>.
 */

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
#define HostName @"dict-co.iciba.com"

@implementation CibaEngine

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static CibaEngine *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[CibaEngine alloc] initWithHostName:HostName]; // or some other init method
        _sharedObject.livingOperations = [[NSMutableSet alloc]init];
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


/**
 一次性填充整个word
 */
- (CibaNetworkOperation *) fillWord:(Word *)word
                     onCompletion:(HKVVoidBlock)completion
                          onError:(HKVErrorBlock)errorBlock
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/%@",HostName,CIBA_URL(word.key)];
    CibaNetworkOperation *operation = [[CibaNetworkOperation alloc]initWithURLString:urlString params:nil httpMethod:@"GET"];
    operation.word = word;
    [operation onCompletion:^(MKNetworkOperation *completedOperation) {
        NSAssert([completedOperation isKindOfClass:[CibaNetworkOperation class]], @"completionOperation is not kind of CibaOperation");
        [self.livingOperations removeObject:completedOperation];
        NSString *xmlString = [completedOperation responseString];
        NSDictionary *resultDict = [CibaXMLParser parseWithXMLString:xmlString];
        if (resultDict == nil) {
            NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDormain code:FillWordError userInfo:nil];
            errorBlock(myError);
            return;
        }
        word.acceptation = [resultDict objectForKey:@"acceptation"];
        word.psEN = [resultDict objectForKey:@"psEN"];
        word.psUS = [resultDict objectForKey:@"psUS"];
        word.sentences = [resultDict objectForKey:@"sentence"];

        [[CoreDataHelper sharedInstance]saveContext];
        //load voice
        NSString *pronURL = [resultDict objectForKey:@"pronounceUS"];
        if (pronURL == nil) {
            pronURL = [resultDict objectForKey:@"pronounceEN"];
        }
        
        //第二次网络访问，取得读音
        CibaNetworkOperation *getPronOp = [[CibaNetworkOperation alloc]initWithURLString:pronURL params:nil httpMethod:@"GET"];
        getPronOp.word = word;
        [getPronOp onCompletion:^(MKNetworkOperation *completedGetPronOp) {
            NSAssert([completedGetPronOp isKindOfClass:[CibaNetworkOperation class]], @"completionOperation is not kind of CibaOperation");
            [self.livingOperations removeObject:completedGetPronOp];
            NSData *data = [completedGetPronOp responseData];
            NSManagedObjectContext *ctx = [[CoreDataHelper sharedInstance]managedObjectContext];
            PronunciationData *pron = [NSEntityDescription insertNewObjectForEntityForName:@"PronunciationData" inManagedObjectContext:ctx];
            pron.pronData = data;
            word.pronunciation = pron;
            word.hasGotDataFromAPI = [NSNumber numberWithBool:NO];
            [[CoreDataHelper sharedInstance]saveContext];
            completion();
            
        } onError:^(NSError *error) {
            NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDormain code:FillWordPronError userInfo:error.userInfo];
            word.hasGotDataFromAPI = [NSNumber numberWithBool:NO];
            [[CoreDataHelper sharedInstance]saveContext];
            errorBlock(myError);
            [self.livingOperations removeObject:getPronOp];
        }];
        [self enqueueOperation:getPronOp];
        [self.livingOperations addObject:getPronOp];
        
    } onError:^(NSError *error) {
        NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDormain code:FillWordError userInfo:error.userInfo];
        errorBlock(myError);
        [self.livingOperations removeObject:operation];
    }];
    [self enqueueOperation:operation];
    [self.livingOperations addObject:operation];
    return operation;
}

//删除一个单词的请求
- (void) cancelOperationOfWord:(Word *)word
{
    NSMutableSet *operationsToBeRemoved = [[NSMutableSet alloc]init];
    for (CibaNetworkOperation *op in self.livingOperations) {
        if ([op isKindOfClass:[CibaNetworkOperation class]]) {
            if (op.word == word) {
                [op cancel];
                [operationsToBeRemoved addObject:op];
            }
        }
    }
    for (CibaNetworkOperation *op in operationsToBeRemoved) {
        [self.livingOperations removeObject:op];
    }

}

@end
