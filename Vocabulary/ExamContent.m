//
//  ExamContent.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-23.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ExamContent.h"

@implementation ExamContent

- (id)initWithWord:(Word *)word examType:(ExamType)examType
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
        familiarity = ((float)(self.rightTimes))/(self.rightTimes+self.wrongTimes); //归一化
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
    return [NSString stringWithFormat:@"content of %@ with type %@",[self.word description],type];
}

@end
