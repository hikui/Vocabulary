
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

//#import "MKNetworkEngine.h"
//#import "CibaNetworkOperation.h"
@import UIKit;

@class AnyPromise;
@class Word;

@interface CibaEngine : NSObject

+ (id)sharedInstance;


- (AnyPromise *)requestContentOfWord:(NSString *)word URLSession:(NSURLSession *)session;
- (AnyPromise *)requestPronWithURL:(NSString*)url URLSession:(NSURLSession *)session;
- (AnyPromise *)fillWord:(Word*)word URLSession:(NSURLSession *)session;

/**
 通过dict填充word
 
 @param word       目标word，必须要在main context中存在
 @param resultDict 包含word信息的dict
 */
+ (void)fillWord:(Word*)word withResultDict:(NSDictionary*)resultDict;

@end
