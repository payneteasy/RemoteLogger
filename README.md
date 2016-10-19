# RemoteLogger

[![Build Status](https://travis-ci.org/payneteasy/RemoteLogger.svg?branch=master)](https://travis-ci.org/payneteasy/RemoteLogger)

RemoteLogger is an Objective-C library which helps you to send logs to your HTTPS server.

When we start to develop new application it is always requiring us to send debug messages to a server.
We should deal with the remote logging.
When we collect the debug messages we should always thinking about resource constraints.

Previously we had a bad experience using an UDP transfer.
It's unbelievable to always have all log messages on a server via UDP transfer,
so we came up with an HTTPS transfer.

Introducing RemoteLogger library.
It firstly saves debug messages to a memory buffer, then stores to a file and then sends them to an HTTPs server.

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

Please see SampleApp in this project to find out the best way to use the library.
https://github.com/payneteasy/RemoteLogger/tree/master/SampleApp

The code below shows principles. 

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

