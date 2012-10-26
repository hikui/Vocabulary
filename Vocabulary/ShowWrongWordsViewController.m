//
//  ShowWrongWordsViewController.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-26.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ShowWrongWordsViewController.h"

@interface ShowWrongWordsViewController ()

- (void)backToWordList;

@end

@implementation ShowWrongWordsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backToWordListButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(backToWordList)];
    self.navigationItem.leftBarButtonItem = backToWordListButton;
    self.title = @"错误单词";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)backToWordList
{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if (vc != self && [vc isKindOfClass:[ShowWordsViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

@end
