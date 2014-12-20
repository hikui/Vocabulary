
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
//  CibaNetworkOperation.m
//  Vocabulary
//
//  Created by Hikui on 12-11-25.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "CibaNetworkOperation.h"
#import "PromiseKit.h"

NSString * const CibaNetworkOperationErrorKey = @"CibaNetworkOperationErrorKey";

@interface CibaNetworkOperation (){
    PMKPromiseFulfiller fufiller;
    PMKPromiseRejecter rejecter;
}

@property (nonatomic, weak) PMKPromise *currentPromise;

@end

@implementation CibaNetworkOperation

- (PMKPromise *)promise {
    PMKPromise *promise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        self->rejecter = reject;
        self->fufiller = fulfill;
        [self addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSData *responseData = [completedOperation responseData];
            fulfill(PMKManifold(responseData, completedOperation));
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
            userInfo[CibaNetworkOperationErrorKey] = completedOperation;
            NSError *newError = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
            reject(newError);
        }];
    }];
    self.currentPromise = promise;
    return promise;
}

#warning 可能引起内存问题
- (void)cancel {
    if (self->rejecter) {
        NSError *error = [NSError errorWithDomain:CibaEngineDomain code:1 userInfo:@{@"Cause":@"Cancel"}];
        self->rejecter(error);
        self->rejecter = nil;
    }
    [super cancel];
}

@end
