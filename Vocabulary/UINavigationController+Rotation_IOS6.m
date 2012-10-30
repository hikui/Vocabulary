//
//  UINavigationController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-30.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "UINavigationController+Rotation_IOS6.h"


@implementation UINavigationController (Rotation_IOS6)

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
