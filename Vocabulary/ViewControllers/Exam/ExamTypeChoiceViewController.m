//
//  ExamTypeChoiceViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12/19/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "ExamTypeChoiceViewController.h"
#import "ExamViewController.h"

@interface ExamTypeChoiceViewController ()

@property (nonatomic, weak) IBOutlet UIButton *btnCheckC2E;
@property (nonatomic, weak) IBOutlet UIButton *btnCheckE2C;
@property (nonatomic, weak) IBOutlet UIButton *btnCheckListening;

@end

@implementation ExamTypeChoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showCustomBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)checkBoxOnTouch:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)btnNextStepOnTouch:(id)sender {
    ExamOption option = ExamOptionNone;
    if (self.btnCheckC2E.selected) {
        option |= ExamOptionC2E;
    }
    if (self.btnCheckE2C.selected) {
        option |= ExamOptionE2C;
    }
    if (self.btnCheckListening.selected) {
        option |= ExamOptionListening;
    }
    
    if (option == ExamOptionNone) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请至少选择一项" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    ExamViewController *examVC = nil;
    if (self.wordList) {
        examVC = [[ExamViewController alloc]initWithWordList:self.wordList];
    }else if (self.wordArray) {
        examVC = [[ExamViewController alloc]initWithWordArray:self.wordArray];
    }
    examVC.examOption = option;
    if (examVC) {
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
        [viewControllers removeLastObject];
        [viewControllers addObject:examVC];
        [[self navigationController] setViewControllers:viewControllers animated:YES];
    }
}

@end
