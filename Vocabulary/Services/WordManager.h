
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
//  ConfusingWordsIndexer.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-11-22.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"
@import CoreData;

@interface WordManager : NSObject

+ (WordManager *)sharedInstance;

/**
 根据关键词搜索
 
 @param key       关键词
 @param completion 完成回调
 */
+ (void)searchWord:(NSString *)key completion:(void(^)(NSArray *words)) completion;


/**
 对给定的words进行易混淆词汇索引
 
 本方法不另起线程，仅在当前线程工作
 
 @param newWords      单词集，可以是未保存的
 @param context       单词集所在的context
 @param progressBlock 进度回调
 @param completion    完成回调
 */
+ (void)indexNewWordsWithoutSaving:(NSArray *)newWords inContext:(NSManagedObjectContext *)context progressBlock:(HKVProgressCallback)progressBlock completion:(HKVErrorBlock)completion;

/**
 对数据库里所有的单词重新进行易混淆词汇索引
 
 @param progressBlock   进度回调
 @param completion 完成回调
 */
+ (void)reIndexForAllWithProgressCallback:(HKVProgressCallback)progressBlock completion:(HKVVoidBlock)completion;

@end
