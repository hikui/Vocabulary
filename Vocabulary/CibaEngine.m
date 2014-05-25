
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
//#import "JSONKit.h"
#define CIBA_URL(__W__)[NSString stringWithFormat:@"search/%@", __W__]
#define HostName @"hikuivocabulary.sinaapp.com"

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
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *jsonData = [completedOperation responseData];
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
        if (resultDict == nil) {
            errorBlock(nil);
        }else{
           completionBlock(resultDict); 
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
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
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data = [completedOperation responseData];
        completionBlock(data);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
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
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSAssert([completedOperation isKindOfClass:[CibaNetworkOperation class]], @"completionOperation is not kind of CibaOperation");
        [self.livingOperations removeObject:completedOperation];
        NSData *jsonData = [completedOperation responseData];
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
        if (resultDict == nil) {
            NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDormain code:FillWordError userInfo:nil];
            errorBlock(myError);
            return;
        }
        if (resultDict[@"error"]!=nil) {
            NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDormain code:FillWordError userInfo:nil];
            errorBlock(myError);
            return;
        }
        [CibaEngine fillWord:word withResultDict:resultDict];

        NSError *err = nil;
        BOOL hasChanges = NO;
        hasChanges = word.managedObjectContext.hasChanges;
        [word.managedObjectContext save:&err];
        //load voice
        NSString *pronURL = [resultDict objectForKey:@"pron_us"];
        if (pronURL == nil) {
            pronURL = [resultDict objectForKey:@"pron_uk"];
        }
        
        //第二次网络访问，取得读音
        CibaNetworkOperation *getPronOp = [[CibaNetworkOperation alloc]initWithURLString:pronURL params:nil httpMethod:@"GET"];
        getPronOp.word = word;
        [getPronOp addCompletionHandler:^(MKNetworkOperation *completedGetPronOp) {
            NSAssert([completedGetPronOp isKindOfClass:[CibaNetworkOperation class]], @"completionOperation is not kind of CibaOperation");
            [self.livingOperations removeObject:completedGetPronOp];
            NSData *data = [completedGetPronOp responseData];
            NSManagedObjectContext *ctx = [[CoreDataHelperV2 sharedInstance]mainContext];
            PronunciationData *pron = [NSEntityDescription insertNewObjectForEntityForName:@"PronunciationData" inManagedObjectContext:ctx];
            pron.pronData = data;
            word.pronunciation = pron;
            word.hasGotDataFromAPI = [NSNumber numberWithBool:YES];
            [[[CoreDataHelperV2 sharedInstance]mainContext]save:nil];
            completion();
            
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDormain code:FillWordPronError userInfo:error.userInfo];
            word.hasGotDataFromAPI = [NSNumber numberWithBool:NO];
            [[[CoreDataHelperV2 sharedInstance]mainContext]save:nil];
            errorBlock(myError);
            [self.livingOperations removeObject:completedOperation];
        }];
        [self enqueueOperation:getPronOp];
        [self.livingOperations addObject:getPronOp];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDormain code:FillWordError userInfo:error.userInfo];
        errorBlock(myError);
        [self.livingOperations removeObject:completedOperation];
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

+ (void)fillWord:(Word *)word withResultDict:(NSDictionary *)resultDict
{
    Word *targetWord = word;
    if (resultDict == nil) {
        // error on parsing
        return;
    }
    
    NSArray *meanings = resultDict[@"meanings"];
    NSMutableString *jointAcceptation = [[NSMutableString alloc]init];
    for (int i=0; i<meanings.count; i++) {
        NSDictionary *aMeaning = meanings[i];
        NSString *tmpPos = aMeaning[@"pos"];
        NSString *tmpAcceptation = aMeaning[@"acceptation"];
        [jointAcceptation appendFormat:@"%@ %@",tmpPos,tmpAcceptation];
    }
    targetWord.acceptation = jointAcceptation;
    targetWord.psEN = [resultDict objectForKey:@"ps_uk"];
    targetWord.psUS = [resultDict objectForKey:@"ps_us"];
    targetWord.sentences = [resultDict objectForKey:@"sentence"]!=nil?[resultDict objectForKey:@"sentence"]:@"";
}

@end
