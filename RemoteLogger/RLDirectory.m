//
//  RLDirectory.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 23/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import "RLDirectory.h"

@implementation RLDirectory {

    NSURL         * _dirUrl;
    NSFileManager * _fileManager;
}


- (instancetype)initCacheWithName:(NSString *)aName  {
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];

        NSString * cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * logsDirectory = [cacheDirectory stringByAppendingPathComponent:aName];
        _dirUrl = [[NSURL alloc] initFileURLWithPath:logsDirectory isDirectory:YES];
    }
    return self;
}

-(void)mkDir {
    NSString *path = _dirUrl.path;
    if(![_fileManager fileExistsAtPath:path]) {
        NSError * error;
        [_fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        if(error){
            NSLog(@"Could not create directory: %@", path);
        }
    }
}

- (NSString *)path {
    return _dirUrl.path;
}


@end
