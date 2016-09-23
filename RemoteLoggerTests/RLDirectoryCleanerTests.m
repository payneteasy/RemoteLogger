//
//  RLDirectoryCleanerTests.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 23/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLDirectoryCleaner.h"
#import "RLFile.h"

@interface RLDirectoryCleanerTests : XCTestCase

@end

@implementation RLDirectoryCleanerTests {
    NSFileManager * _fileManager;
    NSURL         * _directory;
}

- (void)setUp {
    [super setUp];

    _fileManager = [NSFileManager defaultManager];

    NSString * cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * logsDirectory  = [cacheDirectory stringByAppendingPathComponent:@"remote-logs"];
    if(![_fileManager fileExistsAtPath:logsDirectory]) {
        NSError * error;
        [_fileManager createDirectoryAtPath:logsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        if(error){
            NSLog(@"Could not create directory: %@", logsDirectory);
        }
    }
    _directory = [[NSURL alloc] initFileURLWithPath:logsDirectory];

    // clean directory
    NSError * error;
    NSArray<NSString *> *files = [_fileManager contentsOfDirectoryAtPath:_directory.path error:&error ];
    for(NSString * filename in files) {
        RLFile * file = [[RLFile alloc]
                initWithPath:[_directory.path stringByAppendingPathComponent:filename]
                     manager:_fileManager];
        [file deleteFile];
    }

    // creates test files
    [self createFile:@"5.log"];
    [self createFile:@"3.log"];
    [self createFile:@"4.log"];
    [self createFile:@"1.log"];
    [self createFile:@"2.log"];


}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_get_sorted_files {
    RLDirectoryCleaner * cleaner = [[RLDirectoryCleaner alloc] initWithDir:_directory.path filesCount:5 directorySize:5];
    NSArray<NSString *> *files = cleaner.getSortedFiles;
    XCTAssertNotNil(files);
    XCTAssertEqual(5, files.count);

    XCTAssertEqualObjects(@"1.log", files[0].lastPathComponent);
    XCTAssertEqualObjects(@"2.log", files[1].lastPathComponent);
    XCTAssertEqualObjects(@"3.log", files[2].lastPathComponent);
    XCTAssertEqualObjects(@"4.log", files[3].lastPathComponent);
    XCTAssertEqualObjects(@"5.log", files[4].lastPathComponent);
}

- (void)test_check_files_count {
    RLDirectoryCleaner * cleaner = [[RLDirectoryCleaner alloc] initWithDir:_directory.path filesCount:3 directorySize:100];
    [cleaner checkFilesCount];

    NSArray<NSString *> *files = cleaner.getSortedFiles;
    XCTAssertNotNil(files);
    XCTAssertEqual(3, files.count);

    XCTAssertEqualObjects(@"3.log", files[0].lastPathComponent);
    XCTAssertEqualObjects(@"4.log", files[1].lastPathComponent);
    XCTAssertEqualObjects(@"5.log", files[2].lastPathComponent);
}

- (void)test_check_directory_size {
    RLDirectoryCleaner * cleaner = [[RLDirectoryCleaner alloc] initWithDir:_directory.path filesCount:20 directorySize:10];
    [cleaner checkDirectorySize];

    NSArray<NSString *> *files = cleaner.getSortedFiles;
    XCTAssertNotNil(files);
    XCTAssertEqual(2, files.count);

    XCTAssertEqualObjects(@"4.log", files[0].lastPathComponent);
    XCTAssertEqualObjects(@"5.log", files[1].lastPathComponent);
}

- (void)createFile:(NSString *)aFilename {
    NSData * data = [@"12345" dataUsingEncoding:NSUTF8StringEncoding];
    NSString * filepath = [_directory.path stringByAppendingPathComponent:aFilename];
    [data writeToFile:filepath atomically:NO];
}

@end
