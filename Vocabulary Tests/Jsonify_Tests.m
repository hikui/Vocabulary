//
//  Jsonify_Tests.m
//  Vocabulary
//
//  Created by 缪和光 on 21/12/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Word.h"
#import "WordList.h"
#import "Note.h"
#import "CoreData+MagicalRecord.h"


@interface Jsonify_Tests : XCTestCase

@end

@implementation Jsonify_Tests

- (void)setUp {
    [super setUp];
    [MagicalRecord cleanUp];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
}

- (void)tearDown {
    [MagicalRecord cleanUp];
    [super tearDown];
}


- (void)testModelToJSON {
    
    Note *note = [Note MR_createEntity];
    note.textNote = @"text Note";
    
    Word *w = [Word MR_createEntity];
    w.key = @"key1";
    w.acceptation = @"key1 acceptation";
    w.familiarity = @(4);
    w.note = note;
    w.lastVIewDate = [NSDate date];
    
    WordList *wl = [WordList MR_createEntity];
    wl.title = @"word list";
    wl.lastReviewTime = [NSDate date];
    [wl addWordsObject:w];
    
    NSLog(@"%@", [w toJSON]);
    NSLog(@"%@", [wl toJSON]);
    NSLog(@"%@", [note toJSON]);
}

@end
