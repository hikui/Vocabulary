
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
//  LearningViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-10-21.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MKNetworkKit.h"
#import "Word.h"

@class BButton;
@interface WordDetailViewController : VBaseViewController

@property (nonatomic,strong) Word *word;
@property (nonatomic,weak) IBOutlet UILabel *lblKey;
@property (nonatomic,strong) AVAudioPlayer *player;
@property (nonatomic,weak) IBOutlet UITextView *acceptationTextView;
@property (nonatomic,weak) IBOutlet BButton *detailButton;
@property (nonatomic,strong) MKNetworkOperation *downloadOp;
@property (nonatomic,strong) MKNetworkOperation *voiceOp;
@property (nonatomic,unsafe_unretained) BOOL shouldHideInfo;

- (instancetype)initWithWord:(Word *)word;
- (void)refreshView;

- (void)playSound;
- (void)refreshWordData;

- (IBAction)btnReadOnPressed:(id)sender;
// use iciba web page
- (IBAction)fullInfomation:(id)sender;
- (void)showInfo;
- (void)hideInfo;

@end
