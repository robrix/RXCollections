//  L3TestCase.m
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3SourceReference.h"
#import "L3TestCase.h"
#import "L3TestState.h"
#import "L3TestSuite.h"
#import "Lagrangian.h"

@l3_suite_interface(L3TestCase, "Test cases") <L3EventObserver>

@property NSMutableArray *events;

@end

@l3_set_up {
	test.events = [NSMutableArray new];
}


@interface L3TestCase ()

@property (copy, nonatomic, readwrite) NSString *name;

@property (copy, nonatomic, readwrite) NSString *file;
@property (assign, nonatomic, readwrite) NSUInteger line;

@property (weak, nonatomic, readwrite) id<L3EventObserver> eventObserver;

@property (assign, nonatomic, readwrite) NSUInteger failedAssertionCount;

@end

@implementation L3TestCase

static void test_function(L3TestState *state, L3TestCase *testCase) {}

#pragma mark -
#pragma mark Constructors

@l3_test("correlate names with functions") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"test case name" file:@"" __FILE__ line:__LINE__ function:test_function];
	l3_assert(testCase.name, l3_equalTo(@"test case name"));
	__typeof__(nil) object = nil;
	l3_assert(testCase.function, l3_not(object));
}

+(instancetype)testCaseWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line function:(L3TestCaseFunction)function {
	return [[self alloc] initWithName:name file:file line:line function:function];
}

-(instancetype)initWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line function:(L3TestCaseFunction)function {
	NSParameterAssert(name != nil);
	NSParameterAssert(function != nil);
	if((self = [super init])) {
		_name = [name copy];
		_file = [file copy];
		_line = line;
		_function = function;
	}
	return self;
}


#pragma mark -
#pragma mark Steps

-(bool)performStep:(L3TestStep *)step withState:(L3TestState *)state {
	NSParameterAssert(step != nil);
	NSParameterAssert(state != nil);
	
	NSUInteger previousFailedAssertionCount = self.failedAssertionCount;
	
	step.function(state, self, step);
	
	return previousFailedAssertionCount == self.failedAssertionCount;
}


#pragma mark -
#pragma mark L3Test

@l3_test("generate test start events when starting to run") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" file:@"" __FILE__ line:__LINE__ function:test_function];
	[testCase runInSuite:nil eventObserver:test];
	
	if (l3_assert(test.events.count, l3_greaterThanOrEqualTo(1u))) {
		NSDictionary *event = test.events[0];
		l3_assert(event[@"name"], l3_equals(@"name"));
		l3_assert(event[@"type"], l3_equals(@"start"));
	}
}

@l3_test("generate test end events when done running") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" file:@"" __FILE__ line:__LINE__ function:test_function];
	[testCase runInSuite:nil eventObserver:test];
	l3_assert(test.events.count, l3_greaterThanOrEqualTo(1u));
	NSDictionary *event = test.events.lastObject;
	l3_assert(event[@"name"], l3_equals(@"name"));
	l3_assert(event[@"type"], l3_equals(@"end"));
}

static void asynchronousTest(L3TestState *test, L3TestCase *_case);
static void asynchronousTest(L3TestState *test, L3TestCase *_case) {
	test.timeout = 0;
	l3_defer();
}

@l3_test("generate failures when asynchronous tests time out") {
	L3TestSuite *suite = [L3TestSuite testSuiteWithName:@"suite"];
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"case" file:@"file.m" line:42 function:asynchronousTest];
	[testCase runInSuite:suite eventObserver:test];
	NSDictionary *event = test.events[test.events.count - 2];
	l3_assert(event[@"type"], l3_equals(@"failure"));
	l3_assert([event[@"sourceReference"] subject], l3_equals(testCase));
}

-(void)runInSuite:(L3TestSuite *)suite eventObserver:(id<L3EventObserver>)eventObserver {
	L3TestState *state = [[suite.stateClass alloc] initWithSuite:suite];
	self.eventObserver = eventObserver;
	
	[eventObserver testStartEventWithTest:self date:[NSDate date]];
	
	L3TestStep *setUp = suite.steps[L3TestSuiteSetUpStepName];
	if (setUp)
		[self performStep:setUp withState:state];
	
	self.function(state, self);
	
	if (state.isDeferred)
	{
		[self assertThat:l3_to_object([state wait]) matches:l3_to_pattern(YES) sourceReference:[self sourceReferenceForCaseEvents] eventObserver:eventObserver];
	}
	
	L3TestStep *tearDown = suite.steps[L3TestSuiteTearDownStepName];
	if (tearDown)
		[self performStep:tearDown withState:state];
	
	[eventObserver testEndEventWithTest:self date:[NSDate date]];
	
	self.eventObserver = nil;
}


-(bool)isComposite {
	return NO;
}


#pragma mark -
#pragma mark Assertions

@l3_test("create source references for events applying to the case as a whole") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"test case" file:@"file.m" line:42 function:test_function];
	L3SourceReference *reference = [testCase sourceReferenceForCaseEvents];
	l3_assert(reference.file, l3_equals(@"file.m"));
	l3_assert(reference.line, l3_equals(42));
	l3_assert(reference.subject, l3_equals(testCase));
	l3_assert(reference.subjectSource, l3_equals(@"test case"));
	l3_assert(reference.patternSource, l3_equals(nil));
}

-(L3SourceReference *)sourceReferenceForCaseEvents {
	return [L3SourceReference referenceWithFile:self.file line:self.line subjectSource:self.name subject:self patternSource:nil];
}


@l3_test("return true for passing assertions") {
	bool matched = [_case assertThat:@"a" matches:^bool(id obj) { return YES; } sourceReference:l3_sourceReference(@"a", @"a", @".") eventObserver:nil];
	l3_assert(matched, l3_is(YES));
}

@l3_test("return false for failing assertions") {
	bool matched = [_case assertThat:@"a" matches:^bool(id obj){ return NO; } sourceReference:l3_sourceReference(@"a", @"a", @"!") eventObserver:nil];
	l3_assert(matched, l3_is(NO));
}

@l3_test("generate assertion succeeded events for successful assertions") {
	L3SourceReference *sourceReference = l3_sourceReference(@"a", @"a", @".");
	[_case assertThat:@"a" matches:^bool(id x) { return YES; } sourceReference:sourceReference eventObserver:test];
	
	l3_assert(test.events.lastObject[@"sourceReference"], l3_equals(sourceReference));
}

@l3_test("generate assertion failed events for failed assertions") {
	L3SourceReference *sourceReference = l3_sourceReference(@"a", @"a", @"!");
	[_case assertThat:@"a" matches:^bool(id x) { return NO; } sourceReference:sourceReference eventObserver:test];
	
	l3_assert(test.events.lastObject[@"sourceReference"], l3_equals(sourceReference));
}

-(bool)assertThat:(id)object matches:(L3Pattern)pattern sourceReference:(L3SourceReference *)sourceReference eventObserver:(id<L3EventObserver>)eventObserver {
	// fixme: assertion start event
	bool matched = pattern(object);
	if (matched)
		[eventObserver assertionSuccessWithSourceReference:sourceReference date:[NSDate date]];
	else
		[eventObserver assertionFailureWithSourceReference:sourceReference date:[NSDate date]];
	
	self.failedAssertionCount += !matched;
	return matched;
}

@end


@l3_suite_implementation (L3TestCase)

-(void)testStartEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	[self.events addObject:@{ @"name": test.name, @"date": date, @"type": @"start" }];
}

-(void)testEndEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	[self.events addObject:@{ @"name": test.name, @"date": date, @"type": @"end" }];
}

-(void)assertionSuccessWithSourceReference:(L3SourceReference *)sourceReference date:(NSDate *)date {
	[self.events addObject:@{ @"sourceReference": sourceReference, @"date": date, @"type": @"success" }];
}

-(void)assertionFailureWithSourceReference:(L3SourceReference *)sourceReference date:(NSDate *)date {
	[self.events addObject:@{ @"sourceReference": sourceReference, @"date": date, @"type": @"failure" }];
}

@end
