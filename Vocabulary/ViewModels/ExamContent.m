
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
//  ExamContent.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-23.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ExamContent.h"

@implementation ExamContent

- (instancetype)initWithWord:(Word *)word examType:(ExamType)examType
{
    self = [super init];
    if (self) {
        _word = word;
        _neverShow = NO;
        _rightTimes = _wrongTimes = 0;
        _examType = examType;
    }
    return self;
}

- (int)weight
{
    //权值=等待时间/熟悉度
    //熟悉度=正确次数/错误次数
    //权值=错误次数*时间/正确次数
    
    NSTimeInterval time = [_lastReviewDate timeIntervalSinceNow]*(-1);
    
    float familiarity = 0;
    if (self.rightTimes != 0 || self.wrongTimes != 0) {
        familiarity = ((float)(self.rightTimes))/(self.rightTimes+self.wrongTimes);
    }
    if (familiarity == 0) {
        //防止除0
        familiarity = 0.01;
    }
    int weight = (int)(sqrt(time)/(familiarity*familiarity));
    if (weight <0) {
        //溢出
        weight = -weight;
    }
    return weight;
}

- (NSString *)description
{
    NSString *type = nil;
    if (self.examType == ExamTypeE2C) {
        type = @"E2C";
    }else{
        type = @"S2E";
    }
    return [NSString stringWithFormat:@"word:%@,type:%@,weight:%d",[self.word description],type,[self weight]];
}

@end
