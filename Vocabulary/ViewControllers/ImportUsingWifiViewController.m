//
//  ImportUsingWifiViewController.m
//  Vocabulary
//
//  Created by Heguang Miao on 18/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import "ImportUsingWifiViewController.h"
#import "ImportingWebServer.h"

@interface ImportUsingWifiViewController () <ImportingWebServerDelegate>

@property (nonatomic, strong) ImportingWebServer *server;
@property (nonatomic, weak) IBOutlet UILabel *labelURL;

@end

@implementation ImportUsingWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonOnTouch:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    self.server = [[ImportingWebServer alloc]init];
    self.server.importingDelegate = self;
    [self.server start];
    self.labelURL.text = self.server.serverURL.absoluteString;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.server stop];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonOnTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webServerBeginsImportingWords:(ImportingWebServer *)webSrver {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在导入";
}
- (void)webServer:(ImportingWebServer *)webServer finishedImportingWithError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

@end
