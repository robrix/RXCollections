//  L3TestCase.m
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestState.h"
#import "L3TestSuite.h"
#import "L3Event.h"
#import "L3EventSink.h"
#import "Lagrangian.h"

@interface L3TestCase ()

@property (copy, nonatomic, readwrite) NSString *name;

@end

@implementation L3TestCase

@l3_suite("Test cases");

static void test_function(L3TestState *state, L3TestSuite *suite, L3TestCase *testCase) {}

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
#pragma mark Running

-(void)runInSuite:(L3TestSuite *)suite {
	NSLog(@"running test case %@", self.name);
	@autoreleasepool {
		L3TestState *state = [suite.stateClass new];
		if (suite.setUpFunction)
			suite.setUpFunction(state, suite, self);
		
		self.function(state, suite, self);
		
		if (suite.tearDownFunction)
			suite.tearDownFunction(state, suite, self);
	}
}


#pragma mark -
#pragma mark Assertions

@l3_test("return true for passing assertions") {
	bool matched = [_case assertThat:@"a" matches:^bool(id obj) { return YES; } collectingEventsInto:nil];
	l3_assert(matched, l3_is(YES));
}

@l3_test("return false for failing assertions") {
	bool matched = [_case assertThat:@"a" matches:^bool(id obj){ return NO; } collectingEventsInto:nil];
	l3_assert(matched, l3_is(NO));
}

@l3_test("generate assertion succeeded events for successful assertions") {
	L3TestRunner *testRunner = [L3TestRunner new];
	[_case assertThat:@"a" matches:^bool(id x) { return YES; } collectingEventsInto:testRunner];
	
	L3Event *event = testRunner.events.lastObject;
	assert(l3_assert(event.state, l3_is(L3EventStatusSucceeded)) == YES);
}

@l3_test("generate assertion failed events for failed assertions") {
	L3TestRunner *testRunner = [L3TestRunner new];
	[_case assertThat:@"a" matches:^bool(id x) { return NO; } collectingEventsInto:testRunner];
	
	L3Event *event = testRunner.events.lastObject;
	assert(l3_assert(event.state, l3_is(L3EventStatusFailed)) == YES);
}

-(bool)assertThat:(id)object matches:(L3Pattern)pattern collectingEventsInto:(id<L3EventSink>)eventSink {
	bool matched = pattern(object);
	if (eventSink)
		[eventSink addEvent:[L3Event eventWithState:matched? L3EventStatusSucceeded : L3EventStatusFailed source:self]];
	return matched;
}

@end
