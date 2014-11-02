//
//  PureColorImageGenerator.m
//  Vocabulary
//
//  Created by 缪和光 on 13-10-26.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "PureColorImageGenerator.h"

@implementation PureColorImageGenerator

+ (UIImage *)generateOnePixelImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)generateBackButtonImageWithTint:(UIColor *)tintColor
{
    CGRect rect = CGRectMake(0, 0, 24, 24);
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
    CGContextSetLineWidth(context, 4.0f);
    CGContextMoveToPoint(context, 16, 2);
    CGContextAddLineToPoint(context, 6, 12);
    CGContextAddLineToPoint(context, 16, 22);
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

+ (UIImage *)generateRefreshImageWithTint:(UIColor *)tintColor
{
    CGRect rect = CGRectMake(0, 0, 24, 24);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
    CGContextSetLineWidth(context, 4.0f);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextAddArc(context, 12, 12, 8, -M_PI_2, M_PI, 0);
    CGContextMoveToPoint(context, 20, 2);
    CGContextAddLineToPoint(context, 12, 2);
    CGContextAddLineToPoint(context, 12, 8);
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)generateMenuImageWithTint:(UIColor *)tintColor
{
    CGRect rect = CGRectMake(0, 0, 24, 24);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
    CGContextSetLineWidth(context, 3.0f);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextMoveToPoint(context, 3, 6);
    CGContextAddLineToPoint(context, 21, 6);
    CGContextMoveToPoint(context, 3, 12 );
    CGContextAddLineToPoint(context, 21 , 12 );
    CGContextMoveToPoint(context, 3 , 18 );
    CGContextAddLineToPoint(context, 21 , 18 );
    
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
