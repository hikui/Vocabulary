//
//  WordListCell.m
//  Vocabulary
//
//  Created by Heguang Miao on 7/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import "WordListCell.h"
#import "ReactiveCocoa.h"

@interface WordListCell()

@property (nonatomic, strong) IBOutlet UILabel *wordLabel;
@property (nonatomic, strong) IBOutlet UIImageView *starsImageView;

@end

@implementation WordListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    RAC(self.wordLabel, text) = RACObserve(self, word);
    [[RACObserve(self, familiarity) map:^id(NSNumber *familarity) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"stars-%@",familarity]];
    }] subscribeNext:^(UIImage *image) {
        self.starsImageView.image = image;
    }];
}

@end
