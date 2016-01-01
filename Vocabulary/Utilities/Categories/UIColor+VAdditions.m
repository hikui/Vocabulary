//
//  UIColor+VAdditions.m
//  Vocabulary
//
//  Created by 缪和光 on 2/11/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "UIColor+VAdditions.h"

@implementation UIColor (VAdditions)

+ (UIColor *)hkv_colorFromHex:(NSString *)hex{
    NSString *stringColor = hex;
    NSUInteger red, green, blue;
    sscanf([stringColor UTF8String], "#%2lX%2lX%2lX", &red, &green, &blue);
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    return color;
}

@end
