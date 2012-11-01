//
//  AppDelegate.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-18.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (unsafe_unretained, nonatomic) BOOL finishTodaysLearningPlan;
@property (strong, nonatomic) NSDate *planExpireTime;
//@property (copy, nonatomic) NSURL *todaysPlanWordListIdURIRepresentation;

@end
