//  L3TestSuiteStartEvent.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3Event.h"

@class L3TestSuite;

@interface L3TestSuiteStartEvent : L3Event

+(instancetype)eventWithSource:(L3TestSuite<L3EventSource> *)source;

@property (strong, nonatomic, readonly) L3TestSuite<L3EventSource> *source;

@end
