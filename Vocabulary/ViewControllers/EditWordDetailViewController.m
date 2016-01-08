//
//  EditWordDetailViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12/17/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "EditWordDetailViewController.h"

@interface EditWordDetailViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;

@end

@implementation EditWordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(self.word != nil, @"Should contain a word");
    self.navigationItem.title = @"自定义解释";
    self.textView.text = self.word.acceptation;
    self.textView.backgroundColor = GlobalBackgroundColor;
    self.respondScrollView = self.textView;
//    [self showCustomBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        Word *localWord = [self.word MR_inContext:localContext];
        localWord.acceptation = self.textView.text;
        localWord.manuallyInput = @(self.textView.text.length != 0);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
