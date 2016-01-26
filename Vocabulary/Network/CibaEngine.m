
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
#import <PromiseKit/NSURLConnection+AnyPromise.h>
#define CIBA_URL(__W__) [NSString stringWithFormat:@"search/%@", __W__]
#define HostName @"hikuivocabulary.sinaapp.com"

@interface CibaEngine ()

//@property (nonatomic, strong) NSURLSession *downloadSession;

@end

@implementation CibaEngine

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static CibaEngine* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[CibaEngine alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//        _downloadSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    }
    return self;
}

- (AnyPromise *)requestContentOfWord:(NSString *)word URLSession:(NSURLSession *)session; {
    word = [word hkv_trim];
    word = [word hkv_stringByURLEncoding];
    NSString* urlString = [NSString stringWithFormat:@"http://%@/%@", HostName, CIBA_URL(word)];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                resolve(error);
                return;
            }
            if ([(NSHTTPURLResponse *)response statusCode] < 200 || [(NSHTTPURLResponse *)response statusCode] >= 300) {
                id info = @{
                            NSLocalizedDescriptionKey: @"The server returned a bad HTTP response code",
                            NSURLErrorFailingURLStringErrorKey: request.URL.absoluteString,
                            NSURLErrorFailingURLErrorKey: request.URL,
                            @"RequestType":@"word content"
                            };
                id err = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:info];
                resolve(err);
                return;
            }
            NSError *parseJSONError = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:nil error:&parseJSONError];
            if (parseJSONError) {
                resolve(parseJSONError);
                return;
            }
            resolve(dict);
        }] resume];
    }];
}
- (AnyPromise *)requestPronWithURL:(NSString*)urlString URLSession:(NSURLSession *)session{
    NSURL *url = [NSURL URLWithString:urlString];
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
        [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                resolve(error);
                return;
            }
            if ([(NSHTTPURLResponse *)response statusCode] < 200 || [(NSHTTPURLResponse *)response statusCode] >= 300) {
                id info = @{
                            NSLocalizedDescriptionKey: @"The server returned a bad HTTP response code",
                            NSURLErrorFailingURLStringErrorKey: url.absoluteString,
                            NSURLErrorFailingURLErrorKey: url,
                            @"RequestType":@"word pron"
                            };
                id err = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:info];
                resolve(err);
                return;
            }
            resolve(data);
        }]resume];
    }];
}
- (AnyPromise *)fillWord:(Word*)word URLSession:(NSURLSession *)session {
    return [self requestContentOfWord:word.key URLSession:session].then(^(NSDictionary *resultDict){
        if (!resultDict || resultDict[@"error"]!=nil) {
            id info = @{
                        NSLocalizedDescriptionKey: resultDict[@"error"],
                        @"RequestType":@"word pron"
                        };
            NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDomain code:FillWordError userInfo:info];
            @throw myError;
        }
        [CibaEngine fillWord:word withResultDict:resultDict];
        NSString *pronURL = resultDict[@"pron_us"];
        if (pronURL == nil) {
            pronURL = resultDict[@"pron_uk"];
        }
        return [self requestPronWithURL:pronURL URLSession:session];
    }).then(^(NSData *soundData){
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Word *localWord = [word MR_inContext:localContext];
            PronunciationData *pron = [PronunciationData MR_createEntityInContext:localContext];
            pron.pronData = soundData;
            localWord.pronunciation = pron;
        }];
    }).catch(^(NSError *error){
        if ([((NSString *)error.userInfo[@"RequestType"]) isEqualToString:@"word pron"]) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                Word *localWord = [word MR_inContext:localContext];
                localWord.hasGotDataFromAPI = @(NO);
            }];
        }
        @throw error;
    });
}

//- (PMKPromise *)requestContentOfWord:(NSString*)word
//                      outerOperation:(CibaNetworkOperation **)operation
//{
//    word = [word hkv_trim];
//    word = [word hkv_stringByURLEncoding];
//    NSString* urlString = [NSString stringWithFormat:@"http://%@/%@", HostName, CIBA_URL(word)];
//    CibaNetworkOperation* op = [[CibaNetworkOperation alloc] initWithURLString:urlString params:nil httpMethod:@"GET"];
//    PMKPromise *modifiedPromise = op.promise.then(^(NSData *responseData, CibaNetworkOperation *operation){
//        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:NULL];
//        return PMKManifold(resultDict, operation);
//    });
//    if (operation != nil) {
//        *operation = op;
//    }
//    [self enqueueOperation:op];
//    return modifiedPromise;
//}
//
//- (PMKPromise *)requestPronWithURL:(NSString*)url
//                    outerOperation:(CibaNetworkOperation **)operation
//{
//    CibaNetworkOperation* op = [[CibaNetworkOperation alloc] initWithURLString:url params:nil httpMethod:@"GET"];
//    [self enqueueOperation:op];
//    return op.promise.catch(^(NSError *error){
//        //自己先包装一层
//        NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDomain code:FillWordPronError userInfo:error.userInfo];
//        return myError;
//    });
//}
//
//- (PMKPromise *)fillWord:(Word*)word
//          outerOperation:(CibaNetworkOperation **)operation
//{
//    PMKPromise *modifiedPromise = [self requestContentOfWord:word.key outerOperation:operation].then(^(NSDictionary *resultDict){
//        if (!resultDict || resultDict[@"error"]!=nil) {
//            NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDomain code:FillWordError userInfo:nil];
//            return (id)myError;
//        }
//        [CibaEngine fillWord:word withResultDict:resultDict];
//        NSString *pronURL = resultDict[@"pron_us"];
//        if (pronURL == nil) {
//            pronURL = resultDict[@"pron_uk"];
//        }
//        return (id)[self requestPronWithURL:pronURL outerOperation:nil];
//    }).then(^(NSData *soundData){
//        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//            Word *localWord = [word MR_inContext:localContext];
//            PronunciationData *pron = [PronunciationData MR_createEntityInContext:localContext];
//            pron.pronData = soundData;
//            localWord.pronunciation = pron;
//        }];
//    }).catch(^(NSError *error){
//        if ([error.domain isEqualToString: CibaEngineDomain] && error.code != FillWordPronError) {
//            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//                Word *localWord = [word MR_inContext:localContext];
//                localWord.hasGotDataFromAPI = @(NO);
//            }];
//        }
//        return error;
//    });
//    return modifiedPromise;
//}


+ (void)fillWord:(Word*)word withResultDict:(NSDictionary*)resultDict
{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
        Word *targetWord = [word MR_inContext:localContext];
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
        targetWord.psEN = resultDict[@"ps_uk"];
        targetWord.psUS = resultDict[@"ps_us"];
        targetWord.sentences = resultDict[@"sentence"]!=nil?resultDict[@"sentence"]:@"";
        targetWord.hasGotDataFromAPI = @(YES);
    }];
}

@end
