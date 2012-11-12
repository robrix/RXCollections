//  L3AssertionEvent.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3Event.h"

@class L3AssertionReference;

@interface L3AssertionEvent : L3Event

+(instancetype)eventWithAssertion:(L3AssertionReference *)assertionReference source:(id<L3EventSource>)source;

@property (copy, nonatomic, readonly) L3AssertionReference *assertionReference;

@end
