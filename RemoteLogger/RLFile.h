//
//  RLFile.h
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 23/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLFile : NSObject

- (instancetype)initWithPath:(NSString *)aPath manager:(NSFileManager *)aManager;

- (void)deleteFile;

- (uint64_t)fileLength;
@end
