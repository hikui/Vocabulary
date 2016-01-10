//
//  UINavigationItem+Copying.m
//  Vocabulary
//
//  Created by Heguang Miao on 2/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import "UINavigationItem+Copying.h"

@implementation UINavigationItem (Copying)

- (void)copyFrom:(UINavigationItem *)origin {
    self.title = origin.title;
    self.titleView = origin.titleView;
    self.leftBarButtonItems = origin.leftBarButtonItems;
    self.rightBarButtonItems = origin.rightBarButtonItems;
}

@end
