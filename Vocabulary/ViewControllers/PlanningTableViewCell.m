//
//  PlanningTableViewCell.m
//  Vocabulary
//
//  Created by Heguang Miao on 7/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import "PlanningTableViewCell.h"
#import "NSDate+VAdditions.h"
#import "WordList.h"

@interface PlanningTableViewCell()

@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;
@property (nonatomic, weak) IBOutlet UILabel *wordListNameLabel;

@end

@implementation PlanningTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.backgroundView.backgroundColor = [UIColor greenColor];
    
}

- (void)bindData:(id)data {
    [super bindData:data];
    WordList *wordList = (WordList *)data;
    self.wordListNameLabel.text = wordList.title;
    NSDate *todaysDateWithoutTime = [[NSDate date]hkv_dateWithoutTime];
    if ([wordList.lastReviewTime compare:todaysDateWithoutTime] == NSOrderedDescending) {
        self.statusImageView.image = [UIImage imageNamed:@"plan-done-icon"];
    }else{
        self.statusImageView.image = [UIImage imageNamed:@"plan-not-done-icon"];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
