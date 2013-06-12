
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
#define kShouldRefreshTodaysPlanNotificationKey @"shouldRefreshTodaysPlanNotificationKey"

#define WordListCreatorDormain @"wordListCreatorDormain"
#define WordListCreatorEmptyWordSetError -1
#define WordListCreatorNoTitleError -2
#define CibaEngineDormain @"info.herkuang.vocabulary.CibaEngine"
#define FillWordError -3
#define FillWordPronError -4

#define ShowAds NO

#define GlobalBackgroundColor RGBA(227,227,227,1)

#define kChannelId @"91Store"

#define IS_WIDESCREEN ( fabs((double)[[UIScreen mainScreen ] bounds ].size.height -(double)568)< DBL_EPSILON )
#define IS_IPHONE ([[[UIDevice currentDevice ] model ] isEqualToString:@"iPhone"])
#define IS_IPOD   ([[[UIDevice currentDevice ] model ] isEqualToString:@"iPod touch"])
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )
#define IS_IPAD [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad

// bock define
typedef void (^HKVProgressCallback)(float progress);
typedef void (^HKVVoidBlock)(void);
typedef void (^HKVErrorBlock)(NSError *error);

typedef void (^CompleteBlockWithStr)(NSDictionary *parsedDict);
typedef void (^CompleteBlockWithData)(NSData *data);
typedef void (^CompleteBlockWithWord)(Word *word);

#endif
