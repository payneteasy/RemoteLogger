//
//  RLHttpRemoteLoggerTests.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 23/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLHttpRemoteLogger.h"
#import "RLDirectory.h"


@interface RLHttpRemoteLoggerTests : XCTestCase

@end

@implementation RLHttpRemoteLoggerTests

- (void)test_integration {

//    RLDirectory * directory = [[RLDirectory alloc] initCacheWithName:@"remote-logs"];
//    [directory mkDir];
//
//    RLHttpRemoteLogger * logger = [[RLHttpRemoteLogger alloc]
//            initWithDirectory:directory.path
//                    uploadUrl:@"http://localhost:12345"
//             memoryBufferSize:50  * 1024
//                     fileSize:200 * 1024
//                   loggerName:@"remote"
//                   filesCount:50
//                directorySize:10 * 1024 * 1024];
//
//    [logger send:@"12345\n"];
//    [logger send:@"678910\n"];
//
//    [logger mark];
//
//    NSLog(@"Sleeping 10 second");
//    sleep(10);
}


@end
