//
//  NoteViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 2/11/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "NoteViewController.h"
#import "Note.h"
#import "VNavigationController.h"
#import "AppDelegate.h"

@interface NoteViewController ()<UITextViewDelegate>

@property (nonatomic, strong) Note *note;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *wordLabel;

@property (nonatomic) UIEdgeInsets defaultInsets;

@end

@implementation NoteViewController

- (instancetype)initWithWord:(Word *)word {
    self = [super init];
    if (self) {
        if (word.note) {
            _note = word.note;
        }else{
            _note = [Note MR_createEntity];
            word.note = _note;
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GlobalBackgroundColor;
    UIBarButtonItem *attatchButton = [[UIBarButtonItem alloc]initVNavBarButtonItemWithTitle:@"附件" target:self action:@selector(attatchButtonOnClick)];
    UIBarButtonItem *backButton = [VNavigationController generateBackItemWithTarget:self action:@selector(backButtonOnClick)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.rightBarButtonItem = attatchButton;
    
    UILabel *wordLabel = [[UILabel alloc]init];
    wordLabel.font = [UIFont boldSystemFontOfSize:26];
    wordLabel.text = self.note.word.key;
    self.wordLabel = wordLabel;
    
    self.textView = [[UITextView alloc]initWithFrame:self.view.bounds];
    self.textView.backgroundColor = GlobalBackgroundColor;
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    if (self.note.textNote.length > 0) {
        self.textView.text = self.note.textNote;
    }
    if (GRATER_THAN_IOS_7) {
        self.textView.textContainerInset = UIEdgeInsetsMake(0, 8, 0, 8);
    }
    [self.textView addSubview:wordLabel];
    self.textView.delegate = self;
    [self.view addSubview:self.textView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardIsShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardIsHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    static CGFloat labelMargin = 10;
    [self.wordLabel sizeToFit];
    CGRect labelFrame = self.wordLabel.frame;
    CGFloat wordLabelHeight = CGRectGetHeight(self.wordLabel.frame);
    labelFrame.origin.x = labelMargin;
    labelFrame.origin.y = -wordLabelHeight - labelMargin;
    self.wordLabel.frame = labelFrame;
    self.textView.contentInset = UIEdgeInsetsMake(-labelFrame.origin.y + labelMargin, 0, 0, 0);
    self.defaultInsets = self.textView.contentInset;
    self.textView.contentOffset = CGPointMake(0, labelFrame.origin.y - labelMargin);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
- (void)backButtonOnClick {
    [self saveNote];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)attatchButtonOnClick {
    
}

- (void)saveNote {
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        self.note.textNote = self.textView.text;
    }];
}

#pragma mark - scroll delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView resignFirstResponder];
}

#pragma mark - keyboard
- (void)keyboardIsShown:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect targetKeyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    targetKeyboardFrame = [self.view convertRect:targetKeyboardFrame fromView:window];
    CGFloat offsetY = targetKeyboardFrame.size.height;
    UIEdgeInsets contentInsets = self.defaultInsets;
    contentInsets.bottom = offsetY;
    self.textView.contentInset = contentInsets;
    self.textView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardIsHidden:(NSNotification *)notification {
    UIEdgeInsets contentInsets = self.defaultInsets;
    self.textView.contentInset = contentInsets;
    self.textView.scrollIndicatorInsets = contentInsets;
}

@end
