//
//  PureColorImageGenerator.h
//  Vocabulary
//
//  Created by 缪和光 on 13-10-26.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PureColorImageGenerator : NSObject

+ (UIImage *)generateOnePixelImageWithColor:(UIColor *)color;
+ (UIImage *)generateBackButtonImageWithTint:(UIColor *)tintColor;
+ (UIImage *)generateRefreshImageWithTint:(UIColor *)tintColor;
+ (UIImage *)generateMenuImageWithTint:(UIColor *)tintColor;
@end
