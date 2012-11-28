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
