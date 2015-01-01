//
//  VBaseModel.h
//  Vocabulary
//
//  Created by 缪和光 on 21/12/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface VBaseModel : NSManagedObject

- (NSDictionary *)toDict;

- (NSString *)toJSON;

@end
