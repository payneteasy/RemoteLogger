//
//  RLDirectoryCleaner.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 23/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import "RLDirectoryCleaner.h"
#import "RLFile.h"

@implementation RLDirectoryCleaner {
    NSString      * _directoryPath;
    uint32_t        _filesCount;
    uint64_t        _directorySize;
    NSFileManager * _fileManager;
    NSPredicate   * _predicate;
}

- (instancetype)initWithDir:(NSString *)aDir filesCount:(uint32_t)aFilesCount directorySize:(uint64_t)aDirectorySize  {
    self = [super init];
    if (self) {
        _directoryPath = aDir;
        _filesCount    = aFilesCount;
        _directorySize = aDirectorySize;
        _predicate     = [NSPredicate predicateWithFormat:@"self ENDSWITH '.log'"];
        _fileManager   = [NSFileManager defaultManager];
    }

    return self;
}

- (void)checkDirectorySize {
    NSArray<NSString *> *files = [self getSortedFiles];
    if(files.count == 0) {
        return;
    }

    long sum = 0;
    for (int64_t i = files.count - 1; i >= 0 ; --i) {
        NSString * filepath = files[(NSUInteger) i];
        RLFile * file = [[RLFile alloc] initWithPath:filepath manager:_fileManager];

        sum += file.fileLength;

        if(sum > _directorySize) {
            [file deleteFile:@" directory size"];
        }
    }
}

- (void)checkFilesCount {
    NSArray<NSString *> *files = [self getSortedFiles];
    if(files.count == 0) {
        return;
    }

    int64_t deletesCount = (int64_t)files.count - _filesCount;
    for (int32_t i = 0; i < deletesCount && i < files.count; i++) {
        RLFile * file = [[RLFile alloc] initWithPath:files[(NSUInteger) i] manager:_fileManager];
        [file deleteFile:@"files count"];
    }
}

- (NSArray<NSString *> *)getSortedFiles {

    NSMutableArray<NSString *> * unsortedFiles = [[NSMutableArray alloc] init];

    NSError * error;
    NSArray<NSString *> *files = [_fileManager contentsOfDirectoryAtPath:_directoryPath error:&error ];
    if(error) {
        NSLog(@"RL-ERROR Could not get list of directory %@, error is %@", _directoryPath, error);
    } else {
        NSArray<NSString *> *currentFiles = [files filteredArrayUsingPredicate:_predicate];
        for(NSString * filename in currentFiles) {
            [unsortedFiles addObject:[_directoryPath stringByAppendingPathComponent:filename]];
        }
    }

    [unsortedFiles sortUsingSelector:@selector(caseInsensitiveCompare:)];

    return unsortedFiles;
}

@end
