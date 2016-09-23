//
//  RLCurrentFileTest.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 22/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLCurrentFile.h"

@interface RLCurrentFileTest : XCTestCase

@end

@implementation RLCurrentFileTest {
    NSURL * _directory;
    NSFileManager *_fileManager;
}

- (void)setUp {
    [super setUp];

    _fileManager = [NSFileManager defaultManager];

    NSString * cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * logsDirectory = [cacheDirectory stringByAppendingPathComponent:@"remote-logs"];
    if(![_fileManager fileExistsAtPath:logsDirectory]) {
        NSError * error;
        [_fileManager createDirectoryAtPath:logsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        if(error){
            NSLog(@"Could not create directory: %@", logsDirectory);
        }
    }

    _directory = [[NSURL alloc] initFileURLWithPath:logsDirectory isDirectory:YES];
    NSLog(@"Logs directory is %@", _directory);
}


- (void)test_write {
    RLCurrentFile * file = [[RLCurrentFile alloc] initWithDirectory:_directory maxFileSize:10];

    NSData * bytes5 = [@"12345" dataUsingEncoding:NSUTF8StringEncoding];
    [file write:bytes5];

    {
        NSError * error;
        NSDictionary<NSFileAttributeKey, id> *attributes = [_fileManager attributesOfItemAtPath:file.currentFilePath error:&error];
        XCTAssertEqual(5, attributes.fileSize);

        NSData * data = [[NSData alloc] initWithContentsOfFile:file.currentFilePath];
        XCTAssertEqualObjects(@"<31323334 35>", data.description);
    }


    [file write:bytes5];

    {
        NSError * error;
        NSDictionary<NSFileAttributeKey, id> *attributes = [_fileManager attributesOfItemAtPath:file.currentFilePath error:&error];
        XCTAssertEqual(10, attributes.fileSize);

        NSData * data = [[NSData alloc] initWithContentsOfFile:file.currentFilePath];
        XCTAssertEqualObjects(@"<31323334 35313233 3435>", data.description);
    }
}

- (void)test_is_large {
    RLCurrentFile * file = [[RLCurrentFile alloc] initWithDirectory:_directory maxFileSize:10];

    NSData * bytes5 = [@"12345" dataUsingEncoding:NSUTF8StringEncoding];
    [file write:bytes5];

    NSError * error;
    NSDictionary<NSFileAttributeKey, id> *attributes = [_fileManager attributesOfItemAtPath:file.currentFilePath error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(5, attributes.fileSize);
    XCTAssertFalse(file.isLarge);

    [file write:bytes5];
    XCTAssertFalse(file.isLarge);

    [file write:bytes5];
    XCTAssertTrue(file.isLarge);

}

-(void) test_close_and_create_new {
    RLCurrentFile * file = [[RLCurrentFile alloc] initWithDirectory:_directory maxFileSize:10];

    NSData * bytes5 = [@"12345" dataUsingEncoding:NSUTF8StringEncoding];
    [file write:bytes5];

    NSString * filenameCurrent = file.currentFilePath;
    NSString * filenameLog = [filenameCurrent stringByAppendingString:@".log"];
    [file closeAndCreateNew];

    XCTAssertNotEqualObjects(filenameCurrent, file.currentFilePath);
    XCTAssertTrue([_fileManager fileExistsAtPath:filenameLog]);
    XCTAssertFalse([_fileManager fileExistsAtPath:filenameCurrent]);

    {
        NSError * error;
        NSDictionary<NSFileAttributeKey, id> *attributes = [_fileManager attributesOfItemAtPath:filenameLog error:&error];
        XCTAssertEqual(5, attributes.fileSize);

        NSData * data = [[NSData alloc] initWithContentsOfFile:filenameLog];
        XCTAssertEqualObjects(@"<31323334 35>", data.description);
    }

}

-(void) test_do_not_create_empty_file {
    RLCurrentFile * file = [[RLCurrentFile alloc] initWithDirectory:_directory maxFileSize:10];

    NSString * filenameCurrent = file.currentFilePath;
    NSString * filenameLog = [filenameCurrent stringByAppendingString:@".log"];
    [file closeAndCreateNew];

    XCTAssertFalse([_fileManager fileExistsAtPath:filenameLog]);
    XCTAssertFalse([_fileManager fileExistsAtPath:filenameCurrent]);

}
@end
