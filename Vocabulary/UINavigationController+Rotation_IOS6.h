//
//  UINavigationController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-30.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UINavigationController (Rotation_IOS6)

-(BOOL)shouldAutorotate;
-(NSUInteger)supportedInterfaceOrientations;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end
