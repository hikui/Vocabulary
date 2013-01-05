//
//  UIToolbar+VToolBar.m
//  Vocabulary
//
//  Created by 缪 和光 on 13-1-5.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "UIToolbar+VToolBar.h"

@implementation UIToolbar (VToolBar)
- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed: @"nav.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, 43)];
}
@end
