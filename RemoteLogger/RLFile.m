//
//  RLFile.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 23/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import "RLFile.h"

@implementation RLFile {
    NSString      * _path;
    NSFileManager * _manager;
}

- (instancetype)initWithPath:(NSString *)aPath manager:(NSFileManager *)aManager {
    self = [super init];
    if (self) {
        _path = aPath;
        _manager = aManager;
    }

    return self;
}

-(void) deleteFile:(NSString *)aReason {
    NSLog(@"RL-INFO Deleting file: %@ because %@", _path.lastPathComponent, aReason);
    NSError * error;
    [_manager removeItemAtPath:_path error:&error];
    if(error){
        NSLog(@"RL-ERROR Couldn't remote file %@, error is %@", _path, error);
    }
}

- (uint64_t)fileLength {
    NSError * error;
    NSDictionary *attributes = [_manager attributesOfItemAtPath:_path error:&error];
    if(error) {
        NSLog(@"RL-ERROR Couldn't get file size %@", _path);
        return 0;
    }
    return attributes.fileSize;
}
@end
