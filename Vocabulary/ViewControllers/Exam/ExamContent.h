
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
//  ExamContent.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-23.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Word.h"

typedef NS_ENUM(NSInteger, ExamType) {
    ExamTypeE2C, //英译中
    ExamTypeS2E, //听译
    ExamTypeC2E  //中译英
} ;


@interface ExamContent : NSObject

@property (nonatomic, unsafe_unretained) ExamType examType;
@property (nonatomic, strong) Word *word;
@property (nonatomic, unsafe_unretained) int rightTimes;
@property (nonatomic, unsafe_unretained) int wrongTimes;
@property (nonatomic, strong) NSDate *lastReviewDate;

- (instancetype)initWithWord:(Word *)word examType:(ExamType)examType;
@property (NS_NONATOMIC_IOSONLY, readonly) int weight;   //计算权值

@end
