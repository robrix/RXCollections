//  L3TestCase.m
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestState.h"
#import "L3TestSuite.h"
#import "Lagrangian.h"

@l3_suite("Test cases", L3TestCase) <L3EventObserver>

@property NSMutableArray *events;

@end

@l3_set_up {
	test.events = [NSMutableArray new];
}


@interface L3TestCase ()

@property (copy, nonatomic, readwrite) NSString *name;

@property (weak, nonatomic, readwrite) id<L3EventObserver> eventObserver;

@end

@implementation L3TestCase

static void test_function(L3TestState *state, L3TestCase *testCase) {}

#pragma mark -
#pragma mark Constructors

@l3_test("correlate names with functions") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"test case name" function:test_function];
	l3_assert(testCase.name, l3_equalTo(@"test case name"));
	__typeof__(nil) object = nil;
	l3_assert(testCase.function, l3_not(object));
}

+(instancetype)testCaseWithName:(NSString *)name function:(L3TestCaseFunction)function {
	return [[self alloc] initWithName:name function:function];
}

-(instancetype)initWithName:(NSString *)name function:(L3TestCaseFunction)function {
	NSParameterAssert(name != nil);
	NSParameterAssert(function != nil);
	if((self = [super init])) {
		_name = [name copy];
		_function = function;
	}
	return self;
}


#pragma mark -
#pragma mark L3Test

@l3_test("generate test start events when starting to run") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" function:test_function];
	[testCase runInSuite:nil eventObserver:test];
	
	if (l3_assert(test.events.count, l3_greaterThanOrEqualTo(1u))) {
		NSDictionary *event = test.events[0];
		l3_assert(event[@"name"], l3_equals(@"name"));
		l3_assert(event[@"type"], l3_equals(@"start"));
	}
}

@l3_test("generate test end events when done running") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" function:test_function];
	[testCase runInSuite:nil eventObserver:test];
	l3_assert(test.events.count, l3_greaterThanOrEqualTo(1u));
	NSDictionary *event = test.events.lastObject;
	l3_assert(event[@"name"], l3_equals(@"name"));
	l3_assert(event[@"type"], l3_equals(@"end"));
}

-(void)runInSuite:(L3TestSuite *)suite eventObserver:(id<L3EventObserver>)eventObserver {
	L3TestState *state = [suite.stateClass new];
	self.eventObserver = eventObserver;
	
	[eventObserver testStartEventWithTest:self date:[NSDate date]];
	
	if (suite.setUpFunction)
		suite.setUpFunction(state, self);
	
	self.function(state, self);
	
	// fixme: signal a failure at the test line if timeout occurs
	if (state.isDeferred)
		[state wait];
	
	if (suite.tearDownFunction)
		suite.tearDownFunction(state, self);
	
	[eventObserver testEndEventWithTest:self date:[NSDate date]];
	
	self.eventObserver = nil;
}


-(bool)isComposite {
	return NO;
}


#pragma mark -
#pragma mark Assertions

@l3_test("return true for passing assertions") {
	bool matched = [_case assertThat:@"a" matches:^bool(id obj) { return YES; } assertionReference:l3_assertionReference(@"a", @"a", @".") eventObserver:nil];
	l3_assert(matched, l3_is(YES));
}

@l3_test("return false for failing assertions") {
	bool matched = [_case assertThat:@"a" matches:^bool(id obj){ return NO; } assertionReference:l3_assertionReference(@"a", @"a", @"!") eventObserver:nil];
	l3_assert(matched, l3_is(NO));
}

@l3_test("generate assertion succeeded events for successful assertions") {
	L3AssertionReference *assertionReference = l3_assertionReference(@"a", @"a", @".");
	[_case assertThat:@"a" matches:^bool(id x) { return YES; } assertionReference:assertionReference eventObserver:test];
	
	l3_assert(test.events.lastObject[@"assertionReference"], l3_equals(assertionReference));
}

@l3_test("generate assertion failed events for failed assertions") {
	L3AssertionReference *assertionReference = l3_assertionReference(@"a", @"a", @"!");
	[_case assertThat:@"a" matches:^bool(id x) { return NO; } assertionReference:assertionReference eventObserver:test];
	
	l3_assert(test.events.lastObject[@"assertionReference"], l3_equals(assertionReference));
}

-(bool)assertThat:(id)object matches:(L3Pattern)pattern assertionReference:(L3AssertionReference *)assertionReference eventObserver:(id<L3EventObserver>)eventObserver {
	// fixme: assertion start event
	bool matched = pattern(object);
	if (matched)
		[eventObserver assertionSuccessWithAssertionReference:assertionReference date:[NSDate date]];
	else
		[eventObserver assertionFailureWithAssertionReference:assertionReference date:[NSDate date]];
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

-(void)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	[self.events addObject:@{ @"assertionReference": assertionReference, @"date": date, @"type": @"success" }];
}

-(void)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	[self.events addObject:@{ @"assertionReference": assertionReference, @"date": date, @"type": @"success" }];
}

@end
