//
//  PlanMaker.m
//  Vocabulary
//
//  Created by 缪和光 on 14-9-11.
//  Copyright (c) 2014年 缪和光. All rights reserved.
//

#import "PlanMaker.h"
#import "Plan.h"
#import "NSDate+VAdditions.h"

@interface PlanMaker ()

@end

@implementation PlanMaker


+ (PlanMaker *)sharedInstance {
    static PlanMaker *sharedMaker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMaker = [[PlanMaker alloc]init];
    });
    return sharedMaker;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)_refreshPlan {
    
    
}

- (Plan *)todaysPlan {
    __block Plan *plan = [Plan MR_findFirst];
    BOOL shouldMakeAPlan = NO;
    if (plan == nil) {
        shouldMakeAPlan = YES;
    }
    if (plan.learningPlan == nil) {
        shouldMakeAPlan = YES;
    }
    NSDate *today = [[NSDate date]hkv_dateWithoutTime];
    NSDate *planCreateDate = [plan.createDate hkv_dateWithoutTime];
    if (planCreateDate == nil || [planCreateDate compare:today] == NSOrderedAscending) {
        shouldMakeAPlan = YES;
    }
    if (!shouldMakeAPlan) {
        return plan;
    }
    
    // delete old plan
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        [plan MR_deleteEntity];
        plan = [self makeAPlan];
    }];
    return plan;
}

- (Plan *)makeAPlan {
    Plan *plan = [Plan MR_createEntity];
    plan.createDate = [[NSDate date]hkv_dateWithoutTime];
    
    //艾宾浩斯曲线日期递增映射
    NSDictionary *effectiveCount_deltaDay_map =
    @{
      @(1):@(0),
      @(2):@(1),
      @(3):@(2),
      @(4):@(3),
      @(5):@(8)
      };
    
    //筛选学习计划
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(effectiveCount==0)"];
    plan.learningPlan = [WordList MR_findFirstWithPredicate:predicate sortedBy:@"addTime" ascending:YES];
    
    //筛选复习计划
    predicate = [NSPredicate predicateWithFormat:@"(effectiveCount > 0 AND effectiveCount <= 5)"]; //大于5的都不需要学习了
    NSArray *wordListsToReview = [WordList MR_findAllSortedBy:@"addTime" ascending:YES withPredicate:predicate];
//    NSMutableArray *reviewPlan = [[NSMutableArray alloc]init];
    
    for (WordList *wl in wordListsToReview) {
        //上次复习日期+(effectiveCount对应的艾宾浩斯递增天数)=预计复习日期
        NSDate *lastReviewTime = wl.lastReviewTime;
        NSNumber *effectiveCount = wl.effectiveCount;
        int deltaDay = [effectiveCount_deltaDay_map[effectiveCount]intValue];
        NSTimeInterval deltaTimeInterval = deltaDay*24*60*60;
        //计算得到的下次应该复习的时间
        NSDate *expectedNextReviewDate = [lastReviewTime dateByAddingTimeInterval:deltaTimeInterval];
        expectedNextReviewDate = [expectedNextReviewDate hkv_dateWithoutTime];
        NSDate* currDate = [[NSDate date]hkv_dateWithoutTime];
        //比较两个时间
        if ([expectedNextReviewDate compare:currDate] == NSOrderedAscending || [expectedNextReviewDate compare:currDate] == NSOrderedSame) {
            //预计复习日期≤现在日期 需要复习
            [plan addReviewPlanObject:wl];
        }
    }

    return plan;
}

- (void)finishTodaysLearningPlan {
    Plan *plan = [Plan MR_findFirst];
    if (!plan) {
        return;
    }
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        plan.learningFinished = @(YES);
    }];
}

/**
 判断是否需要学新的词汇表
 
 如果今天已经学了，就不再学
 
 @return BOOL
 */
//- (BOOL)_shouldAddLearningPlan {
//    NSDate *lastLearningDate = [[NSUserDefaults standardUserDefaults]objectForKey:kLastLearningTime];
//    lastLearningDate = [lastLearningDate hkv_dateWithoutTime];
//    NSDate *today = [[NSDate date]hkv_dateWithoutTime];
//    if (!lastLearningDate || [lastLearningDate compare:today] == NSOrderedAscending) {
//        //上次学习时间早于今天，需要学习新的词汇表
//        return YES;
//    }
//    return NO;
//}

@end
