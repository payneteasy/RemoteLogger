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
                  directory:(NSString *)aDirectory
           directoryCleaner:(RLDirectoryCleaner *)aDirectoryCleaner
{
    self = [super init];
    if (self) {
        _deviceId         = [UIDevice currentDevice].identifierForVendor.UUIDString;
        _uploadUrl        = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@", aUrl, _deviceId]];
        _fileManager      = [NSFileManager defaultManager];
        _directoryCleaner = aDirectoryCleaner;
    }

    return self;
}

- (void)removeOldFiles {
    [_directoryCleaner checkFilesCount];
    [_directoryCleaner checkDirectorySize];
}

- (void)uploadFiles {
    NSArray<NSString *> *files = _directoryCleaner.getSortedFiles;
    NSLog(@"%@ files to be uploaded", @(files.count));
    for(NSString * file in files) {
        [self uploadFile:file];
    }
}

- (void)uploadFile:(NSString *)aFilepath {

    NSURLRequest      * request = [self createHttpRequest:aFilepath];
    NSHTTPURLResponse * response;
    NSError           * error;

    NSLog(@"Sending %@ to %@", aFilepath, _uploadUrl);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
#pragma clang diagnostic pop

    if(error) {
        NSLog(@"Couldn't send %@ to %@ error is %@", aFilepath, _uploadUrl, error);
        return;
    }

    if(response.statusCode != 200) {
        NSLog(@"Couldn't send %@ \nto %@ \nresponse is %@ %@", aFilepath, _uploadUrl, @(response.statusCode), [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]);
        return;
    }

    RLFile * file = [[RLFile alloc] initWithPath:aFilepath manager:_fileManager];
    [file deleteFile];
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
    NSDictionary<NSFileAttributeKey, id> *attributes = [_fileManager attributesOfItemAtPath:filepath error:&error];
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
