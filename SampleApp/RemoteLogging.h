//
//  RemoteLogging.h
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 26/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLHttpRemoteLogger;

# define DLog(fmt, ...) [RemoteLogging send:__PRETTY_FUNCTION__ line:__LINE__ originalFormat:fmt , ##__VA_ARGS__];

@interface RemoteLogging : NSObject

+ (RLHttpRemoteLogger *)sharedInstance;

+ (void)incrementSession;

+ (void)send:(const char *)aSender line:(int)aLine originalFormat:(NSString *)aOriginalFormat, ... ;


@end
