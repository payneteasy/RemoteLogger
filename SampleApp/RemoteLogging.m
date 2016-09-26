//
//  RemoteLogging.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 26/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import "RemoteLogging.h"
#import "RLHttpRemoteLogger.h"
#import "RLDirectory.h"

NSString *YOUR_UPLOAD_URL = @"https://paynet-qa.clubber.me/paynet/log-upload";

NSString *YOUR_ACCESS_TOKEN = @"1234";


@implementation RemoteLogging

+ (RLHttpRemoteLogger *)sharedInstance {
    static dispatch_once_t predicate;
    static RLHttpRemoteLogger *instance;

    dispatch_once(&predicate, ^{
        RLDirectory *directory = [[RLDirectory alloc] initCacheWithName:@"remote-logs"];
        [directory mkDir];

        instance = [[RLHttpRemoteLogger alloc]
                initWithDirectory:directory.path
                        uploadUrl:YOUR_UPLOAD_URL
                      accessToken:YOUR_ACCESS_TOKEN
                 memoryBufferSize:50 * 1024
                         fileSize:200 * 1024
                       loggerName:@"remote"
                       filesCount:50
                    directorySize:10 * 1024 * 1024];
    });
    return instance;
}

+ (void)incrementSession {
    [[RemoteLogging sharedInstance] mark];
}

+ (void)send:(const char *)aSender line:(int)aLine originalFormat:(NSString *)aOriginalFormat, ... {
    va_list args;
    va_start(args, aOriginalFormat);
    NSString *logLine = [[NSString alloc] initWithFormat:aOriginalFormat arguments:args];
    va_end(args);

// write to log immediately
    NSLog(@"%@: %@", [NSThread currentThread], logLine);

    NSString *outputText = [self createOutputText:aSender aLine:aLine text:logLine];
    [[RemoteLogging sharedInstance] send:outputText];
}

+ (NSString *)createOutputText:(char const *)aSender aLine:(int)aLine text:(NSString *)aText {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS ZZZZZ"];

// date
// sender
// line
// log line
    NSString *outputText = [NSString stringWithFormat:@"%@ %s,%d - %@\n"
            , [dateFormat stringFromDate:[NSDate date]]
            , aSender
            , aLine
            , aText
    ];
    return outputText;
}

@end


