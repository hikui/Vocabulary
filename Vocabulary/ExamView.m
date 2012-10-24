//
//  ExamView.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-23.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ExamView.h"

@implementation ExamView


+ (id)newInstance
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"ExamView"
                                                      owner:self
                                                    options:nil];
    ExamView *view = [nibViews objectAtIndex:0];
    return view;
}

- (void)setContent:(ExamContent *)content
{
    _content = content;
    if (content.examType == ExamTypeE2C) {
        self.keyLabel.text = content.word.key;
    }else{
        self.keyLabel.text = @"听读音";
    }
    [self.keyLabel sizeToFit];
    self.acceptationView.hidden = YES;
    self.acceptationView.text = content.word.acceptation;
    self.showAcceptationButton.hidden = NO;
}

- (IBAction)showAcceptationButtonOnPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.hidden = YES;
    self.acceptationView.hidden = NO;
    self.keyLabel.text = self.content.word.key;
    [self.keyLabel sizeToFit];
}

@end
