//
//  VNavigationManager_Tests.m
//  Vocabulary
//
//  Created by 缪和光 on 12/22/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import "VNavigationManager.h"
#import "DummyViewController1.h"
#import "DummyViewController2.h"
#import "DummyViewController3.h"

@interface VNavigationManager_Tests : XCTestCase

@property (nonatomic, strong) VNavigationManager *navigationManager;

@end

@implementation VNavigationManager_Tests

- (void)setUp {
    [super setUp];
    NSDictionary *route = @{
                            [NSURL URLWithString:@"http://herkuang.info/DummyVC1"]:@{VNavigationConfigClassNameKey:NSStringFromClass([DummyViewController1 class])},
                            [NSURL URLWithString:@"http://herkuang.info/DummyVC2"]:@{VNavigationConfigClassNameKey:NSStringFromClass([DummyViewController2 class])},
                            [NSURL URLWithString:@"http://herkuang.info/DummyVC3"]:@{VNavigationConfigClassNameKey:NSStringFromClass([DummyViewController3 class])},
    };
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navigation = [[UINavigationController alloc]init];
    VNavigationManager *navigationManager = [VNavigationManager sharedInstance];
    [navigationManager configRoute:^NSDictionary *{
        return route;
    }];
    navigationManager.navigationController = navigation;
    self.navigationManager = navigationManager;
    appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    appDelegate.window.rootViewController = navigation;
    [appDelegate.window makeKeyAndVisible];
}

- (void)tearDown {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window = nil;
    [super tearDown];
}

- (void)testBasicPush {
    VNavigationActionCommand *command1 = [VNavigationActionCommand new];
    command1.targetURL = [NSURL URLWithString:@"http://herkuang.info/DummyVC1"];
    command1.animate = YES;
    command1.params = @{@"title":@"level1"};
    VNavigationActionCommand *command2 = [command1 copy];
    command2.params = @{@"title":@"level2"};
    VNavigationActionCommand *command3 = [command1 copy];
    command3.targetURL = [NSURL URLWithString:@"http://herkuang.info/DummyVC3"];
    command3.params = @{@"title":@"level3"};
    [self.navigationManager executeCommand:command1];
    sleep(1);
    [self.navigationManager executeCommand:command2];
    sleep(1);
    [self.navigationManager executeCommand:command3];
    sleep(1);
    XCTAssert(self.navigationManager.navigationController.viewControllers.count == 3);
}

- (void)testBasicPop {
    
}

- (void)testCombinedPushPop {
    
}

@end
