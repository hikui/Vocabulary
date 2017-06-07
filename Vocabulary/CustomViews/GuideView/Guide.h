//
//  Guide.h
//  Vocabulary
//
//  Created by 缪 和光 on 13-2-17.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

@import UIKit;

@interface Guide : NSObject
{
    NSMutableArray *_guidePictureNameArray;
    NSString *_guideName;
    int _guideVersion;
}

@property(nonatomic,copy) NSMutableArray *guidePictureNameArray;
@property(nonatomic,copy) NSString *guideName;
@property(nonatomic,assign) int guideVersion;

- (UIImage *)guidePictureAtIndex:(NSInteger)index;

@end
