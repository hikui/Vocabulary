//
//  NoteViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 2/11/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "NoteViewController.h"
#import "Note.h"

@interface NoteViewController ()

@property (nonatomic, strong) Note *note;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation NoteViewController

- (instancetype)initWithWord:(Word *)word {
    self = [super init];
    if (self) {
        if (word.note) {
            _note = word.note;
        }else{
            _note = [Note MR_createEntity];
            word.note = _note;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
