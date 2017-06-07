//
//  PlanMaker.h
//  Vocabulary
//
//  Created by 缪和光 on 14-9-11.
//  Copyright (c) 2014年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Plan;
@class WordList;

@interface PlanMaker : NSObject

+ (PlanMaker *)sharedInstance;

/**
 取得今日需要完成的计划（包括学习计划、复习计划）
 
 返回的plan对象将出现在defaultContext中
 
 @return Plan
 */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) Plan *todaysPlan;

/**
 当完成今日的学习计划时，调用此函数
 */
//- (void)finishTodaysLearningPlan;

/**
 从todays plan中删除一个WordList
 @param wordList 要删除的WordList
 */
- (void)removeWordListFromTodaysPlan:(WordList *)wordList;

@end
