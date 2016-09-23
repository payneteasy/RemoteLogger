//
//  RLMemoryBuffer.h
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 21/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLCurrentFile;

// Allocates buffer in memory to store log messages
@interface RLMemoryBuffer : NSObject

- (instancetype)init:(uint32_t)aSize;

- (BOOL)hasSpaceFor:(uint64_t)aMessageLength;

- (void)append:(NSData *)aMessage;

- (NSString *)description;

- (void) clearToFile:(RLCurrentFile *)aFile;
@end
