//  L3Event.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
	L3EventStatusUnknown = 0,
	L3EventStatusStarted = 1 << 1,
	L3EventStatusEnded = 1 << 2,
	L3EventStatusSucceeded = 1 << 3,
	L3EventStatusFailed = 1 << 4,
} L3EventState;

@interface L3Event : NSObject

+(instancetype)eventWithState:(L3EventState)state source:(id)source;

@property (nonatomic, readonly) L3EventState state;
@property (nonatomic, readonly) NSDate *date;

@end

// suite started
// suite ended
// test started
// test ended
// assertion passed
// assertion failed
// assertion failed unexpectedly (exception)
