//
//  ImportSelectionView.h
//  Vocabulary
//
//  Created by Heguang Miao on 1/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImportSelectionView : UIView

+ (instancetype)importSelectionView;

@property (weak, readonly) UIButton *importUsingWifi;
@property (weak, readonly) UIButton *importManuallyButton;
@property (nonatomic, copy) void (^menuDidHideBlock)();

- (void)showMenu;
- (void)hideMenu;

@end
