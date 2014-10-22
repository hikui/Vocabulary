//
//  SimpleProgressBar.m
//  Vocabulary
//
//  Created by 缪和光 on 13-10-27.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "SimpleProgressBar.h"

@implementation SimpleProgressBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame barColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        _barColor = color;
        _progress = 0.0f;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat width = rect.size.width;
    float progress = _progress;
    if (progress > 1.0f) {
        progress = 1.0f;
    }
    
    width = width * progress;
    rect.size.width = width;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.barColor.CGColor);
    CGContextFillRect(ctx, rect);
    
}

@end
