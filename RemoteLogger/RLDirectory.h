//
//  RLDirectory.h
//  RemoteLogger
//
//  Created by Evgeniy Sinev on 23/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLDirectory : NSObject

- (instancetype)initCacheWithName:(NSString *)aName;

-(void)mkDir;

-(NSString *)path;

@end
