//
//  RLHttpRemoteLogger.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 21/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import "RLHttpRemoteLogger.h"
#import "RLMemoryBuffer.h"
#import "RLCurrentFile.h"
#import "RLHttpUploader.h"
#import "RLDirectoryCleaner.h"

@interface RLHttpRemoteLogger() {

}

@property (nonatomic, strong) RLMemoryBuffer   * memoryBuffer;
@property (nonatomic, strong) RLCurrentFile    * currentFile;
@property (nonatomic, strong) dispatch_queue_t   fileQueue;
@property (nonatomic, strong) dispatch_queue_t   uploadQueue;
@property (nonatomic, strong) RLHttpUploader   * httpUploader;
@end

@implementation RLHttpRemoteLogger

- (instancetype)initWithDirectory:(NSString *)aDirectory
                        uploadUrl:(NSString *)aUploadUrl
                 memoryBufferSize:(uint32_t)aMemoryBufferSize
                         fileSize:(uint64_t)aFileSize
                       loggerName:(NSString *)aLoggerName
                       filesCount:(uint32_t)aFilesCount
                    directorySize:(uint64_t)aDirectorySize
{
    self = [super init];
    if (self) {
        NSURL              * directoryUrl = [[NSURL alloc] initFileURLWithPath:aDirectory];
        RLDirectoryCleaner * cleaner      = [[RLDirectoryCleaner alloc]
                initWithDir:aDirectory
                 filesCount:aFilesCount
              directorySize:aDirectorySize];

        _memoryBuffer = [[RLMemoryBuffer alloc] init:aMemoryBufferSize];
        _currentFile  = [[RLCurrentFile alloc] initWithDirectory:directoryUrl maxFileSize:aFileSize];
        _httpUploader = [[RLHttpUploader alloc] initWithUrl:aDirectory directory:aDirectory directoryCleaner:cleaner];
        _fileQueue    = dispatch_queue_create([@"io.pne.queue.file."   stringByAppendingString:aLoggerName].UTF8String, DISPATCH_QUEUE_SERIAL);
        _uploadQueue  = dispatch_queue_create([@"io.pne.queue.upload." stringByAppendingString:aLoggerName].UTF8String, DISPATCH_QUEUE_SERIAL);
        _httpUploader = [[RLHttpUploader alloc] initWithUrl:aUploadUrl directory:aDirectory directoryCleaner:cleaner];
    }

    return self;
}

- (void)send:(NSString *)aMessage {
    NSData * data = [aMessage dataUsingEncoding:NSUTF8StringEncoding];

    __weak RLHttpRemoteLogger * wself = self;
    dispatch_async(_fileQueue, ^{

        if([wself.memoryBuffer hasSpaceFor:data.length]) {
            [wself.memoryBuffer append:data];
        } else {
            [wself.memoryBuffer clearToFile:wself.currentFile];
            [wself.memoryBuffer append:data];

            if(wself.currentFile.isLarge) {
                [wself.currentFile closeAndCreateNew];

                dispatch_async(wself.uploadQueue, ^{
                    [wself.httpUploader removeOldFiles];
                    [wself.httpUploader uploadFiles];
                });
            }
        }
    });
}

- (void)mark {
    NSLog(@"Mark");

    __weak RLHttpRemoteLogger * wself = self;
    dispatch_async(_fileQueue, ^{
        NSLog(@"Clear to file");

        [wself.memoryBuffer clearToFile:wself.currentFile];
        [wself.currentFile closeAndCreateNew];

        dispatch_async(wself.uploadQueue, ^{
            [wself.httpUploader removeOldFiles];
            NSLog(@"Uploading files ...");
            [wself.httpUploader uploadFiles];
        });
    });
}


@end
