//
//  PureColorImageGenerator.m
//  Vocabulary
//
//  Created by 缪和光 on 13-10-26.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "PureColorImageGenerator.h"

@implementation PureColorImageGenerator

static int factor = 2;

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
    CGRect rect = CGRectMake(0, 0, 24*factor, 24*factor);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
    CGContextSetLineWidth(context, 4.0f*factor);
    CGContextMoveToPoint(context, 16*factor, 2*factor);
    CGContextAddLineToPoint(context, 6*factor, 12*factor);
    CGContextAddLineToPoint(context, 16*factor, 22*factor);
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

+ (UIImage *)generateRefreshImageWithTint:(UIColor *)tintColor
{
    CGRect rect = CGRectMake(0, 0, 24*factor, 24*factor);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
    CGContextSetLineWidth(context, 4.0f*factor);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextAddArc(context, 12*factor, 12*factor, 8*factor, -M_PI_2, M_PI, 0);
    CGContextMoveToPoint(context, 20*factor, 2*factor);
    CGContextAddLineToPoint(context, 12*factor, 2*factor);
    CGContextAddLineToPoint(context, 12*factor, 8*factor);
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)generateMenuImageWithTint:(UIColor *)tintColor
{
    CGRect rect = CGRectMake(0, 0, 24*factor, 24*factor);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
    CGContextSetLineWidth(context, 3.0f*factor);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextMoveToPoint(context, 3*factor, 6*factor);
    CGContextAddLineToPoint(context, 21*factor, 6*factor);
    CGContextMoveToPoint(context, 3*factor, 12*factor);
    CGContextAddLineToPoint(context, 21*factor, 12*factor);
    CGContextMoveToPoint(context, 3*factor, 18*factor);
    CGContextAddLineToPoint(context, 21*factor, 18*factor);
    
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
