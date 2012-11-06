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
#import "AdBaseViewController.h"
@interface LearningViewController : AdBaseViewController

@property (nonatomic,strong) Word *word;
@property (nonatomic,strong) IBOutlet UILabel *lblKey;
@property (nonatomic,strong) AVAudioPlayer *player;
@property (nonatomic,strong) IBOutlet UITextView *acceptationTextView;
@property (nonatomic,strong) MKNetworkOperation *downloadOp;
@property (nonatomic,strong) MKNetworkOperation *voiceOp;
@property (nonatomic,unsafe_unretained) BOOL shouldHideInfo;

- (id)initWithWord:(Word *)word;
- (void)refreshView;

- (IBAction)btnReadOnPressed:(id)sender;
- (void)showInfo;
- (void)hideInfo;

@end
