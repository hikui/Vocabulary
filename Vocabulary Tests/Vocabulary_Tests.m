//
//  Vocabulary_Tests.m
//  Vocabulary Tests
//
//  Created by 缪和光 on 20/12/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HKVNavigationRouteConfig.h"

@interface Vocabulary_Tests : XCTestCase

@end

@implementation Vocabulary_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    HKVNavigationRouteConfig *commonURL = [HKVNavigationRouteConfig sharedInstance];
    XCTAssertEqualObjects(commonURL.noteVC.absoluteString, @"vocabulary://viewcontroller/noteVC");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
