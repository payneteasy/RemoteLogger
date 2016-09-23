# RemoteLogger

[![Build Status](https://travis-ci.org/payneteasy/RemoteLogger.svg?branch=master)](https://travis-ci.org/payneteasy/RemoteLogger)

RemoteLogger is an Objective-C library which helps you to send logs to your HTTPS server.

It firstly saves log lines to a memory buffer, then to a file and then sends to a http server.

## Features

* lightweight (no external dependencies)
* send logs via http/https

## Setup with dependency managers

### Cocoapods

    pod 'RemoteLogging', '0.1.0'

or

    pod "BerTlv", :git => 'git@github.com:payneteasy/RemoteLogging.git', :tag => '0.1.0'

### Carthage

    github "RemoteLogging/BerTlv"  "0.1.0"

## How to use it
    
You can create DLog macros and use it to send all logs to your http server.
 
For example

```obj-c
# define DLog(fmt, ...) [RemoteLogging send:__PRETTY_FUNCTION__ line:__LINE__ originalFormat:fmt , ##__VA_ARGS__];
 
 @interface RemoteLogging : NSObject
 
 +(void)incrementSession;
 
 +(void)     send:(const char*) aSender
             line:(int) aLine
   originalFormat:(NSString *)aOriginalFormat
                 , ...
 ;
 
 @end

@implementation RemoteLogging

+ (RLHttpRemoteLogger *) sharedInstance {
    static dispatch_once_t      predicate;
    static RLHttpRemoteLogger   * instance;

    dispatch_once(&predicate, ^{
        RLDirectory * directory = [[RLDirectory alloc] initCacheWithName:@"remote-logs"];
        [directory mkDir];

        instance = [[RLHttpRemoteLogger alloc]
                initWithDirectory:directory.path
                        uploadUrl:YOUR_UPLOAD_URL
                      accessToken:YOUR_ACCESS_TOKEN
                 memoryBufferSize:50  * 1024
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
    va_start(args,aOriginalFormat);
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

``` 

