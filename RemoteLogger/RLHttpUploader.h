//
//  RLHttpUploader.h
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 23/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLDirectoryCleaner;

@interface RLHttpUploader : NSObject

- (instancetype)initWithUrl:(NSString *)aUrl
                  directory:(NSString *)aDirectory
           directoryCleaner:(RLDirectoryCleaner *)aDirectoryCleaner
;

- (void)removeOldFiles;

- (void)uploadFiles;

@end
