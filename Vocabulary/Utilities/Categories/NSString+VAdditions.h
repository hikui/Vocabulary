//
//  NSString+VAdditions.h
//  Vocabulary
//
//  Created by 缪和光 on 14/10/24.
//  Copyright (c) 2014年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (VAdditions)

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hkv_isPureInt;

- (NSString *)hkv_stringByURLEncoding;
- (NSString *)hkv_stringByURLDecoding;
- (NSString *)hkv_trim;

@end
