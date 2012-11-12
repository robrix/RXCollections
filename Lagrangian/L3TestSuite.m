//  L3TestSuite.m
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestSuite.h"
#import "L3TestState.h"
#import "L3Event.h"
#import "L3EventSink.h"
#import "L3TestSuiteStartEvent.h"
#import "L3TestSuiteEndEvent.h"
#import "Lagrangian.h"

@interface L3TestSuite () <L3TestContext>

@property (copy, nonatomic, readwrite) NSString *name;

@property (strong, nonatomic, readonly) NSMutableArray *mutableTests;
@property (strong, nonatomic, readonly) NSMutableDictionary *mutableTestsByName;

@end

@implementation L3TestSuite

@l3_suite("Test suites");

#pragma mark -
#pragma mark Constructors

+(instancetype)defaultSuite {
	static L3TestSuite *defaultSuite = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultSuite = [self testSuiteWithName:[NSBundle mainBundle].bundlePath.lastPathComponent ?: [NSProcessInfo processInfo].processName];
	});
	return defaultSuite;
}


+(instancetype)testSuiteWithName:(NSString *)name {
	return [[self alloc] initWithName:name];
}

-(instancetype)initWithName:(NSString *)name {
	NSParameterAssert(name != nil);
	if ((self = [super init])) {
		_name = [name copy];
		_mutableTests = [NSMutableArray new];
		_mutableTestsByName = [NSMutableDictionary new];
		_stateClass = [L3TestState class];
	}
	return self;
}


#pragma mark -
#pragma mark Tests

-(void)addTest:(id<L3Test>)test {
	NSParameterAssert(test != nil);
	NSParameterAssert([self.testsByName objectForKey:test.name] == nil);
	
	[self.mutableTests addObject:test];
	[self.mutableTestsByName setObject:test forKey:test.name];
}


-(NSArray *)tests {
	return self.mutableTests;
}

-(NSDictionary *)testsByName {
	return self.mutableTestsByName;
}


-(void)setStateClass:(Class)stateClass {
	NSAssert(stateClass != nil, @"No state class found for suite ‘%@’. Did you forget to add a @l3_suite_implementation for this suite? Did you add one but give it the wrong name?", self.name);
	_stateClass = stateClass;
}


#pragma mark -
#pragma mark L3Test

@l3_test("generate suite started events when starting to run") {
	L3EventSink *eventSink = [L3EventSink new];
	L3TestSuite *testSuite = [L3TestSuite testSuiteWithName:[NSString stringWithFormat:@"%@ test suite", _case.name]];
	[testSuite runInContext:nil eventAlgebra:eventSink];
	if (l3_assert(eventSink.events.count, l3_greaterThanOrEqualTo(1u))) {
		L3TestSuiteStartEvent *event = [eventSink.events objectAtIndex:0];
		l3_assert(event, l3_isKindOfClass([L3TestSuiteStartEvent class]));
		l3_assert(event.testSuite, l3_is(_case));
	}
}

@l3_test("generate suite finished events when done running") {
	L3EventSink *eventSink = [L3EventSink new];
	L3TestSuite *testSuite = [L3TestSuite testSuiteWithName:[NSString stringWithFormat:@"%@ test suite", _case.name]];
	[testSuite runInContext:nil eventAlgebra:eventSink];
	L3TestSuiteEndEvent *event = eventSink.events.lastObject;
	l3_assert(event, l3_isKindOfClass([L3TestSuiteEndEvent class]));
	l3_assert(event.testSuite, l3_is(_case));
}

-(void)runInContext:(id<L3TestContext>)context eventAlgebra:(id<L3EventAlgebra>)eventAlgebra {
	[eventAlgebra testSuiteStartEventWithTestSuite:self date:nil];
	for (id<L3Test> test in self.tests) {
		[test runInContext:self eventAlgebra:eventAlgebra];
	}
	[eventAlgebra testSuiteEndEventWithTestSuite:self date:nil];
}

@end
