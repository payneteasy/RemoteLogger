//
//  RLHttpUploader.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 23/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RLHttpUploader.h"
#import "RLFile.h"
#import "RLDirectoryCleaner.h"

@implementation RLHttpUploader {
    NSURL              * _uploadUrl;
    NSString           * _deviceId;
    NSFileManager      * _fileManager;
    NSString           * _bearer;
    RLDirectoryCleaner * _directoryCleaner;
}

- (instancetype)initWithUrl:(NSString *)aUrl
                accessToken:(NSString *)aAccessToken
                  directory:(NSString *)aDirectory
           directoryCleaner:(RLDirectoryCleaner *)aDirectoryCleaner
{
    self = [super init];
    if (self) {
        _deviceId         = [UIDevice currentDevice].identifierForVendor.UUIDString;
        _uploadUrl        = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@", aUrl, _deviceId]];
        _fileManager      = [NSFileManager defaultManager];
        _directoryCleaner = aDirectoryCleaner;
        _bearer           = [NSString stringWithFormat:@"Bearer %@", aAccessToken];
    }

    return self;
}

- (void)removeOldFiles {
    [_directoryCleaner checkFilesCount];
    [_directoryCleaner checkDirectorySize];
}

- (void)uploadFiles {
    NSArray<NSString *> *files = _directoryCleaner.getSortedFiles;
    NSLog(@"RL-INFO %@ files to be uploaded", @(files.count));
    for(NSString * file in files) {
        [self uploadFile:file];
    }
}

- (void)uploadFile:(NSString *)aFilepath {

    RLFile * file = [[RLFile alloc] initWithPath:aFilepath manager:_fileManager];
    uint64_t fileSize = file.fileLength;
    if(fileSize <= 0 ) {
        [file deleteFile:@"file size is 0 (wasn't uploaded)"];
        return;
    }

    NSURLRequest      * request = [self createHttpRequest:aFilepath];
    NSHTTPURLResponse * response;
    NSError           * error;

    NSLog(@"RL-INFO Sending %@ bytes from %@ to %@", @(fileSize), aFilepath.lastPathComponent, _uploadUrl);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
#pragma clang diagnostic pop

    if(error) {
        NSLog(@"RL-ERROR Couldn't send %@ to %@ error is %@", aFilepath, _uploadUrl, error);
        return;
    }

    if(response.statusCode != 200) {
        NSLog(@"RL-ERROR Couldn't send %@ \nto %@ \nresponse is %@ %@", aFilepath, _uploadUrl, @(response.statusCode), [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]);
        return;
    }

    [file deleteFile:@"uploaded to server"];
}

- (NSURLRequest *)createHttpRequest:(NSString *)aFilepath {

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_uploadUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/octet-stream"    forHTTPHeaderField:@"Content-Type"];
    [request setValue:[self getAttachment:aFilepath] forHTTPHeaderField:@"Content-Disposition"];
    [request setValue:[self getFileSize:aFilepath]   forHTTPHeaderField:@"Content-Length"];
    [request setValue:_bearer                        forHTTPHeaderField:@"Authorization"];
    [request setValue:_deviceId                      forHTTPHeaderField:@"Device-id"];

    NSURL  * fileUrl  = [[NSURL alloc] initFileURLWithPath:aFilepath];
    NSData * httpBody = [[NSData alloc] initWithContentsOfURL:fileUrl];
    [request setHTTPBody:httpBody];

    return request;
}

- (NSString *)getFileSize:(NSString *)filepath {
    NSError * error;
    NSDictionary *attributes = [_fileManager attributesOfItemAtPath:filepath error:&error];
    if(error) {
        return @"0";
    }
    return [NSString stringWithFormat:@"%@", @(attributes.fileSize)];
}

- (NSString *)getAttachment:(NSString *)filePath {
    return [NSString stringWithFormat:@"attachment; filename=\"%@\"", filePath.lastPathComponent];
    ;
}
@end
