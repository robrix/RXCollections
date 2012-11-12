//  L3Event.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3EventVisitor.h"
#import "L3EventSource.h"

typedef enum : NSUInteger {
	L3EventStateUnknown = 0,
	L3EventStateStarted = 1 << 1,
	L3EventStateEnded = 1 << 2,
	L3EventStateSucceeded = 1 << 3,
	L3EventStateFailed = 1 << 4,
} L3EventState;

@protocol L3Event <NSObject>

@property (nonatomic, readonly) NSDate *date;

@end

@interface L3Event : NSObject <L3Event>

+(instancetype)eventWithState:(L3EventState)state source:(id<L3EventSource>)source;

@property (nonatomic, readonly) L3EventState state;
@property (strong, nonatomic, readonly) id<L3EventSource> source;

-(id)acceptVisitor:(id<L3EventVisitor>)visitor;

@end

// suite started
// suite ended
// test started
// test ended
// assertion passed
// assertion failed
// assertion failed unexpectedly (exception)
