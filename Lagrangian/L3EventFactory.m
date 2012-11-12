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

-(L3TestSuiteStartEvent *)testSuiteStartEventWithTestSuite:(L3TestSuite *)testSuite {
	return [L3TestSuiteStartEvent eventWithTestSuite:testSuite];
}

-(L3TestSuiteEndEvent *)testSuiteEndEventWithTestSuite:(L3TestSuite *)testSuite {
	return [L3TestSuiteEndEvent eventWithTestSuite:testSuite];
}


-(L3TestCaseStartEvent *)testCaseStartEventWithTestCase:(L3TestCase *)testCase {
	return [L3TestCaseStartEvent eventWithTestCase:testCase];
}

-(L3TestCaseEndEvent *)testCaseEndEventWithTestCase:(L3TestCase *)testCase {
	return [L3TestCaseEndEvent eventWithTestCase:testCase];
}


-(L3AssertionFailureEvent *)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference {
	return [L3AssertionFailureEvent eventWithAssertionReference:assertionReference];
}

-(L3AssertionSuccessEvent *)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference {
	return [L3AssertionSuccessEvent eventWithAssertionReference:assertionReference];
}

@end
