//
//  PlanningTableViewCell.h
//  Vocabulary
//
//  Created by Heguang Miao on 7/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKVBasicTableViewCell.h"

@interface PlanningTableViewCell : HKVBasicTableViewCell

@property (nonatomic, copy) NSString *wordListName;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) int reviewCount;

@end
