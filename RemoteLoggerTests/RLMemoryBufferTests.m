//
//  RLMemoryBufferTests.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 21/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLMemoryBuffer.h"


@interface RLMemoryBufferTests : XCTestCase

@end

@implementation RLMemoryBufferTests

- (void)test_has_space {
    RLMemoryBuffer * buffer = [[RLMemoryBuffer alloc] init:10];

    XCTAssertTrue ([buffer hasSpaceFor:0]);
    XCTAssertTrue ([buffer hasSpaceFor:1]);
    XCTAssertTrue ([buffer hasSpaceFor:10]);

    XCTAssertFalse([buffer hasSpaceFor:11]);
}

- (void) test_append {
    RLMemoryBuffer * buffer = [[RLMemoryBuffer alloc] init:10];

    [buffer append:[@"1234" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(@"<RLMemoryBuffer: _buffer=<31323334 00000000 0000>, _position=4, _capacity=10>", buffer.description);

    [buffer append:[@"5678" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(@"<RLMemoryBuffer: _buffer=<31323334 35363738 0000>, _position=8, _capacity=10>", buffer.description);

    [buffer append:[@"90" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(@"<RLMemoryBuffer: _buffer=<31323334 35363738 3930>, _position=10, _capacity=10>", buffer.description);

    [buffer append:[@"abcd" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(@"<RLMemoryBuffer: _buffer=<31323334 35363738 3930>, _position=10, _capacity=10>", buffer.description);
}

- (void) test_append_with_cut {
    RLMemoryBuffer * buffer = [[RLMemoryBuffer alloc] init:10];
    [buffer append:[@"1234567890abcdef" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(@"<RLMemoryBuffer: _buffer=<31323334 35363738 3930>, _position=10, _capacity=10>", buffer.description);
}

- (void) test_clear_to_file {
    RLMemoryBuffer * buffer = [[RLMemoryBuffer alloc] init:10];
    [buffer append:[@"1234567890" dataUsingEncoding:NSUTF8StringEncoding]];
    [buffer clearToFile:nil];
    XCTAssertEqualObjects(@"<RLMemoryBuffer: _buffer=<31323334 35363738 3930>, _position=0, _capacity=10>", buffer.description);

    [buffer append:[@"abcd" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(@"<RLMemoryBuffer: _buffer=<61626364 35363738 3930>, _position=4, _capacity=10>", buffer.description);
}

@end
