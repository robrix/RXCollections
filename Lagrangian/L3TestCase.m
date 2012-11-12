//  L3TestCase.m
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestContext.h"
#import "L3TestState.h"
#import "L3TestSuite.h"
#import "L3Event.h"
#import "L3EventSink.h"
#import "Lagrangian.h"

@interface L3TestCase ()

@property (copy, nonatomic, readwrite) NSString *name;

@property (weak, nonatomic, readwrite) L3EventSink *eventSink;

@end

@implementation L3TestCase

@l3_suite("Test cases");

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
#pragma mark Running

@l3_test("generate case started events when starting to run") {
	L3EventSink *eventSink = [L3EventSink new];
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" function:test_function];
	[testCase runInContext:nil collectingEventsInto:eventSink];
	if (l3_assert(eventSink.events.count, l3_greaterThanOrEqualTo(1u))) {
		L3Event *event = [eventSink.events objectAtIndex:0];
		l3_assert(event.state, l3_is(L3EventStateStarted));
	}
}

@l3_test("generate case finished events when done running") {
	L3EventSink *eventSink = [L3EventSink new];
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"name" function:test_function];
	[testCase runInContext:nil collectingEventsInto:eventSink];
	l3_assert(eventSink.events.count, l3_greaterThanOrEqualTo(1u));
	L3Event *event = eventSink.events.lastObject;
	l3_assert(event.state, l3_is(L3EventStateEnded));
}

-(void)runInContext:(id<L3TestContext>)context collectingEventsInto:(L3EventSink *)eventSink {
	L3TestState *state = [context.stateClass new];
	self.eventSink = eventSink;
	
	[eventSink addEvent:[L3Event eventWithState:L3EventStateStarted source:self]];
	
	if (context.setUpFunction)
		context.setUpFunction(state, self);
	
	self.function(state, self);
	
	if (context.tearDownFunction)
		context.tearDownFunction(state, self);
	
	[eventSink addEvent:[L3Event eventWithState:L3EventStateEnded source:self]];
	
	self.eventSink = nil;
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
	L3EventSink *eventSink = [L3EventSink new];
	[_case assertThat:@"a" matches:^bool(id x) { return YES; } collectingEventsInto:eventSink];
	
	L3Event *event = eventSink.events.lastObject;
	assert(l3_assert(event.state, l3_is(L3EventStateSucceeded)) == YES);
}

@l3_test("generate assertion failed events for failed assertions") {
	L3EventSink *eventSink = [L3EventSink new];
	[_case assertThat:@"a" matches:^bool(id x) { return NO; } collectingEventsInto:eventSink];
	
	L3Event *event = eventSink.events.lastObject;
	assert(l3_assert(event.state, l3_is(L3EventStateFailed)) == YES);
}

-(bool)assertThat:(id)object matches:(L3Pattern)pattern collectingEventsInto:(L3EventSink *)eventSink {
	bool matched = pattern(object);
	[eventSink addEvent:[L3Event eventWithState:matched? L3EventStateSucceeded : L3EventStateFailed source:self]];
	return matched;
}

@end
