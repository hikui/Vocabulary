//
//  InsertWordView.m
//  Vocabulary
//
//  Created by 缪和光 on 12/29/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "InsertWordView.h"
#import "SZTextView.h"
#import "WordManager.h"

@interface InsertWordView()

@property (nonatomic, weak) IBOutlet UITextField *wordField;
@property (nonatomic, weak) IBOutlet SZTextView *definitionTextView;
@property (nonatomic, weak) IBOutlet UIView *wrapperView;
@property (nonatomic, weak) IBOutlet UIButton *confirmButton;

@end

NS_INLINE UIWindow * getMainWindow(){
    id appDelegate = [[UIApplication sharedApplication]delegate];
    UIWindow *mainWindow = [appDelegate performSelector:@selector(window) withObject:nil];
    return mainWindow;
}

@implementation InsertWordView

+ (instancetype)newInstance {
   InsertWordView *instance = [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
    NSAssert([instance isKindOfClass:[InsertWordView class]], @"Should be an InsertWordView");
    [[NSNotificationCenter defaultCenter]addObserver:instance selector:@selector(keyboardIsShown:) name:UIKeyboardWillShowNotification object:nil];
    return instance;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *wordFieldLeftPadding = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, CGRectGetHeight(self.wordField.frame))];
    wordFieldLeftPadding.backgroundColor = [UIColor clearColor];
    UIView *wordFieldRightPadding = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, CGRectGetHeight(self.wordField.frame))];
    wordFieldRightPadding.backgroundColor = [UIColor redColor];
    self.wordField.leftView = wordFieldLeftPadding;
    self.wordField.rightView = wordFieldRightPadding;
    self.wordField.leftViewMode = UITextFieldViewModeAlways;
    
    self.definitionTextView.placeholder = @"(可选)输入解释";
}

- (void)showWithResultBlock:(void (^)())resultBlock {
    self.resultBlock = resultBlock;
    UIWindow *mainWindow = getMainWindow();
    [mainWindow addSubview:self];
    [self.wordField becomeFirstResponder];
    [self.wrapperView setY:CGRectGetHeight(mainWindow.bounds)];
    [UIView animateWithDuration:.4 animations:^{
        self.backgroundColor = RGBA(0, 0, 0, .6);
    }];
    
}

- (void)hide {
    UIWindow *mainWindow = getMainWindow();
    [self.wrapperView resignFirstResponder];
    [self.definitionTextView resignFirstResponder];
    [UIView animateWithDuration:.4 animations:^{
        [self.wrapperView setY:CGRectGetHeight(mainWindow.bounds)];
        self.backgroundColor = RGBA(0, 0, 0, 0);
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        [self removeFromSuperview];
    }];
}

- (void)keyboardIsShown:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect targetKeyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    targetKeyboardFrame = [self convertRect:targetKeyboardFrame fromView:nil];
    CGFloat contentMaxY = CGRectGetMaxY(self.confirmButton.frame) + 5; // relative y to wrapper view
    CGFloat wrapperOriginY = CGRectGetMinY(targetKeyboardFrame) - contentMaxY;
    CGRect wrapperFrame = self.wrapperView.frame;
    wrapperFrame.origin.y = wrapperOriginY;
    //不dispatch_after的话会出现动画冲突现象（暂时不明原因）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.wrapperView.frame = wrapperFrame;
        } completion:nil];
    });
}

- (IBAction)buttonAddOnTouch:(UIButton *)sender {
    NSString *key = [self.wordField.text hkv_trim];
    if (key.length > 0 && self.targetWordList != nil) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Word *word = [Word MR_createEntityInContext:localContext];
            word.key = key;
            if (self.definitionTextView.text.length > 0) {
                word.acceptation = self.definitionTextView.text;
                word.manuallyInput = @(YES);
            }
            WordList *localWordList = [self.targetWordList MR_inContext:localContext];
            [word addWordListsObject:localWordList];
            [WordManager indexNewWordsWithoutSaving:@[word] inContext:localContext progressBlock:nil completion:nil];
            
        }];
        if (self.resultBlock) {
            self.resultBlock();
        }
    }
    [self hide];
    
}

- (IBAction)buttonCancelOnTouch:(UIButton *)sender {
    [self hide];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    if (!CGRectContainsPoint(self.wrapperView.frame, location)) {
        [self hide];
    }
}

@end
