//
//  VBaseModel.m
//  Vocabulary
//
//  Created by 缪和光 on 21/12/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "VBaseModel.h"

@implementation VBaseModel

- (NSDictionary *)toDict {
    NSArray *allAttributesKeys = [self.entity.attributesByName allKeys];
    NSDictionary *relationships = self.entity.relationshipsByName;
    NSMutableDictionary *dictRepresentation = [[NSMutableDictionary alloc]initWithCapacity:allAttributesKeys.count];
    for (NSString *aKey in allAttributesKeys) {
        id value = [self valueForKey:aKey];
        if ([value isKindOfClass: [NSString class]] || [value isKindOfClass: [NSNumber class]]) {
            [dictRepresentation setObject:value forKey:aKey];
        }else if([value isKindOfClass:[NSDate class]]){
            NSTimeInterval timePassed = [((NSDate *)value) timeIntervalSince1970];
            [dictRepresentation setObject:@(timePassed) forKey:aKey];
        }else if ([value isKindOfClass: [VBaseModel class]]) {
            [dictRepresentation setObject:[((VBaseModel *)value) toDict]forKey:aKey];
        }
    }
    NSManagedObjectID *objId = self.objectID;
    [dictRepresentation setObject:[[objId URIRepresentation]absoluteString] forKey:@"ObjectID"];
    return dictRepresentation;
}

- (NSString *)toJSON {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self toDict] options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
