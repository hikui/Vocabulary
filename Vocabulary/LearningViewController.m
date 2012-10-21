//
//  LearningViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-21.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "LearningViewController.h"
#import "CibaEngine.h"

@interface LearningViewController ()

@end

@implementation LearningViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblKey.text = self.word.key;
    
    if (!self.word.hasGotDataFromAPI) {
        CibaEngine *engine = [CibaEngine sharedInstance];
        [engine infomationForWord:self.word.key onCompletion:^(NSDictionary *parsedDict) {
            self.acceptationTextView.text = [parsedDict objectForKey:@"acceptation"];
            //load voice
            NSString *pronURL = [parsedDict objectForKey:@"pronounceUS"];
            if (pronURL) {
                [engine getPronWithURL:pronURL onCompletion:^(NSData *data) {
                    NSLog(@"voice succeed");
                } onError:^(NSError *error) {
                    NSLog(@"VOICE ERROR");
                }];
            }
            
        } onError:^(NSError *error) {
            NSLog(@"ERROR");
        }];
    }else{
        self.acceptationTextView.text = self.word.acceptation;
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setWord:(Word *)word
{
    _word = word;
    [self refreshView];
}

- (id)initWithWord:(Word *)word
{
    self = [super initWithNibName:@"LearningViewController" bundle:nil];
    if (self) {
        _word = word;
    }
    return self;
}

- (void)refreshView
{
    self.lblKey.text = self.word.key;
}
@end
