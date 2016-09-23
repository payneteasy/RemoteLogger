//
//  RLDirectoryCleaner.h
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 23/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLDirectoryCleaner : NSObject

- (instancetype)initWithDir:(NSString *)aDir filesCount:(uint32_t)aFilesCount directorySize:(uint64_t)aDirectorySize;

- (NSArray<NSString *> *)getSortedFiles;

- (void)checkFilesCount;

- (void)checkDirectorySize;

@end
