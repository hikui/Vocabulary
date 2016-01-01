
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
#define CIBA_URL(__W__) [NSString stringWithFormat:@"search/%@", __W__]
#define HostName @"hikuivocabulary.sinaapp.com"

@implementation CibaEngine

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static CibaEngine* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[CibaEngine alloc] initWithHostName:HostName]; // or some other init method
    });
    return _sharedObject;
}


- (PMKPromise *)requestContentOfWord:(NSString*)word
                      outerOperation:(CibaNetworkOperation **)operation
{
    word = [word hkv_trim];
    word = [word urlEncodedString];
    NSString* urlString = [NSString stringWithFormat:@"http://%@/%@", HostName, CIBA_URL(word)];
    CibaNetworkOperation* op = [[CibaNetworkOperation alloc] initWithURLString:urlString params:nil httpMethod:@"GET"];
    PMKPromise *modifiedPromise = op.promise.then(^(NSData *responseData, CibaNetworkOperation *operation){
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:NULL];
        return PMKManifold(resultDict, operation);
    });
    if (operation != nil) {
        *operation = op;
    }
    [self enqueueOperation:op];
    return modifiedPromise;
}

- (PMKPromise *)requestPronWithURL:(NSString*)url
                    outerOperation:(CibaNetworkOperation **)operation
{
    CibaNetworkOperation* op = [[CibaNetworkOperation alloc] initWithURLString:url params:nil httpMethod:@"GET"];
    [self enqueueOperation:op];
    return op.promise.catch(^(NSError *error){
        //自己先包装一层
        NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDomain code:FillWordPronError userInfo:error.userInfo];
        return myError;
    });
}

- (PMKPromise *)fillWord:(Word*)word
          outerOperation:(CibaNetworkOperation **)operation
{
    PMKPromise *modifiedPromise = [self requestContentOfWord:word.key outerOperation:operation].then(^(NSDictionary *resultDict){
        if (!resultDict || resultDict[@"error"]!=nil) {
            NSError *myError = [[NSError alloc]initWithDomain:CibaEngineDomain code:FillWordError userInfo:nil];
            return (id)myError;
        }
        [CibaEngine fillWord:word withResultDict:resultDict];
        NSString *pronURL = resultDict[@"pron_us"];
        if (pronURL == nil) {
            pronURL = resultDict[@"pron_uk"];
        }
        return (id)[self requestPronWithURL:pronURL outerOperation:nil];
    }).then(^(NSData *soundData){
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Word *localWord = [word MR_inContext:localContext];
            PronunciationData *pron = [PronunciationData MR_createEntityInContext:localContext];
            pron.pronData = soundData;
            localWord.pronunciation = pron;
        }];
    }).catch(^(NSError *error){
        if ([error.domain isEqualToString: CibaEngineDomain] && error.code != FillWordPronError) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                Word *localWord = [word MR_inContext:localContext];
                localWord.hasGotDataFromAPI = @(NO);
            }];
        }
        return error;
    });
    return modifiedPromise;
}


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
