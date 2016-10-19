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
                      accessToken:(NSString *)aAccessToken
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
        _fileQueue    = dispatch_queue_create([@"io.pne.queue.file."   stringByAppendingString:aLoggerName].UTF8String, DISPATCH_QUEUE_SERIAL);
        _uploadQueue  = dispatch_queue_create([@"io.pne.queue.upload." stringByAppendingString:aLoggerName].UTF8String, DISPATCH_QUEUE_SERIAL);
        _httpUploader = [[RLHttpUploader alloc] initWithUrl:aUploadUrl
                                                accessToken:aAccessToken
                                                  directory:aDirectory
                                           directoryCleaner:cleaner];
    }

    return self;
}

- (void)send:(NSString *)aMessage {
    NSData * data = [aMessage dataUsingEncoding:NSUTF8StringEncoding];

    dispatch_async(_fileQueue, ^{

        if([self.memoryBuffer hasSpaceFor:data.length]) {
            [self.memoryBuffer append:data];
        } else {
            [self.memoryBuffer clearToFile:self.currentFile];
            [self.memoryBuffer append:data];

            if(self.currentFile.isLarge) {
                [self.currentFile closeAndCreateNew];

                dispatch_async(self.uploadQueue, ^{
                    [self.httpUploader removeOldFiles];
                    [self.httpUploader uploadFiles];
                });
            }
        }
    });
}

- (void)mark {
    NSLog(@"RL-INFO Mark");

    dispatch_async(_fileQueue, ^{
        NSLog(@"RL-INFO Clear to file");

        [self.memoryBuffer clearToFile:self.currentFile];
        [self.currentFile closeAndCreateNew];

        dispatch_async(self.uploadQueue, ^{
            [self.httpUploader removeOldFiles];
            NSLog(@"RL-INFO Uploading files ...");
            [self.httpUploader uploadFiles];
        });
    });
}


@end
