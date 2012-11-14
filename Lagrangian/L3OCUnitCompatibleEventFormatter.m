//  L3OCUnitCompatibleEventFormatter.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3OCUnitCompatibleEventFormatter.h"
#import "Lagrangian.h"
#import "L3TestResult.h"

@interface L3OCUnitCompatibleEventFormatter ()

-(void)pushTestResultWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date;
-(void)pushTestResultWithTestCase:(L3TestCase *)testCase date:(NSDate *)date;
-(L3TestResult *)popTestResultWithDate:(NSDate *)date;
@property (strong, nonatomic) L3TestResult *currentTestResult;

-(NSString *)formatTestName:(NSString *)name;
-(NSString *)methodNameWithCurrentSuiteAndCase;
-(NSString *)pluralizeNoun:(NSString *)noun count:(NSUInteger)count;
-(NSString *)cardinalizeNoun:(NSString *)noun count:(NSUInteger)count;

@end

@implementation L3OCUnitCompatibleEventFormatter

@synthesize delegate = _delegate;

@l3_suite("OCUnit-compatible event formatters");

@l3_set_up {
	test[@"formatter"] = [L3OCUnitCompatibleEventFormatter new];
}

static void dummyFunction(L3TestState *test, L3TestCase *_case);


#pragma mark -
#pragma mark Event algebra

#pragma mark -
#pragma mark Test events

-(NSString *)testStartEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	NSString *formatted = nil;
	[self pushTestResultWithTestSuite:test date:date];
	if (test.isComposite) {
		formatted = [NSString stringWithFormat:@"Test Suite '%@' started at %@\n", [self formatTestName:test.name], date];
	} else {
		self.currentTestResult.testCaseCount++;
		formatted = [NSString stringWithFormat:@"Test Case '%@' started.", [self methodNameWithCurrentSuiteAndCase]];
	}
	[self.delegate formatter:self didFormatEventWithResultString:formatted];
	return formatted;
}

@l3_test("format test suite end events with the sums of the test cases, failures, and durations they encompassed") {
	NSDate *now = [NSDate date];
	NSDate *then = [NSDate dateWithTimeInterval:-10 sinceDate:now];
	L3OCUnitCompatibleEventFormatter *formatter = [L3OCUnitCompatibleEventFormatter new];
	L3TestSuite *suite = [L3TestSuite testSuiteWithName:@"suite"];
	[formatter pushTestResultWithTestSuite:suite date:then];
	L3TestResult *currentTestResult = formatter.currentTestResult;
	currentTestResult.assertionFailureCount = 3;
	currentTestResult.duration = 5;
	currentTestResult.testCaseCount = 2;
	NSString *formatted = [formatter testEndEventWithTest:suite date:now];
	l3_assert([formatted rangeOfString:@"Executed 2 tests, with 3 failures (0 unexpected) in 5.000 (10.000) seconds"].length > 0, l3_is(YES));
}

@l3_test("format test case end events with ‘passed’ for cases without any assertion failures") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" function:dummyFunction];
	NSString *formattedResult = [[L3OCUnitCompatibleEventFormatter new] testEndEventWithTest:testCase date:[NSDate date]];
	l3_assert([formattedResult rangeOfString:@"passed"].length > 0, l3_is(YES));
}

@l3_test("format test case end events with ‘failed’ for cases with assertion failures") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" function:dummyFunction];
	L3OCUnitCompatibleEventFormatter *formatter = [L3OCUnitCompatibleEventFormatter new];
	[formatter pushTestResultWithTestCase:testCase date:[NSDate date]];
	formatter.currentTestResult.assertionFailureCount += 1;
	NSString *formattedResult = [formatter testEndEventWithTest:testCase date:[NSDate date]];
	l3_assert([formattedResult rangeOfString:@"failed"].length > 0, l3_is(YES));
}

@l3_test("format test case end events with the duration of the test") {
	NSDate *now = [NSDate date];
	NSDate *then = [NSDate dateWithTimeInterval:-10 sinceDate:now];
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" function:dummyFunction];
	L3OCUnitCompatibleEventFormatter *formatter = [L3OCUnitCompatibleEventFormatter new];
	[formatter pushTestResultWithTestCase:testCase date:then];
	NSString *formattedResult = [formatter testEndEventWithTest:testCase date:now];
	l3_assert([formattedResult rangeOfString:@"(10.000 seconds)"].length > 0, @l3_is(YES));
}

-(NSString *)testEndEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	NSString *formatted = nil;
	L3TestResult *testResult = self.currentTestResult;
	if (test.isComposite) {
		formatted = [NSString stringWithFormat:@"Test Suite '%@' finished at %@.\nExecuted %@, with %@ (%lu unexpected) in %.3f (%.3f) seconds\n",
					 [self formatTestName:test.name],
					 date,
					 [self cardinalizeNoun:@"test" count:testResult.testCaseCount],
					 [self cardinalizeNoun:@"failure" count:testResult.assertionFailureCount],
					 testResult.exceptionCount,
					 testResult.duration,
					 [date timeIntervalSinceDate:testResult.startDate]];
	} else {
		bool success = self.currentTestResult.assertionFailureCount == 0;
		NSTimeInterval duration = [date timeIntervalSinceDate:self.currentTestResult.startDate];
		formatted = [NSString stringWithFormat:@"Test Case '%@' %@ (%.3f seconds).\n", [self methodNameWithCurrentSuiteAndCase], success? @"passed" : @"failed", duration];
	}
	[self popTestResultWithDate:date];
	[self.delegate formatter:self didFormatEventWithResultString:formatted];
	return formatted;
}


#pragma mark -
#pragma mark Assertion events

@l3_test("format assertion failures with their file, line, source, actual value, and expectation") {
	L3AssertionReference *assertionReference = [L3AssertionReference assertionReferenceWithFile:@"/foo/bar/file.m" line:42 subjectSource:@"x" subject:@"y" patternSource:@"src"];
	NSString *string = [[L3OCUnitCompatibleEventFormatter new] assertionFailureWithAssertionReference:assertionReference date:nil];
	l3_assert(string, @"/foo/bar/file.m:42: error: 'x' was 'y' but should have matched 'src'");
}

-(NSString *)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	self.currentTestResult.assertionCount++;
	self.currentTestResult.assertionFailureCount++;
	NSString *formatted = [NSString stringWithFormat:@"%@:%lu: error: '%@' was '%@' but should have matched '%@'", assertionReference.file, assertionReference.line, assertionReference.subjectSource, assertionReference.subject, assertionReference.patternSource];
	[self.delegate formatter:self didFormatEventWithResultString:formatted];
	return formatted;
}

@l3_test("do not format assertion successes") {
	NSString *string = [test[@"formatter"] assertionSuccessWithAssertionReference:l3_assertionReference(@"a", @"a", @"b") date:nil];
	l3_assert(string, l3_is(nil));
}

-(NSString *)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	self.currentTestResult.assertionCount++;
	return nil;
}


#pragma mark -
#pragma mark String formatting

@l3_test("format test names by replacing nonalphanumeric characters with underscores") {
	l3_assert([test[@"formatter"] formatTestName:@"foo bar's quux: herp?"], @"foo_bar_s_quux__herp_");
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
	L3TestResult *suiteResult = [L3TestResult testResultWithName:@"suite of tests!" startDate:[NSDate distantPast]];
	L3TestResult *caseResult = [L3TestResult testResultWithName:@"test of suites!" startDate:[NSDate date]];
	caseResult.parent = suiteResult;
	[test[@"formatter"] setCurrentTestResult:caseResult];
	l3_assert([test[@"formatter"] methodNameWithCurrentSuiteAndCase], @"-[suite_of_tests_ test_of_suites_]");
}

-(NSString *)methodNameWithCurrentSuiteAndCase {
	return [NSString stringWithFormat:@"-[%@ %@]", [self formatTestName:self.currentTestResult.parent.name], [self formatTestName:self.currentTestResult.name]];
}


@l3_test("pluralize nouns when their cardinality is 0") {
	l3_assert([test[@"formatter"] pluralizeNoun:@"dog" count:0], l3_is(@"dogs"));
}

@l3_test("do not pluralize nouns when their cardinality is 1") {
	l3_assert([test[@"formatter"] pluralizeNoun:@"cat" count:1], l3_is(@"cat"));
}

@l3_test("pluralize nouns when their cardinality is 2 or greater") {
	l3_assert([test[@"formatter"] pluralizeNoun:@"bird" count:2], l3_is(@"birds"));
}

-(NSString *)pluralizeNoun:(NSString *)noun count:(NSUInteger)count {
	return count == 1?
		noun
	:	[noun stringByAppendingString:@"s"];
}


@l3_test("cardinalize nouns with their plurals when cardinality is not 1") {
	l3_assert([test[@"formatter"] cardinalizeNoun:@"plural" count:0], @"0 plurals");
	l3_assert([test[@"formatter"] cardinalizeNoun:@"cardinal" count:1], @"1 cardinal");
	l3_assert([test[@"formatter"] cardinalizeNoun:@"ordinal" count:2], @"2 ordinals");
}

-(NSString *)cardinalizeNoun:(NSString *)noun count:(NSUInteger)count {
	return [NSString stringWithFormat:@"%lu %@", count, [self pluralizeNoun:noun count:count]];
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
	if (!result.parent)
		[self.delegate formatter:self didFinishFormattingEventsWithFinalTestResult:result];
	result.parent = nil;
	return result;
}

@end

static void dummyFunction(L3TestState *test, L3TestCase *_case) {}
