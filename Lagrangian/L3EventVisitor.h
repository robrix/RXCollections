//  L3EventVisitor.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3Event;

@protocol L3EventVisitor <NSObject>

-(id)unknownEvent:(L3Event *)event;

-(id)startedEvent:(L3Event *)started;
-(id)endedEvent:(L3Event *)event;

-(id)succeededEvent:(L3Event *)event;
-(id)failedEvent:(L3Event *)event;

@end
