//
//  WordListCell.h
//  Vocabulary
//
//  Created by Heguang Miao on 7/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordListCell : UITableViewCell

@property (nonatomic, copy) NSString *word;
@property (nonatomic, assign) int familiarity;

@end
