//  L3TestSuiteEndEvent.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3Event.h"

@class L3TestSuite;

@interface L3TestSuiteEndEvent : L3Event

+(instancetype)eventWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date;

@property (strong, nonatomic, readonly) L3TestSuite *testSuite;

@end
