//
//  TestBaseViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12/22/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "TestBaseViewController.h"

@interface TestBaseViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation TestBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *label = [[UILabel alloc]initWithFrame:self.view.bounds];
    label.numberOfLines = 0;
    label.text = self.title;
    self.label = label;
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
