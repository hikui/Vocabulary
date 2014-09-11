//
//  NSDate+VAdditions.h
//  Vocabulary
//
//  Created by 缪和光 on 14-9-11.
//  Copyright (c) 2014年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (VAdditions)

/**
 获取当前日期，忽略具体时间
 
 @return 时间是0：00的日期
 */
- (NSDate *)hkv_dateWithoutTime;

@end
