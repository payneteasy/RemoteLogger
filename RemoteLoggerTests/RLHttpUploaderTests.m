//
//  RLHttpUploaderTests.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 23/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLHttpUploader.h"
#import "RLCurrentFile.h"

@interface RLHttpUploaderTests : XCTestCase

@end

@implementation RLHttpUploaderTests

- (void)test_update_files {
//    NSString * cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString * logsDirectory = [cacheDirectory stringByAppendingPathComponent:@"remote-logs"];
//
//    RLCurrentFile * file = [[RLCurrentFile alloc] initWithDirectory:[[NSURL alloc] initFileURLWithPath:logsDirectory] maxFileSize:10];
//
//    NSData * bytes5 = [@"12345" dataUsingEncoding:NSUTF8StringEncoding];
//    [file write:bytes5];
//    [file closeAndCreateNew];
//
//    // todo create local http server
//    RLHttpUploader * uploader = [[RLHttpUploader alloc]
//            initWithUrl:@"http://localhost:12345"
//              directory:logsDirectory
//            directoryCleaner:nil
//    ];
//    [uploader uploadFiles];
}

@end
