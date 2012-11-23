//
//  Constants.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-27.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#ifndef Vocabulary_Common_h
#define Vocabulary_Common_h

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

//constants
#define kPerformSoundAutomatically @"performSound"
#define kFinishTodaysPlan @"finishTodaysPlan"
#define kPlanExpireTime @"planExpireTime"
#define kTodaysPlanWordListIdURIRepresentation @"todaysPlanWordListIdURIRepresentation"
#define kDayNotificationTime @"dayNotificationTime"
#define kNightNotificationTime @"nightNotificationTime"


// bock define
typedef void (^HKVProgressCallback)(float progress);
typedef void (^HKVVoidBlock)(void);
typedef void (^HKVErrorBlock)(NSError *error);
#endif
