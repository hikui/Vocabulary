
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
//  WordListCreator.h
//  Vocabulary
//
//  Created by 缪和光 on 12-11-3.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"
#import "WordList.h"

@interface WordListManager : NSObject

+ (void)createWordListAsyncWithTitle:(NSString *)title
                             wordSet:(NSSet *)wordSet
                       progressBlock:(HKVProgressCallback)progressBlock
                          completion:(HKVErrorBlock)completion;

+ (void)createWordListAsyncWithTitle:(NSString *)title
                             wordSet:(NSSet *)wordSet
                          completion:(HKVErrorBlock)completion;

/**
 从yaml中新建词汇列表
 
 @param title         word list title
 @param yamlContent   yaml格式的内容
 @param progressBlock progress
 @param completion    completion
 */
+ (void)createWordListAsyncWithTitle:(NSString *)title
                    yamlContent:(NSString *)yamlContent
                  progressBlock:(HKVProgressCallback)progressBlock
                     completion:(HKVErrorBlock)completion;

+ (void)deleteWordList:(WordList *)wordList;

/**
 从一段文字中析出所有单词（根据空格、换行等white space chars）
 
 @param content 文字
 
 @return word set
 */
+ (NSSet *)wordSetFromContent:(NSString *)content;

+ (void)addWords:(NSSet *)wordSet
      toWordList:(WordList *)wordlist
   progressBlock:(HKVProgressCallback)progressBlock
      completion:(HKVErrorBlock)completion;
@end
