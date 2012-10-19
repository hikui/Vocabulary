//
//  CreateWordListViewController.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-19.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateWordListViewController : UIViewController<UITextViewDelegate,UIScrollViewDelegate>

@property (nonatomic,weak) IBOutlet UITextView *textView;

- (void)keyboardWillAppear:(NSNotification *)notification;
- (void)keyboardwillChangeFrame:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

- (IBAction)btnOkPressed:(id)sender;
- (IBAction)btnCancelPressed:(id)sender;

@end
