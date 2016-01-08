//
//  HKVBasicTableViewCell.h
//  Vocabulary
//
//  Created by 缪和光 on 3/01/2015.
//  Copyright (c) 2015 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKVDefaultTableViewModel.h"

@interface HKVBasicTableViewCell : UITableViewCell<HKVDefaultTableViewModelCellProtocol>

@property (nonatomic, strong) id data;
@property (nonatomic, weak) HKVDefaultTableViewModel *model;

+ (CGFloat)heightForData:(id)data;

@end
