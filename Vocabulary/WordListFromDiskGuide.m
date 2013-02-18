//
//  WordListFromDiskGuide.m
//  Vocabulary
//
//  Created by 缪 和光 on 13-2-17.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "WordListFromDiskGuide.h"

@implementation WordListFromDiskGuide

- (id)init
{
    self = [super init];
    if (self) {
        _guidePictureNameArray = [[NSMutableArray alloc]initWithObjects:
                                  @"import_wordlist_itunes1",@"import_wordlist_itunes2",
                                  @"import_wordlist_itunes3",@"import_wordlist_itunes4"
                                  , nil];
        _guideName = @"WordListFromDiskGuide";
        _guideVersion = 2;
    }
    return self;
}

@end
