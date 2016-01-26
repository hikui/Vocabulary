//
//  ImportSelectionView.m
//  Vocabulary
//
//  Created by Heguang Miao on 1/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import "ImportSelectionView.h"

@interface ImportSelectionView()

@property (weak) IBOutlet UIView *wrapperView;
@property (weak, readwrite) IBOutlet UIButton *importUsingWifi;
@property (weak, readwrite) IBOutlet UIButton *importManuallyButton;

@property (weak) IBOutlet NSLayoutConstraint *bottomMarginConstraint;

@end

@implementation ImportSelectionView



+ (instancetype)importSelectionView {
    ImportSelectionView *view = [[NSBundle mainBundle]loadNibNamed:@"ImportSelectionView" owner:nil options:nil][0];
    return view;
}

- (void)awakeFromNib {
    self.wrapperView.layer.cornerRadius = 4;
}

- (IBAction)bgViewOnTap:(UIGestureRecognizer *)gestureRecognizer {
    DDLogDebug(@"bgViewOnTap");
    [self hideMenu];
}

- (void)showMenu {
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomMarginConstraint.constant = 55;
        [self.wrapperView layoutIfNeeded];
    }];
}
- (void)hideMenu {
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomMarginConstraint.constant = -94;
        [self.wrapperView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.menuDidHideBlock) {
            self.menuDidHideBlock();
        }
    }];
}

@end
