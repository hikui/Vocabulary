//
//  NSMutableString+HTMLEscape.h
//  Vocabulary
//
//  Created by Hikui on 13-1-1.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (HTMLEscape)

- (NSMutableString *)htmlUnescape;

- (NSMutableString *)htmlEscape;

@end
