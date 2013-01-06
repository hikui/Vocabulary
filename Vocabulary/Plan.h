//
//  Plan.h
//  Vocabulary
//
//  Created by 缪 和光 on 13-1-6.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WordList.h"

// This class is not a subclass of NSManagedObject.
// It's not for persistent storage. Everytime the app restarts, the AppDelegate will refresh it's plan object.
@interface Plan : NSObject

@property (nonatomic, copy) NSArray *reviewPlan;
@property (nonatomic, strong) WordList *learningPlan;
@property (nonatomic, assign) BOOL reviewPlanFinished;
@property (nonatomic, assign) BOOL learningPlanFinished;

@end
