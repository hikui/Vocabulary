//
//  VKeyboardAwarenessViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12/17/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "VBaseViewController.h"

@interface VKeyboardAwarenessViewController : VBaseViewController

/**
 响应键盘弹出事件的scrollview
 */
@property (nonatomic, weak) UIScrollView *respondScrollView;
@property (nonatomic, assign) UIEdgeInsets defaultTextViewInset;

@end
