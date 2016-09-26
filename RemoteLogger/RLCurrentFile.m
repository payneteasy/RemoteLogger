//
//  RLCurrentFile.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 21/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import "RLCurrentFile.h"

@implementation RLCurrentFile {
    NSURL         * _directory;
    uint64_t        _maxFileSize;
    NSFileManager * _fileManager;
    NSURL         * _activeFile;

}

- (instancetype)initWithDirectory:(NSURL *)aDirectory maxFileSize:(uint64_t)aMaxFileSize {
    self = [super init];
    if (self) {
        _directory   = aDirectory;
        _maxFileSize = aMaxFileSize;
        _fileManager = [NSFileManager defaultManager];
        _activeFile  = [self createNewActiveFile];
    }
    return self;
}

- (BOOL)isLarge {
    NSError * error;
    NSDictionary *attributes = [_fileManager attributesOfItemAtPath:_activeFile.path error:&error];
    if(error) {
        NSLog(@"RL-ERROR Couldn't get file attributes for file %@, error is %@", _activeFile, error);
        return YES;
    }
    return attributes.fileSize > _maxFileSize;
}

- (void)closeAndCreateNew {
    NSString *path = _activeFile.path;
    if([_fileManager fileExistsAtPath:path]){
        [self renameFileToLog:path];
    }

    // close all -current files
    NSError * error;
    NSArray<NSString *> *files = [_fileManager contentsOfDirectoryAtPath:_directory.path error:&error ];
    if(error) {
        NSLog(@"RL-ERROR Could not get list of directory %@, error is %@", _directory, error);
    } else {
        NSArray<NSString *> *currentFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '-current'"]];
        for(NSString * filename in currentFiles) {
            [self renameFileToLog:[_directory.path stringByAppendingPathComponent:filename]];
        }
    }
    _activeFile = [self createNewActiveFile];
}

- (void)renameFileToLog:(NSString *)path {
    NSString * newPath = [path stringByAppendingString:@".log"];
    NSError *error;
    [_fileManager moveItemAtPath:path toPath:newPath error:&error];
    if(error) {
            NSLog(@"RL-ERROR Couldn't rename file %@ to %@ : %@", path, newPath, error);
        }
}

- (NSURL *)createNewActiveFile {
    NSString * filename = [NSString stringWithFormat:@"%@-current", @([[NSDate date] timeIntervalSince1970])];
    NSString * path     = [_directory.path stringByAppendingPathComponent:filename];
    return [[NSURL alloc] initFileURLWithPath:path];
}

- (void)write:(NSData *)aData {

    if([_fileManager fileExistsAtPath:_activeFile.path]){
        NSError * error;
        NSFileHandle * handle = [NSFileHandle fileHandleForWritingToURL:_activeFile error:&error];
        if(error) {
            NSLog(@"RL-ERROR Could not create file handle for file %@", _activeFile);
            return;
        }

        @try {
            [handle seekToEndOfFile];
            [handle writeData:aData];
        }
        @catch (NSException *exception) {
            NSLog(@"RL-ERROR Exception occurred: %@, %@", exception, [exception userInfo]);
        }
        @finally {
            [handle closeFile];
        }
    } else {
        NSError * error;
        [aData writeToURL:_activeFile options:NSDataWritingWithoutOverwriting error:&error];
        if(error) {
            NSLog(@"RL-ERROR Couldn't write to file %@, error is %@", _activeFile, error);
        }
    }

}

- (NSString *)currentFilePath {
    return _activeFile.path;
}


@end
