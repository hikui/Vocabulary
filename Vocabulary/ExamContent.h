//
//  ExamContent.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-23.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Word.h"

typedef enum {
    ExamTypeE2C, //英译中
    ExamTypeS2E, //听译
} ExamType;


@interface ExamContent : NSObject

@property (nonatomic, unsafe_unretained) ExamType examType;
@property (nonatomic, unsafe_unretained) BOOL neverShow;
@property (nonatomic, strong) Word *word;
@property (nonatomic, unsafe_unretained) int rightTimes;
@property (nonatomic, unsafe_unretained) int wrongTimes;

- (id)initWithWord:(Word *)word examType:(ExamType)examType;
- (int)weight;   //计算权值

@end
