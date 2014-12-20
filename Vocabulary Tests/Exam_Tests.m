//
//  Exam_Tests.m
//  Vocabulary
//
//  Created by 缪和光 on 20/12/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CoreData+MagicalRecord.h"
#import "Word.h"
#import "ExamContent.h"

@interface Exam_Tests : XCTestCase

@end

@implementation Exam_Tests

- (void)setUp {
    [super setUp];
    [MagicalRecord cleanUp];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
}

- (void)tearDown {
    [MagicalRecord cleanUp];
    [super tearDown];
}

@end
