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
    [[NSNotificationCenter defaultCenter]addObserver:instance selector:@selector(keyboardIsShown:) name:UIKeyboardDidShowNotification object:nil];
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
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue] animations:^{
        [self.wrapperView setY:wrapperOriginY];
    }];
}

- (IBAction)buttonAddOnTouch:(UIButton *)sender {
    NSString *key = [self.wordField.text hkv_trim];
    if (key.length > 0 && self.targetWordList != nil) {
        /*
         `asyncIndexNewWords` runs in a new thread along with a new NSManagedObjectContext, which is a child of MR_defaultContext and has nothing to do with the context of `saveWithBlockAndWait` below. Thus the word created in the block cannot be detected in the default context and its other children before `save` is called.
         So we need to record the object id of the new word, then look for the entity in the default context by this id. Then we can run asyncIndexNewWords safely.
         Remember, when a new NSManagedObject is created, its objectID property is a temporary id, which is useless in the outside world. We should call `obtainPermanentIDsForObjects` first to turn it to a permanent id.
         */
        __block NSError *e = nil;
        __block NSManagedObjectID *objId = nil;
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Word *word = [Word MR_createEntityInContext:localContext];
            word.key = key;
            if (self.definitionTextView.text.length > 0) {
                word.acceptation = self.definitionTextView.text;
                word.manuallyInput = @(YES);
            }
            WordList *localWordList = [self.targetWordList MR_inContext:localContext];
            [word addWordListsObject:localWordList];
            if ([word.objectID isTemporaryID]) {
                
                [localContext obtainPermanentIDsForObjects:@[word] error:&e];
                if (e) {
                    [MagicalRecord handleErrors:e];
                    return;
                }
                objId = word.objectID;
            }
        }];
        Word *wordInMainThread = (Word *)[[NSManagedObjectContext MR_defaultContext] existingObjectWithID:objId error:&e];
        if (e) {
            [MagicalRecord handleErrors:e];
            return;
        }
        
        [WordManager asyncIndexNewWords:@[wordInMainThread] progressBlock:nil completion:nil];
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
