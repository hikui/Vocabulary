//
//  PlanMaker.h
//  Vocabulary
//
//  Created by 缪和光 on 14-9-11.
//  Copyright (c) 2014年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Plan;
@interface PlanMaker : NSObject

+ (PlanMaker *)sharedInstance;

/**
 取得今日需要完成的计划（包括学习计划、复习计划）
 
 @return Plan
 */
- (Plan *)todaysPlan;

/**
 当完成今日的学习计划时，调用此函数
 */
- (void)finishTodaysLearningPlan;

@end
