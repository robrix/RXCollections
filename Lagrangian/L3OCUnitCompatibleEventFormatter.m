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

@property (strong, nonatomic, readonly) NSMutableArray *currentSuites;
-(void)pushSuite:(L3TestSuite *)suite;
-(L3TestSuite *)popSuite;
@property (strong, nonatomic, readonly) L3TestSuite *currentSuite;
@property (strong, nonatomic) L3TestCase *currentCase;


-(NSString *)formatTestName:(NSString *)name;
-(NSString *)methodNameWithCurrentSuiteAndCase;

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
	[self pushSuite:testSuite];
	return [NSString stringWithFormat:@"Test Suite '%@' started at %@\n", [self formatTestName:testSuite.name], date];
}

-(NSString *)testSuiteEndEventWithTestSuite:(L3TestSuite *)testSuite date:(NSDate *)date {
	[self popSuite];
	return [NSString stringWithFormat:@"Test Suite '%@' finished at %@.\nExecuted %u tests, with %u failures (%u unexpected) in %.3f (%.3f) seconds\n", [self formatTestName:testSuite.name], date, 0u, 0u, 0u, 0.0f, 0.0f];
}


@l3_test("format test case started events compatibly with OCUnit") {
	NSString *string = [[L3OCUnitCompatibleEventFormatter new] formatEvent:[L3TestCaseStartEvent eventWithTestCase:_case date:nil]];
	l3_assert(string, l3_not(nil));
}

-(NSString *)testCaseStartEventWithTestCase:(L3TestCase *)testCase date:(NSDate *)date {
	self.currentCase = testCase;
	return [NSString stringWithFormat:@"Test Case '%@' started.", [self methodNameWithCurrentSuiteAndCase]];
}

-(NSString *)testCaseEndEventWithTestCase:(L3TestCase *)testCase date:(NSDate *)date {
	NSString *formatted = [NSString stringWithFormat:@"Test Case '%@' %@ (%.3f seconds).\n", [self methodNameWithCurrentSuiteAndCase], @"passed", 0.0f];
	self.currentCase = nil;
	return formatted;
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


#pragma mark -
#pragma mark Constructors

-(instancetype)init {
	if ((self = [super init])) {
		_currentSuites = [NSMutableArray new];
	}
	return self;
}


#pragma mark -
#pragma mark Test name formatting

@l3_test("formats test names by replacing nonalphanumeric characters with underscores") {
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

static void dummyFunction(L3TestState *test, L3TestCase *_case) {}

@l3_test("formats faux method names from suite and test case names") {
	L3OCUnitCompatibleEventFormatter *formatter = [L3OCUnitCompatibleEventFormatter new];
	[formatter pushSuite:[L3TestSuite testSuiteWithName:@"suite of tests!"]];
	formatter.currentCase = [L3TestCase testCaseWithName:@"test of suites!" function:dummyFunction];
	l3_assert([formatter methodNameWithCurrentSuiteAndCase], @"-[suite_of_tests_ test_of_suites_]");
}

-(NSString *)methodNameWithCurrentSuiteAndCase {
	return [NSString stringWithFormat:@"-[%@ %@]", [self formatTestName:self.currentSuite.name], [self formatTestName:self.currentCase.name]];
}


#pragma mark -
#pragma mark Suite stack

-(void)pushSuite:(L3TestSuite *)suite {
	[self.currentSuites addObject:suite];
}

-(L3TestSuite *)popSuite {
	L3TestSuite *suite = self.currentSuite;
	[self.currentSuites removeLastObject];
	return suite;
}

-(L3TestSuite *)currentSuite {
	return self.currentSuites.lastObject;
}

@end
