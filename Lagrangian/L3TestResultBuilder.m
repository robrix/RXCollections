//  L3TestResultBuilder.m
//  Created by Rob Rix on 2012-11-13.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3FunctionalUtilities.h"
#import "L3Stack.h"
#import "L3TestResult.h"
#import "L3TestResultBuilder.h"
#import "L3TestSuite.h"
#import "Lagrangian.h"

@interface L3TestResultBuilder ()

@property (strong, nonatomic, readonly) L3Stack *testResultStack;
@property (nonatomic, readonly) L3TestResult *currentTestResult;

@end

@l3_suite("Test result builders", L3TestResultBuilder) <L3Test, L3TestResultBuilderDelegate>

@property L3TestResultBuilder *builder;
@property L3AssertionReference *assertionReference;
@property L3TestResult *builtResult;
@property L3AssertionReference *builtAssertionReference;

@property (copy, nonatomic, readwrite) NSString *name;

@property (nonatomic, readwrite, getter = isComposite) bool composite;

@end

@implementation L3TestResultBuilder

@l3_set_up {
	test.builder = [L3TestResultBuilder new];
	test.builder.delegate = test;
	test.name = _case.name;
	test.assertionReference = l3_assertionReference(@"subject", @"subjectSource", @"patternSource");
}


#pragma mark -
#pragma mark Constructors

@l3_test("are initialized with an empty stack") {
	l3_assert([test.builder testResultStack].objects, l3_equals(@[]));
}

-(instancetype)init {
	if ((self = [super init])) {
		_testResultStack = [L3Stack new];
	}
	return self;
}


#pragma mark -
#pragma mark Event algebra

#pragma mark -
#pragma mark Test events

@l3_test("push a result when starting tests") {
	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-10];
	[test.builder testStartEventWithTest:test date:date];
	L3TestResult *testResult = [test.builder testResultStack].topObject;
	
	l3_assert(testResult.name, l3_equals(_case.name));
	l3_assert(testResult.startDate, l3_equals(date));
}

@l3_test("notify their delegates when starting tests") {
	[test.builder testStartEventWithTest:test date:[NSDate date]];
	
	l3_assert(test.builtResult.name, l3_equals(_case.name));
}

@l3_test("set new test results’ parent relationships when pushing them") {
	[test.builder testStartEventWithTest:test date:[NSDate date]];
	[test.builder testStartEventWithTest:test date:[NSDate date]];
	
	l3_assert(test.builder.currentTestResult.parent, l3_equals(test.builder.testResultStack.objects[0]));
}

-(void)testStartEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	L3TestResult *testResult = [(test.isComposite? [L3CompositeTestResult class] : [L3TestResult class]) testResultWithName:test.name startDate:date];
	testResult.parent = self.currentTestResult;
	[self.testResultStack pushObject:testResult];
	[self.delegate testResultBuilder:self testResultDidStart:testResult];
}


@l3_test("pop a result when ending tests") {
	L3TestResult *testResult = [L3TestResult testResultWithName:_case.name startDate:[NSDate dateWithTimeIntervalSinceNow:-10]];
	[[test.builder testResultStack] pushObject:testResult];
	L3TestSuite *suite = [L3TestSuite testSuiteWithName:_case.name];
	[test.builder testEndEventWithTest:suite date:[NSDate date]];
	l3_assert([test.builder testResultStack].objects, l3_equals(@[]));
}

@l3_test("set returned results’ end dates when ending tests") {
	NSDate *now = [NSDate date];
	[test.builder.testResultStack pushObject:[L3TestResult testResultWithName:_case.name startDate:[NSDate dateWithTimeInterval:-10 sinceDate:now]]];
	L3TestResult *testResult = test.builder.testResultStack.topObject;
	[test.builder testEndEventWithTest:test date:now];
	l3_assert(testResult.endDate, l3_equals(now));
}

@l3_test("notify their delegates when ending tests") {
	L3TestResult *testResult = [L3TestResult testResultWithName:_case.name startDate:[NSDate dateWithTimeInterval:-10 sinceDate:[NSDate date]]];
	[test.builder.testResultStack pushObject:testResult];
	[test.builder testEndEventWithTest:_case date:[NSDate date]];
	l3_assert(test.builtResult, l3_equals(testResult));
}

-(void)testEndEventWithTest:(L3TestSuite *)testSuite date:(NSDate *)date {
	L3TestResult *testResult = [self.testResultStack popObject];
	testResult.endDate = date;
	[self.currentTestResult addTestResult:testResult];
	[self.delegate testResultBuilder:self testResultDidFinish:testResult];
}


#pragma mark -
#pragma mark Assertion events

@l3_test("notify their delegates of result changes when assertions succeed") {
	[test.builder assertionSuccessWithAssertionReference:test.assertionReference date:[NSDate date]];
	
	l3_assert(test.builtAssertionReference, l3_equals(test.assertionReference));
}

@l3_test("increment the current test result’s assertion count when assertions succeed") {
	[test.builder.testResultStack pushObject:[L3TestResult testResultWithName:_case.name startDate:[NSDate date]]];
	[test.builder assertionSuccessWithAssertionReference:test.assertionReference date:[NSDate date]];
	
	l3_assert(test.builtResult.assertionCount, l3_equals(1));
}

-(void)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	self.currentTestResult.assertionCount += 1;
	
	[self.delegate testResultBuilder:self testResult:self.currentTestResult didChangeWithSuccessfulAssertionReference:assertionReference];
}

@l3_test("notify their delegates of result changes when assertions fail") {
	[test.builder assertionFailureWithAssertionReference:test.assertionReference date:[NSDate date]];
	
	l3_assert(test.builtAssertionReference, l3_equals(test.assertionReference));
}

@l3_test("increment the current test result’s assertion count when assertions fail") {
	[test.builder.testResultStack pushObject:[L3TestResult testResultWithName:_case.name startDate:[NSDate date]]];
	[test.builder assertionFailureWithAssertionReference:test.assertionReference date:[NSDate date]];
	
	l3_assert(test.builtResult.assertionCount, l3_equals(1));
}

@l3_test("increment the current test result’s assertion failure count when assertions fail") {
	[test.builder.testResultStack pushObject:[L3TestResult testResultWithName:_case.name startDate:[NSDate date]]];
	[test.builder assertionFailureWithAssertionReference:test.assertionReference date:[NSDate date]];
	
	l3_assert(test.builtResult.assertionFailureCount, l3_equals(1));
}

-(void)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	self.currentTestResult.assertionCount += 1;
	self.currentTestResult.assertionFailureCount += 1;
	
	[self.delegate testResultBuilder:self testResult:self.currentTestResult didChangeWithFailedAssertionReference:assertionReference];
}


#pragma mark -
#pragma mark Current results

-(L3TestResult *)currentTestResult {
	return self.testResultStack.topObject;
}

@end

@l3_suite_implementation(L3TestResultBuilder)

-(void)runInContext:(id<L3TestContext>)context eventObserver:(id<L3EventObserver>)eventObserver {}


-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidStart:(L3TestResult *)result {
	self.builtResult = result;
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result didChangeWithSuccessfulAssertionReference:(L3AssertionReference *)assertionReference {
	self.builtResult = result;
	self.builtAssertionReference = assertionReference;
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result didChangeWithFailedAssertionReference:(L3AssertionReference *)assertionReference {
	self.builtResult = result;
	self.builtAssertionReference = assertionReference;
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidFinish:(L3TestResult *)result {
	self.builtResult = result;
}

@end
