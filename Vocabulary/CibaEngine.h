
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
