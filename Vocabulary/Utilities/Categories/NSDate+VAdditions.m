//
//  NSDate+VAdditions.m
//  Vocabulary
//
//  Created by 缪和光 on 14-9-11.
//  Copyright (c) 2014年 缪和光. All rights reserved.
//

#import "NSDate+VAdditions.h"

@implementation NSDate (VAdditions)

- (NSDate *)hkv_dateWithoutTime {
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:self];
    return [calendar dateFromComponents:components];
}

@end
