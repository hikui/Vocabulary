//
//  InsertWordView.h
//  Vocabulary
//
//  Created by 缪和光 on 12/29/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InsertWordView : UIView

@property (nonatomic, strong) WordList *targetWordList;
@property (nonatomic, copy) void (^resultBlock)();

+ (instancetype)newInstance;
- (void)showWithResultBlock:(void (^)())resultBlock;;
- (void)hide;

@end
