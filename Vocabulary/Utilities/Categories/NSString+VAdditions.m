//
//  NSString+VAdditions.m
//  Vocabulary
//
//  Created by 缪和光 on 14/10/24.
//  Copyright (c) 2014年 缪和光. All rights reserved.
//

#import "NSString+VAdditions.h"

@implementation NSString (VAdditions)

- (BOOL)hkv_isPureInt {
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

@end
