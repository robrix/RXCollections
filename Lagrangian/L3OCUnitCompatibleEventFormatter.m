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
#import "L3TestResult.h"

@interface L3OCUnitCompatibleEventFormatter () <L3EventAlgebra>

-(void)pushTestResultWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date;
-(void)pushTestResultWithTestCase:(L3TestCase *)testCase date:(NSDate *)date;
-(L3TestResult *)popTestResultWithDate:(NSDate *)date;
@property (strong, nonatomic) L3TestResult *currentTestResult;

-(NSString *)formatTestName:(NSString *)name;
-(NSString *)methodNameWithCurrentSuiteAndCase;

@end

@implementation L3OCUnitCompatibleEventFormatter

#pragma mark -
#pragma mark Formatting

@l3_suite("OCUnit-compatible event formatters");

static void dummyFunction(L3TestState *test, L3TestCase *_case);

-(NSString *)formatEvent:(L3Event *)event {
	return [event acceptAlgebra:self];
}

#pragma mark -
#pragma mark Event algebra

-(NSString *)testSuiteStartEventWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date {
	[self pushTestResultWithTestSuite:testSuite date:date];
	return [NSString stringWithFormat:@"Test Suite '%@' started at %@\n", [self formatTestName:testSuite.name], date];
}

-(NSString *)testSuiteEndEventWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date {
	[self popTestResultWithDate:date];
	return [NSString stringWithFormat:@"Test Suite '%@' finished at %@.\nExecuted %u tests, with %u failures (%u unexpected) in %.3f (%.3f) seconds\n", [self formatTestName:testSuite.name], date, 0u, 0u, 0u, 0.0f, 0.0f];
}


@l3_test("format test case started events compatibly with OCUnit") {
	NSString *string = [[L3OCUnitCompatibleEventFormatter new] formatEvent:[L3TestCaseStartEvent eventWithTestCase:_case date:nil]];
	l3_assert(string, l3_not(nil));
}

-(NSString *)testCaseStartEventWithTestCase:(L3TestCase *)testCase date:(NSDate *)date {
	self.currentTestResult.testCaseCount++;
	[self pushTestResultWithTestCase:testCase date:date];
	return [NSString stringWithFormat:@"Test Case '%@' started.", [self methodNameWithCurrentSuiteAndCase]];
}

@l3_test("format test case end events with ‘passed’ for cases without any assertion failures") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" function:dummyFunction];
	NSString *formattedResult = [[L3OCUnitCompatibleEventFormatter new] testCaseEndEventWithTestCase:testCase date:[NSDate date]];
	l3_assert([formattedResult rangeOfString:@"passed"].length > 0, l3_is(YES));
}

@l3_test("format test case end events with ‘failed’ for cases with assertion failures") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" function:dummyFunction];
	L3OCUnitCompatibleEventFormatter *formatter = [L3OCUnitCompatibleEventFormatter new];
	[formatter pushTestResultWithTestCase:testCase date:[NSDate date]];
	formatter.currentTestResult.assertionFailureCount += 1;
	NSString *formattedResult = [formatter testCaseEndEventWithTestCase:testCase date:[NSDate date]];
	l3_assert([formattedResult rangeOfString:@"failed"].length > 0, l3_is(YES));
}

@l3_test("format test case end events with the duration of the test") {
	NSDate *now = [NSDate date];
	NSDate *then = [NSDate dateWithTimeInterval:-10 sinceDate:now];
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" function:dummyFunction];
	L3OCUnitCompatibleEventFormatter *formatter = [L3OCUnitCompatibleEventFormatter new];
	[formatter pushTestResultWithTestCase:testCase date:then];
	NSString *formattedResult = [formatter testCaseEndEventWithTestCase:testCase date:now];
	l3_assert([formattedResult rangeOfString:@"(10.000 seconds)"].length > 0, @l3_is(YES));
}

-(NSString *)testCaseEndEventWithTestCase:(L3TestCase *)testCase date:(NSDate *)date {
	bool success = self.currentTestResult.assertionFailureCount == 0;
	NSTimeInterval duration = [date timeIntervalSinceDate:self.currentTestResult.startDate];
	NSString *formatted = [NSString stringWithFormat:@"Test Case '%@' %@ (%.3f seconds).\n", [self methodNameWithCurrentSuiteAndCase], success? @"passed" : @"failed", duration];
	[self popTestResultWithDate:date];
	return formatted;
}


@l3_test("format assertion failures with their file, line, source, actual value, and expectation") {
	L3AssertionReference *assertionReference = [L3AssertionReference assertionReferenceWithFile:@"/foo/bar/file.m" line:42 subjectSource:@"x" subject:@"y" patternSource:@"src"];
	NSString *string = [[L3OCUnitCompatibleEventFormatter new] assertionFailureWithAssertionReference:assertionReference date:nil];
	l3_assert(string, @"/foo/bar/file.m:42: error: 'x' was 'y' but should have matched 'src'");
}

-(NSString *)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	self.currentTestResult.assertionCount++;
	self.currentTestResult.assertionFailureCount++;
	return [NSString stringWithFormat:@"%@:%lu: error: '%@' was '%@' but should have matched '%@'", assertionReference.file, assertionReference.line, assertionReference.subjectSource, assertionReference.subject, assertionReference.patternSource];
}

@l3_test("do not format assertion successes") {
	NSString *string = [[L3OCUnitCompatibleEventFormatter new] formatEvent:[L3AssertionSuccessEvent eventWithAssertionReference:l3_assertionReference(@"a", @"a", @"b") date:nil]];
	l3_assert(string, l3_is(nil));
}

-(NSString *)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	self.currentTestResult.assertionCount++;
	return nil;
}


#pragma mark -
#pragma mark Test name formatting

@l3_test("format test names by replacing nonalphanumeric characters with underscores") {
	l3_assert([[L3OCUnitCompatibleEventFormatter new] formatTestName:@"foo bar's quux: herp?"], @"foo_bar_s_quux__herp_");
}

-(NSString *)formatTestName:(NSString *)name {
	NSMutableString *formatted = [name mutableCopy];
	NSRange range = {0};
	NSMutableCharacterSet *disallowed = [NSMutableCharacterSet new];
	[disallowed formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
	[disallowed removeCharactersInString:@"_"];
	while ((range = [formatted rangeOfCharacterFromSet:disallowed]).length > 0) {
		[formatted replaceCharactersInRange:range withString:@"_"];
	}
	return formatted;
}

@l3_test("format faux method names from suite and test case names") {
	L3OCUnitCompatibleEventFormatter *formatter = [L3OCUnitCompatibleEventFormatter new];
	L3TestResult *suiteResult = [L3TestResult testResultWithName:@"suite of tests!" startDate:[NSDate distantPast]];
	L3TestResult *caseResult = [L3TestResult testResultWithName:@"test of suites!" startDate:[NSDate date]];
	caseResult.parent = suiteResult;
	formatter.currentTestResult = caseResult;
	l3_assert([formatter methodNameWithCurrentSuiteAndCase], @"-[suite_of_tests_ test_of_suites_]");
}

-(NSString *)methodNameWithCurrentSuiteAndCase {
	return [NSString stringWithFormat:@"-[%@ %@]", [self formatTestName:self.currentTestResult.parent.name], [self formatTestName:self.currentTestResult.name]];
}


#pragma mark -
#pragma mark Test result stack

-(void)pushTestResultWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date {
	[self pushTestResult:[L3TestResult testResultWithName:testSuite.name startDate:date]];
}

-(void)pushTestResultWithTestCase:(L3TestCase *)testCase date:(NSDate *)date {
	[self pushTestResult:[L3TestResult testResultWithName:testCase.name startDate:date]];
}

-(void)pushTestResult:(L3TestResult *)testResult {
	testResult.parent = self.currentTestResult;
	self.currentTestResult = testResult;
}

-(L3TestResult *)popTestResultWithDate:(NSDate *)date {
	L3TestResult *result = self.currentTestResult;
	self.currentTestResult = result.parent;
	[result.parent addTestResult:result];
	result.parent = nil;
	return result;
}

@end

static void dummyFunction(L3TestState *test, L3TestCase *_case) {}
