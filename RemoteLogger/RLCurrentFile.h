//
//  RLCurrentFile.h
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 21/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLCurrentFile : NSObject

- (instancetype)initWithDirectory:(NSURL *)aDirectory maxFileSize:(uint64_t)aFileSize;

- (BOOL) isLarge;

- (void) closeAndCreateNew;

- (void) write:(NSData *)aData;

- (NSString *) currentFilePath;

@end
