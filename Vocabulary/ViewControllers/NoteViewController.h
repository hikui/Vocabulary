//
//  NoteViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 2/11/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "VKeyboardAwarenessViewController.h"

@class Word;

@interface NoteViewController : VKeyboardAwarenessViewController

@property (nonatomic, strong) Word *word;

//- (instancetype)initWithWord:(Word *)word;

@end
