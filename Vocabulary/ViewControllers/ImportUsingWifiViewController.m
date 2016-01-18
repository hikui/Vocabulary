//
//  ImportUsingWifiViewController.m
//  Vocabulary
//
//  Created by Heguang Miao on 18/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import "ImportUsingWifiViewController.h"
#import "ImportingWebServer.h"

@interface ImportUsingWifiViewController ()

@property (nonatomic, strong) ImportingWebServer *server;
@property (nonatomic, weak) IBOutlet UILabel *labelURL;

@end

@implementation ImportUsingWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.server = [[ImportingWebServer alloc]init];
    [self.server start];
    self.labelURL.text = self.server.serverURL.absoluteString;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.server stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonOnTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
