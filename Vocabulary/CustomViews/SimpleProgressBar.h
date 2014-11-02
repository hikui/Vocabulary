//
//  SimpleProgressBar.h
//  Vocabulary
//
//  Created by 缪和光 on 13-10-27.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleProgressBar : UIView

@property (nonatomic, assign) float progress;
@property (nonatomic, strong) UIColor *barColor;

- (instancetype)initWithFrame:(CGRect)frame barColor:(UIColor *)color;

@end
