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

-(L3TestSuiteStartEvent *)testSuiteStartEventWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date {
	return [L3TestSuiteStartEvent eventWithTestSuite:testSuite date:date];
}

-(L3TestSuiteEndEvent *)testSuiteEndEventWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date {
	return [L3TestSuiteEndEvent eventWithTestSuite:testSuite date:date];
}


-(L3TestCaseStartEvent *)testCaseStartEventWithTestCase:(L3TestCase *)testCase date:(NSDate *)date {
	return [L3TestCaseStartEvent eventWithTestCase:testCase date:date];
}

-(L3TestCaseEndEvent *)testCaseEndEventWithTestCase:(L3TestCase *)testCase date:(NSDate *)date {
	return [L3TestCaseEndEvent eventWithTestCase:testCase date:date];
}


-(L3AssertionFailureEvent *)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	return [L3AssertionFailureEvent eventWithAssertionReference:assertionReference date:date];
}

-(L3AssertionSuccessEvent *)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	return [L3AssertionSuccessEvent eventWithAssertionReference:assertionReference date:date];
}

@end
