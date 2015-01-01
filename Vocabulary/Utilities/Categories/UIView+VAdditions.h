//
//  UIView+VAdditions.h
//  Vocabulary
//
//  Created by 缪和光 on 1/01/2015.
//  Copyright (c) 2015 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (VAdditions)

#pragma mark Without auto layout
- (void)setHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;
- (void)setOrigin:(CGPoint)origin;
- (void)setSize:(CGSize)size;

@end
