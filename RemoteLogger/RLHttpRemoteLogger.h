//
//  RLHttpRemoteLogger.h
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 21/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLIRemoteLogger.h"

@interface RLHttpRemoteLogger : NSObject<RLIRemoteLogger>

+(NSString *) loggerVersion;

- (instancetype)initWithDirectory:(NSString *)aDirectory
                        uploadUrl:(NSString *)aUploadUrl
                      accessToken:(NSString *)aAccessToken
                 memoryBufferSize:(uint32_t)aMemoryBufferSize
                         fileSize:(uint64_t)aFileSize
                       loggerName:(NSString *)aLoggerName
                       filesCount:(uint32_t)aFilesCount
                    directorySize:(uint64_t)aDirectorySize
;

@end
