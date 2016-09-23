//
//  RLMemoryBuffer.m
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 21/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import "RLMemoryBuffer.h"
#import "RLCurrentFile.h"

@implementation RLMemoryBuffer {
    NSMutableData * _buffer;
    uint32_t        _position;
    uint32_t        _capacity;
}

- (instancetype)init:(uint32_t)aSize {
    self = [super init];
    if (self) {
        _capacity      = aSize;
        _position      = 0;
        _buffer        = [[NSMutableData alloc] initWithCapacity:aSize];
        _buffer.length = aSize;
    }

    return self;
}

- (BOOL)hasSpaceFor:(uint64_t)aMessageLength {
    return _position + aMessageLength <= _capacity;
}

- (void)append:(NSData *)aMessage {
    uint32_t count = (uint32_t)aMessage.length + _position > _capacity
            ? _capacity - _position
            : (uint32_t)aMessage.length;

    [_buffer replaceBytesInRange:NSMakeRange(_position, count) withBytes:aMessage.bytes length:count];
    _position += count;
}

- (void)clearToFile:(RLCurrentFile *)aFile {
    NSData * data = [_buffer subdataWithRange:NSMakeRange(0, _position)];
    [aFile write:data];
    _position = 0;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"_buffer=%@", _buffer];
    [description appendFormat:@", _position=%u", _position];
    [description appendFormat:@", _capacity=%u", _capacity];
    [description appendString:@">"];
    return description;
}

@end
