//  L3OCUnitCompatibleEventFormatter.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3OCUnitCompatibleEventFormatter.h"
#import "L3Event.h"
#import "Lagrangian.h"
#import "L3TestSuiteStartEvent.h"
#import "L3TestSuiteEndEvent.h"
#import "L3TestCaseStartEvent.h"
#import "L3TestCaseEndEvent.h"
#import "L3AssertionFailureEvent.h"
#import "L3AssertionSuccessEvent.h"

@interface L3OCUnitCompatibleEventFormatter () <L3EventVisitor>
@end

@implementation L3OCUnitCompatibleEventFormatter

@l3_suite("OCUnit-compatible event formatters");

-(NSString *)formatEvent:(L3Event *)event {
	return [event acceptVisitor:self];
}


-(NSString *)testSuiteStartEvent:(L3TestSuiteStartEvent *)event {
	return [NSString stringWithFormat:@"Test Suite '%@' started at %@\n", event.testSuite.name, event.date];
}

-(NSString *)testSuiteEndEvent:(L3TestSuiteEndEvent *)event {
	return [NSString stringWithFormat:@"Test Suite '%@' finished at %@.\nExecuted %u tests, with %u failures (%u unexpected) in %.3f (%.3f) seconds\n", event.testSuite.name, event.date, 0u, 0u, 0u, 0.0f, 0.0f];
}


@l3_test("format test case started events compatibly with OCUnit") {
	NSString *string = [[L3OCUnitCompatibleEventFormatter new] formatEvent:[L3TestCaseStartEvent eventWithTestCase:_case]];
	l3_assert(string, l3_not(nil));
}

-(NSString *)testCaseStartEvent:(L3TestCaseStartEvent *)event {
	return [NSString stringWithFormat:@"Test Case '-[%@]' started.", event.testCase.name];
}

-(NSString *)testCaseEndEvent:(L3TestCaseEndEvent *)event {
	return [NSString stringWithFormat:@"Test Case '-[%@]' %@ (%.3f seconds).\n", event.testCase.name, @"passed", 0.0f];
}


-(NSString *)assertionFailureEvent:(L3AssertionFailureEvent *)event {
	return @"failure!";
}

-(NSString *)assertionSuccessEvent:(L3AssertionSuccessEvent *)event {
	return nil;
}

@end
