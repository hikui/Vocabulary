//
//  HKVBasicTableViewCell.m
//  Vocabulary
//
//  Created by 缪和光 on 3/01/2015.
//  Copyright (c) 2015 缪和光. All rights reserved.
//

#import "HKVBasicTableViewCell.h"

@implementation HKVBasicTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bindData:(id)data {
    self.data = data;
}

+ (CGFloat)heightForData:(id)data {
    return 44;
}

@end
