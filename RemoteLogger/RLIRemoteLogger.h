//
//  RLIRemoteLogger.h
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 21/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RLIRemoteLogger <NSObject>

- (void) mark;

- (void) send:(NSString *)aMessage;


@end

