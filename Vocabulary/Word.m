//
//  Word.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-19.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "Word.h"
#import "WordList.h"


@implementation Word

@dynamic key;
@dynamic acceptation;
@dynamic psEN;
@dynamic psUS;
@dynamic pronounceEN;
@dynamic pronounceUS;
@dynamic sentences;
@dynamic familiarity;
@dynamic lastVIewDate;
@dynamic hasGotDataFromAPI;
@dynamic wordList;

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@",self.key];
}

@end
