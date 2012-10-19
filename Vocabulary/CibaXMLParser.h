//
//  CibaXMLParser.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-19.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CibaXMLParser : NSObject

+ (NSDictionary *)parseWithXMLString:(NSString *)str;

@end
