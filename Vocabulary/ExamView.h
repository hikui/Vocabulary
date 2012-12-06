
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
//  ExamView.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-23.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExamContent.h"
#import <AVFoundation/AVFoundation.h>

@interface ExamView : UIView

@property (nonatomic, weak) IBOutlet UILabel *keyLabel;
@property (nonatomic, weak) IBOutlet UITextView *acceptationView;
@property (nonatomic, weak) IBOutlet UIButton *showAcceptationButton;
@property (nonatomic, weak) ExamContent *content;
@property (nonatomic, strong) AVAudioPlayer *soundPlayer;

+ (id)newInstance;
- (IBAction)showAcceptationButtonOnPressed:(id)sender;
- (void)playSound;
- (void)stopSound;


@end
