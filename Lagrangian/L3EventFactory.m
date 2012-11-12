//  L3EventFactory.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3EventFactory.h"
#import "L3TestSuiteStartEvent.h"
#import "L3TestSuiteEndEvent.h"
#import "L3TestCaseStartEvent.h"
#import "L3TestCaseEndEvent.h"
#import "L3AssertionFailureEvent.h"
#import "L3AssertionSuccessEvent.h"

@implementation L3EventFactory

-(id)testSuiteStartEventWithSource:(L3TestSuite<L3EventSource> *)source {
	return [L3TestSuiteStartEvent eventWithSource:source];
}

-(id)testSuiteEndEventWithSource:(L3TestSuite<L3EventSource> *)source {
	return [L3TestSuiteEndEvent eventWithSource:source];
}


-(id)testCaseStartEventWithSource:(L3TestCase<L3EventSource> *)source {
	return [L3TestCaseStartEvent eventWithSource:source];
}

-(id)testCaseEndEventWithSource:(L3TestCase<L3EventSource> *)source {
	return [L3TestCaseEndEvent eventWithSource:source];
}


-(id)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference source:(id<L3EventSource>)source {
	return [L3AssertionFailureEvent eventWithAssertionReference:assertionReference source:source];
}

-(L3AssertionSuccessEvent *)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference source:(id<L3EventSource>)source {
	return [L3AssertionSuccessEvent eventWithAssertionReference:assertionReference source:source];
}

@end
