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
#define kAutoIndex @"autoIndex"

#define WordListCreatorDormain @"wordListCreatorDormain"
#define WordListCreatorEmptyWordSetError -1
#define WordListCreatorNoTitleError -2
#define CibaEngineDormain @"info.herkuang.vocabulary.CibaEngine"
#define FillWordError -3
#define FillWordPronError -4

// bock define
typedef void (^HKVProgressCallback)(float progress);
typedef void (^HKVVoidBlock)(void);
typedef void (^HKVErrorBlock)(NSError *error);

typedef void (^CompleteBlockWithStr)(NSDictionary *parsedDict);
typedef void (^CompleteBlockWithData)(NSData *data);
typedef void (^CompleteBlockWithWord)(Word *word);

#endif
