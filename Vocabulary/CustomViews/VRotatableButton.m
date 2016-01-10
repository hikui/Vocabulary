//
//  VRotatableButton.m
//  Vocabulary
//
//  Created by Heguang Miao on 1/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import "VRotatableButton.h"

@interface VRotatableButton()

@end

@implementation VRotatableButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _rotatableImageView = [[UIImageView alloc]initWithFrame:frame];
        _rotatableImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _rotatableImageView.userInteractionEnabled = NO;
        _rotatableImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_rotatableImageView];
        [self addTarget:self action:@selector(selfOnTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)selfOnTouch:(id)sender {
    self.active = !self.active;
}

- (void)setActive:(BOOL)active {
    _active = active;
    [UIView animateWithDuration:0.2 animations:^{
        if (active) {
            self.rotatableImageView.transform = CGAffineTransformMakeRotation(M_PI/4);
        } else {
            self.rotatableImageView.transform = CGAffineTransformMakeRotation(0);
        }
    }];
}

@end
