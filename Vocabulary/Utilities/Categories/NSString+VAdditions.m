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

- (NSString *)hkv_stringByURLEncoding {
    NSMutableString * encoded = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [encoded appendString:@"%20"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [encoded appendFormat:@"%c", thisChar];
        } else {
            [encoded appendFormat:@"%%%02X", thisChar];
        }
    }
    return encoded;
}

- (NSString *)hkv_stringByURLDecoding {
    NSString *decoded = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return decoded;
}

- (NSString *)hkv_trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
