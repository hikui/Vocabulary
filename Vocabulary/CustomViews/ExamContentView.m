
/*
 *  This file is part of 记词助手.
 *
 *	记词助手 is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License Version 2 as 
 *  published by the Free Software Foundation.
 *
 *	记词助手 is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with 记词助手.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  ExamView.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-23.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ExamContentView.h"
#import "NSMutableString+HTMLEscape.h"

@implementation ExamContentView


+ (id)newInstance
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"ExamContentView"
                                                      owner:self
                                                    options:nil];
    ExamContentView *view = nibViews[0];
    return view;
}

- (void)setContent:(ExamContent *)content
{
    _content = content;
    
    if (content.examType == ExamTypeE2C) {
        self.keyLabel.text = content.word.key;
        self.acceptationView.attributedText = content.word.attributedWordDetail;
    }else if(content.examType == ExamTypeS2E){
        self.keyLabel.text = @"听读音";
        self.acceptationView.attributedText = content.word.attributedWordDetail;
    }else if(content.examType == ExamTypeC2E){
        self.keyLabel.text = content.word.acceptation;
        self.acceptationView.text = content.word.key;
    }
    self.acceptationView.hidden = YES;
    self.showAcceptationButton.hidden = NO;
    NSData *pronData = content.word.pronunciation.pronData;

    if (pronData != nil) {
        self.soundPlayer = [[AVAudioPlayer alloc]initWithData:pronData error:nil];
    }else{
        self.soundPlayer = nil;
    }
    
}

- (void)playSound
{
    [self.soundPlayer play];
}

- (void)stopSound
{
    [self.soundPlayer stop];
}

- (IBAction)showAcceptationButtonOnPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.hidden = YES;
    self.acceptationView.hidden = NO;
    if (self.content.examType == ExamTypeS2E) {
        self.keyLabel.text = self.content.word.key;
    }
    [self playSound];
}

@end
