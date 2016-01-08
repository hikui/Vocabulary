//
//  VNavigationCommonURL.h
//  Vocabulary
//
//  Created by 缪和光 on 12/22/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKVNavigationRouteConfig : NSObject

@property (nonatomic, readonly) NSURL *examVC;
@property (nonatomic, readonly) NSURL *showWrongWordsVC;
@property (nonatomic, readonly) NSURL *examTypeChoiceVC;
@property (nonatomic, readonly) NSURL *learningBackboneVC;
@property (nonatomic, readonly) NSURL *planningVC;
@property (nonatomic, readonly) NSURL *createWordListVC;
@property (nonatomic, readonly) NSURL *existingWordsListsVC;
@property (nonatomic, readonly) NSURL *PreferenceVC;
@property (nonatomic, readonly) NSURL *wordDetailVC;
@property (nonatomic, readonly) NSURL *wordListFromDiskVC;
@property (nonatomic, readonly) NSURL *wordListVC;
@property (nonatomic, readonly) NSURL *noteVC;
@property (nonatomic, readonly) NSURL *editWordDetailVC;
@property (nonatomic, readonly) NSURL *unfamiliarWordListVC;

@property (nonatomic, readonly) NSDictionary *route;

+ (HKVNavigationRouteConfig *)sharedInstance;

@end
