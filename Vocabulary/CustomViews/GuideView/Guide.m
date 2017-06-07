//
//  Guide.m
//  Vocabulary
//
//  Created by 缪 和光 on 13-2-17.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "Guide.h"
#import "common.h"

@interface Guide ()

@end

@implementation Guide

- (UIImage *)guidePictureAtIndex:(NSInteger)index
{
    if (index < 0 || index > self.guidePictureNameArray.count) {
        return nil;
    }
    NSString *pictureName = self.guidePictureNameArray[index];
    if (IS_IPHONE_5) {
        pictureName = [NSString stringWithFormat:@"%@-568h",pictureName];
    }
    return [UIImage imageNamed:pictureName];
}

@end
