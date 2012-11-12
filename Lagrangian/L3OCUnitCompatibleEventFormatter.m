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

@interface L3OCUnitCompatibleEventFormatter () <L3EventAlgebra>
@end

@implementation L3OCUnitCompatibleEventFormatter

#pragma mark -
#pragma mark Formatting

@l3_suite("OCUnit-compatible event formatters");

-(NSString *)formatEvent:(L3Event *)event {
	return [event acceptAlgebra:self];
}


#pragma mark -
#pragma mark Event algebra

-(NSString *)testSuiteStartEventWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date {
	return [NSString stringWithFormat:@"Test Suite '%@' started at %@\n", testSuite.name, date];
}

-(NSString *)testSuiteEndEventWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date {
	return [NSString stringWithFormat:@"Test Suite '%@' finished at %@.\nExecuted %u tests, with %u failures (%u unexpected) in %.3f (%.3f) seconds\n", testSuite.name, date, 0u, 0u, 0u, 0.0f, 0.0f];
}


@l3_test("format test case started events compatibly with OCUnit") {
	NSString *string = [[L3OCUnitCompatibleEventFormatter new] formatEvent:[L3TestCaseStartEvent eventWithTestCase:_case date:nil]];
	l3_assert(string, l3_not(nil));
}

-(NSString *)testCaseStartEventWithTestCase:(L3TestCase *)testCase date:(NSDate *)date {
	return [NSString stringWithFormat:@"Test Case '-[%@]' started.", testCase.name];
}

-(NSString *)testCaseEndEventWithTestCase:(L3TestCase *)testCase date:(NSDate *)date {
	return [NSString stringWithFormat:@"Test Case '-[%@]' %@ (%.3f seconds).\n", testCase.name, @"passed", 0.0f];
}


@l3_test("formats assertion failures with their file, line, source, actual value, and expectation") {
	L3AssertionReference *assertionReference = [L3AssertionReference assertionReferenceWithFile:@"/foo/bar/file.m" line:42 subjectSource:@"x" subject:@"y" patternSource:@"src"];
	NSString *string = [[L3OCUnitCompatibleEventFormatter new] assertionFailureWithAssertionReference:assertionReference date:nil];
	l3_assert(string, @"/foo/bar/file.m:42: error: 'x' was 'y' but should have matched 'src'");
}

-(NSString *)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	return [NSString stringWithFormat:@"%@:%lu: error: '%@' was '%@' but should have matched '%@'", assertionReference.file, assertionReference.line, assertionReference.subjectSource, assertionReference.subject, assertionReference.patternSource];
}

@l3_test("does not format assertion successes") {
	NSString *string = [[L3OCUnitCompatibleEventFormatter new] formatEvent:[L3AssertionSuccessEvent eventWithAssertionReference:l3_assertionReference(@"a", @"a", @"b") date:nil]];
	l3_assert(string, l3_is(nil));
}

-(NSString *)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	return nil;
}

@end
